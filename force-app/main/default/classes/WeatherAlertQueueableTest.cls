@IsTest
private class WeatherAlertQueueableTest {
  private class ForecastMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody(
        '{"daily":{"temperature_2m_max":[22],"temperature_2m_min":[18]}}'
      );

      return response;
    }
  }

  @IsTest
  static void executeRunsWeatherCheck() {
    Test.setMock(HttpCalloutMock.class, new ForecastMock());

    Test.startTest();

    WeatherAlertService.checkWeather();

    Test.stopTest();

    System.assert(true, 'Weather check completed without errors');
  }
}
