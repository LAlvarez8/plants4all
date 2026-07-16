@RestResource(urlMapping='/weather-alert/*')
global with sharing class ForecastRestApi {
    global class ResponseDTO {
        public Integer alertsSent;
        public String status;
    }

    @HttpGet
    global static ResponseDTO executeWeatherCheck() {
        // Validar acceso al objeto Plant__c (CRUD) antes de ejecutar la lógica
        if (!Schema.sObjectType.Plant__c.isAccessible()) {
            throw new AuraHandledException('No tienes permisos para leer registros de Plant__c');
        }

        Integer alerts = WeatherAlertService.checkWeather();

        ResponseDTO response = new ResponseDTO();
        response.alertsSent = alerts;
        response.status = 'success';

        return response;
    }
}