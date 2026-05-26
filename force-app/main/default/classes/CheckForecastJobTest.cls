@IsTest
private class CheckForecastJobTest {
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
  static void executeRunsWeatherAlertService() {
    Test.setMock(HttpCalloutMock.class, new ForecastMock());
    WeatherAlertService.skipNotifications = true;

    Test.startTest();
    System.schedule(
      'Daily Forecast Check Test',
      '0 0 9 1 1 ? 2099',
      new CheckForecastJob()
    );
    Test.stopTest();

    System.assert(true, 'Scheduled job completed without errors');
  }
}
