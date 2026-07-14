@IsTest
private class ForecastServiceTest {
    private class SuccessfulForecastMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(
                '{"daily":{"temperature_2m_max":[32],"temperature_2m_min":[8]}}'
            );
            return response;
        }
    }

    private class FailedForecastMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('{"error":true}');
            return response;
        }
    }

    @IsTest
    static void getTodayTemperatureDeserializesForecast() {
        Test.setMock(HttpCalloutMock.class, new SuccessfulForecastMock());

        Test.startTest();
        ForecastService.ForecastResponse forecast = ForecastService.getTodayTemperature();
        Test.stopTest();

        System.assertEquals(
            32,
            forecast.daily.temperature_2m_max[0],
            'La temperatura máxima debería ser 32°C'
        );
        System.assertEquals(
            8,
            forecast.daily.temperature_2m_min[0],
            'La temperatura mínima debería ser 8°C'
        );
    }

    @IsTest
    static void getTodayTemperatureThrowsWhenCalloutFails() {
        Test.setMock(HttpCalloutMock.class, new FailedForecastMock());

        Test.startTest();
        try {
            ForecastService.getTodayTemperature();
            System.assert(
                false,
                'Debería haber lanzado ForecastException'
            );
        } catch (ForecastService.ForecastException ex) {
            System.assert(
                ex.getMessage().contains('OpenMeteo callout failed'),
                'El mensaje de la excepción debería indicar fallo en el callout'
            );
        }
        Test.stopTest();
    }
}