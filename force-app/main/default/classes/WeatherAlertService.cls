public with sharing class WeatherAlertService {
    private static final String NOTIFICATION_TYPE_DEVELOPER_NAME = 'Temperature_Alert';

    @TestVisible
    private static Boolean skipNotifications = false;

    // ─── MÉTODO PRINCIPAL (con SOQL for loop y Savepoint) ──────────────────────
    public static Integer checkWeather() {
        Savepoint sp = Database.setSavepoint();
        try {
            // 1. Obtener pronóstico
            ForecastService.ForecastResponse forecast = ForecastService.getTodayTemperature();
            if (forecast == null || forecast.daily == null) {
                return 0;
            }
            Decimal maxTemp = forecast.daily.temperature_2m_max[0];
            Decimal minTemp = forecast.daily.temperature_2m_min[0];

            // 2. Procesar plantas con SOQL for loop (bulkificado en bloques de 200)
            Integer alertsSent = 0;
            for (Plant__c plant : getPlantsWithProblemsQuery(maxTemp, minTemp)) {
                alertsSent += processPlant(plant, maxTemp, minTemp);
            }

            return alertsSent;
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('❌ Error en checkWeather: ' + e.getMessage());
            return 0;
        }
    }

    // ─── CONSULTA (devuelve la query para el SOQL for loop) ────────────────────
    private static Iterable<Plant__c> getPlantsWithProblemsQuery(Decimal maxTemp, Decimal minTemp) {
        // Validar permisos de acceso a Plant__c y a campos relacionados
        if (!Schema.sObjectType.Plant__c.isAccessible()) {
            return new List<Plant__c>();
        }
        if (!Schema.sObjectType.Plant__c.fields.Id.isAccessible() ||
            !Schema.sObjectType.Plant__c.fields.Name.isAccessible() ||
            !Schema.sObjectType.Plant__c.fields.OwnerId.isAccessible() ||
            !Schema.sObjectType.Species__c.fields.Name.isAccessible() ||
            !Schema.sObjectType.Species__c.fields.Ideal_Max_Temperature__c.isAccessible() ||
            !Schema.sObjectType.Species__c.fields.Ideal_Min_Temperature__c.isAccessible()) {
            return new List<Plant__c>();
        }

        // La query se ejecutará en el SOQL for loop de checkWeather()
        return [
            SELECT
                Id,
                Name,
                OwnerId,
                Species__r.Name,
                Species__r.Ideal_Max_Temperature__c,
                Species__r.Ideal_Min_Temperature__c
            FROM Plant__c
            WHERE Species__c != NULL
              AND (Species__r.Ideal_Max_Temperature__c < :maxTemp
                OR Species__r.Ideal_Min_Temperature__c > :minTemp)
        ];
    }

    // ─── PROCESAR UNA PLANTA INDIVIDUAL ──────────────────────────────────────────
    private static Integer processPlant(Plant__c plant, Decimal maxTemp, Decimal minTemp) {
        Integer alertsSent = 0;
        Boolean isHot = false;
        Boolean isCold = false;

        if (plant.Species__r.Ideal_Max_Temperature__c != null &&
            plant.Species__r.Ideal_Max_Temperature__c < maxTemp) {
            isHot = true;
            sendNotification(
                plant,
                'Hace demasiado calor para tu planta',
                'Hoy se esperan ' + maxTemp +
                ' grados. Tu ' + plant.Species__r.Name +
                ' soporta maximo ' + plant.Species__r.Ideal_Max_Temperature__c + '.'
            );
            alertsSent++;
        }

        if (plant.Species__r.Ideal_Min_Temperature__c != null &&
            plant.Species__r.Ideal_Min_Temperature__c > minTemp) {
            isCold = true;
            sendNotification(
                plant,
                'Hace demasiado frio para tu planta',
                'Hoy se esperan ' + minTemp +
                ' grados. Tu ' + plant.Species__r.Name +
                ' necesita al menos ' + plant.Species__r.Ideal_Min_Temperature__c + '.'
            );
            alertsSent++;
        }

        if (!skipNotifications && (isHot || isCold)) {
            String alertType = isHot && isCold ? 'Both' : (isHot ? 'Hot' : 'Cold');
            publishPlatformEvent(plant.Id, alertType);
        }

        return alertsSent;
    }

    // ─── ENVIAR NOTIFICACIÓN ──────────────────────────────────────────────────────
    private static void sendNotification(Plant__c plant, String title, String body) {
        if (skipNotifications) {
            return;
        }

        Id notificationTypeId = getNotificationTypeId();
        if (notificationTypeId == null) {
            return;
        }

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(title);
        notification.setBody(body);
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(plant.Id);
        notification.send(new Set<String>{ String.valueOf(plant.OwnerId) });
    }

    // ─── OBTENER ID DEL TIPO DE NOTIFICACIÓN ────────────────────────────────────
    private static Id getNotificationTypeId() {
        if (!Schema.sObjectType.CustomNotificationType.isAccessible()) {
            return null;
        }
        if (!CustomNotificationType.Id.getDescribe().isAccessible()) {
            return null;
        }

        List<CustomNotificationType> types = [
            SELECT Id
            FROM CustomNotificationType
            WHERE DeveloperName = :NOTIFICATION_TYPE_DEVELOPER_NAME
            LIMIT 1
        ];
        if (types.isEmpty()) {
            return null;
        }
        return types[0].Id;
    }

    // ─── PUBLICAR PLATFORM EVENT ──────────────────────────────────────────────────
    private static void publishPlatformEvent(Id plantId, String alertType) {
        if (skipNotifications) {
            return;
        }

        if (!Schema.sObjectType.Plant_With_Problems__e.isCreateable()) {
            System.debug('⚠️ El usuario no tiene permisos para publicar Platform Events');
            return;
        }

        Plant_With_Problems__e event = new Plant_With_Problems__e(
            Plant_Id__c = plantId,
            Alert_Type__c = alertType
        );

        List<Database.SaveResult> results = EventBus.publish(new List<Plant_With_Problems__e>{ event });

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('✅ PLATFORM EVENT PUBLICADO con ID: ' + sr.getId() + ' para planta: ' + plantId);
            } else {
                System.debug('❌ Error al publicar evento: ' + sr.getErrors());
            }
        }
    }
}