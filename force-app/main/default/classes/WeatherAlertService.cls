public with sharing class WeatherAlertService {
  private static final String NOTIFICATION_TYPE_DEVELOPER_NAME = 'Temperature_Alert';

  @TestVisible
  private static Boolean skipNotifications = false;

  // ─── MÉTODO PRINCIPAL ──────────────────────────────────────────────────────────
  public static Integer checkWeather() {
    // 1. Obtener pronóstico
    ForecastService.ForecastResponse forecast = ForecastService.getTodayTemperature();
    // Validar que el pronóstico tenga datos
    if (forecast == null || forecast.daily == null) {
      return 0;
    }
    Decimal maxTemp = forecast.daily.temperature_2m_max[0];
    Decimal minTemp = forecast.daily.temperature_2m_min[0];

    // 2. Obtener plantas con problemas (con validación CRUD manual y FLS)
    List<Plant__c> plantsWithProblems = getPlantsWithProblems(maxTemp, minTemp);

    // 3. Procesar cada planta
    Integer alertsSent = 0;
    for (Plant__c plant : plantsWithProblems) {
      alertsSent += processPlant(plant, maxTemp, minTemp);
    }

    return alertsSent;
  }

  // ─── CONSULTAR PLANTAS CON PROBLEMAS (seguridad manual) ──────────────────────
  private static List<Plant__c> getPlantsWithProblems(
    Decimal maxTemp,
    Decimal minTemp
  ) {
    // Validar permisos de acceso a Plant__c y a campos relacionados
    if (!Schema.sObjectType.Plant__c.isAccessible()) {
      return new List<Plant__c>();
    }
    if (
      !Schema.sObjectType.Plant__c.fields.Id.isAccessible() ||
      !Schema.sObjectType.Plant__c.fields.Name.isAccessible() ||
      !Schema.sObjectType.Plant__c.fields.OwnerId.isAccessible() ||
      !Schema.sObjectType.Species__c.fields.Name.isAccessible() ||
      !Schema.sObjectType.Species__c.fields.Ideal_Max_Temperature__c.isAccessible() ||
      !Schema.sObjectType.Species__c.fields.Ideal_Min_Temperature__c.isAccessible()
    ) {
      return new List<Plant__c>();
    }

    // Consulta sin WITH SECURITY_ENFORCED para evitar errores de sintaxis
    return [
      SELECT
        Id,
        Name,
        OwnerId,
        Species__r.Name,
        Species__r.Ideal_Max_Temperature__c,
        Species__r.Ideal_Min_Temperature__c
      FROM Plant__c
      WHERE
        Species__c != NULL
        AND (Species__r.Ideal_Max_Temperature__c < :maxTemp
        OR Species__r.Ideal_Min_Temperature__c > :minTemp)
    ];
  }

  // ─── PROCESAR UNA PLANTA INDIVIDUAL ──────────────────────────────────────────
  private static Integer processPlant(
    Plant__c plant,
    Decimal maxTemp,
    Decimal minTemp
  ) {
    Integer alertsSent = 0;
    Boolean isHot = false;
    Boolean isCold = false;

    // Calor
    if (
      plant.Species__r.Ideal_Max_Temperature__c != null &&
      plant.Species__r.Ideal_Max_Temperature__c < maxTemp
    ) {
      isHot = true;
      sendNotification(
        plant,
        'Hace demasiado calor para tu planta',
        'Hoy se esperan ' +
          maxTemp +
          ' grados. Tu ' +
          plant.Species__r.Name +
          ' soporta maximo ' +
          plant.Species__r.Ideal_Max_Temperature__c +
          '.'
      );
      alertsSent++;
    }

    // Frío
    if (
      plant.Species__r.Ideal_Min_Temperature__c != null &&
      plant.Species__r.Ideal_Min_Temperature__c > minTemp
    ) {
      isCold = true;
      sendNotification(
        plant,
        'Hace demasiado frio para tu planta',
        'Hoy se esperan ' +
          minTemp +
          ' grados. Tu ' +
          plant.Species__r.Name +
          ' necesita al menos ' +
          plant.Species__r.Ideal_Min_Temperature__c +
          '.'
      );
      alertsSent++;
    }

    // Publicar Platform Event (si corresponde)
    if (!skipNotifications && (isHot || isCold)) {
      String alertType = isHot && isCold ? 'Both' : (isHot ? 'Hot' : 'Cold');
      publishPlatformEvent(plant.Id, alertType);
    }

    return alertsSent;
  }

  // ─── ENVIAR NOTIFICACIÓN ──────────────────────────────────────────────────────
  private static void sendNotification(
    Plant__c plant,
    String title,
    String body
  ) {
    if (skipNotifications) {
      return;
    }

    Id notificationTypeId = getNotificationTypeId();
    if (notificationTypeId == null) {
      return; // No hay tipo de notificación configurado
    }

    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle(title);
    notification.setBody(body);
    notification.setNotificationTypeId(notificationTypeId);
    notification.setTargetId(plant.Id);
    notification.send(new Set<String>{ String.valueOf(plant.OwnerId) });
  }

  // ─── OBTENER ID DEL TIPO DE NOTIFICACIÓN (con seguridad) ────────────────────
  private static Id getNotificationTypeId() {
    if (!Schema.sObjectType.CustomNotificationType.isAccessible()) {
      return null;
    }

    // Validar permisos de campo
    if (!CustomNotificationType.Id.getDescribe().isAccessible()) {
      return null;
    }

    List<CustomNotificationType> types = [
      SELECT Id
      FROM CustomNotificationType
      WHERE DeveloperName = :NOTIFICATION_TYPE_DEVELOPER_NAME
      LIMIT 1
    ];

    return types.isEmpty() ? null : types[0].Id;
  }

  // ─── PUBLICAR PLATFORM EVENT ──────────────────────────────────────────────────
  private static void publishPlatformEvent(Id plantId, String alertType) {
    if (skipNotifications) {
      return;
    }

    // Validar que el usuario tenga permiso para crear Platform Events
    if (!Schema.sObjectType.Plant_With_Problems__e.isCreateable()) {
      System.debug(
        '⚠️ El usuario no tiene permisos para publicar Platform Events'
      );
      return;
    }

    // Validar permisos de campos del Platform Event
    if (
      !Plant_With_Problems__e.Plant_Id__c.getDescribe().isCreateable() ||
      !Plant_With_Problems__e.Alert_Type__c.getDescribe().isCreateable()
    ) {
      System.debug(
        '⚠️ El usuario no tiene permisos para crear campos del Platform Event'
      );
      return;
    }

    // Crear el evento
    Plant_With_Problems__e event = new Plant_With_Problems__e(
      Plant_Id__c = plantId,
      Alert_Type__c = alertType
    );

    // Publicar en el bus de eventos
    List<Plant_With_Problems__e> events = new List<Plant_With_Problems__e>{
      event
    };
    List<Database.SaveResult> results = EventBus.publish(events);

    // ✅ IMPRIMIR EL ID DEL EVENTO PUBLICADO (para confirmar)
    for (Database.SaveResult sr : results) {
      if (sr.isSuccess()) {
        System.debug(
          '✅ PLATFORM EVENT PUBLICADO con ID: ' +
            sr.getId() +
            ' para planta: ' +
            plantId
        );
      } else {
        System.debug('❌ Error al publicar evento: ' + sr.getErrors());
      }
    }
  }
}
