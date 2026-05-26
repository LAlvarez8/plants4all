public with sharing class WeatherAlertService {
  private static final String NOTIFICATION_TYPE_DEVELOPER_NAME = 'Temperature_Alert';

  @TestVisible
  private static Boolean skipNotifications = false;

  public static Integer checkWeather() {
    ForecastService.ForecastResponse forecast = ForecastService.getTodayTemperature();

    Decimal maxTemp = forecast.daily.temperature_2m_max[0];
    Decimal minTemp = forecast.daily.temperature_2m_min[0];

    List<Plant__c> plantsWithProblems = [
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

    Integer alertsSent = 0;

    for (Plant__c plant : plantsWithProblems) {
      if (
        plant.Species__r.Ideal_Max_Temperature__c != null &&
        plant.Species__r.Ideal_Max_Temperature__c < maxTemp
      ) {
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

      if (
        plant.Species__r.Ideal_Min_Temperature__c != null &&
        plant.Species__r.Ideal_Min_Temperature__c > minTemp
      ) {
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
    }

    return alertsSent;
  }

  private static void sendNotification(
    Plant__c plant,
    String title,
    String body
  ) {
    if (skipNotifications) {
      return;
    }

    CustomNotificationType notificationType = [
      SELECT Id
      FROM CustomNotificationType
      WHERE DeveloperName = :NOTIFICATION_TYPE_DEVELOPER_NAME
      LIMIT 1
    ];

    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle(title);
    notification.setBody(body);
    notification.setNotificationTypeId(notificationType.Id);
    notification.setTargetId(plant.Id);
    notification.send(new Set<String>{ String.valueOf(plant.OwnerId) });
  }
}
