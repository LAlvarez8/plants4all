public with sharing class ForecastService {
    public class ForecastResponse {
        @AuraEnabled
        public Daily daily;
    }

    public class Daily {
        @AuraEnabled
        public List<Double> temperature_2m_max; // NOPMD - nombre requerido por la API externa
        @AuraEnabled
        public List<Double> temperature_2m_min; // NOPMD - nombre requerido por la API externa
    }

    public class ForecastException extends Exception {}

    @AuraEnabled(cacheable=true)
    public static ForecastResponse getTodayTemperature() {
        String endpoint = 'callout:OpenMeteo/v1/forecast?latitude=37.18&longitude=-3.60&daily=temperature_2m_max,temperature_2m_min&timezone=Europe/Madrid';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(12000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new ForecastException('OpenMeteo callout failed: ' + res.getStatusCode() + ' - ' + res.getStatus());
        }

        return (ForecastResponse) JSON.deserialize(res.getBody(), ForecastResponse.class);
    }
}