@IsTest
private class WeatherAlertServiceTest {
  private class HotForecastMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody(
        '{"daily":{"temperature_2m_max":[35],"temperature_2m_min":[18]}}'
      );
      return response;
    }
  }

  private class ColdForecastMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody(
        '{"daily":{"temperature_2m_max":[20],"temperature_2m_min":[5]}}'
      );
      return response;
    }
  }

  private class ComfortableForecastMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody(
        '{"daily":{"temperature_2m_max":[22],"temperature_2m_min":[18]}}'
      );
      return response;
    }
  }

  @TestSetup
  static void setupData() {
    String locationes = Species__c.Locationes__c
        .getDescribe()
        .getPicklistValues()[0]
      .getValue();

    Species__c species = new Species__c(
      Name = 'Aloe Vera',
      Whatering__c = 'Low (1 vez por semana)',
      Fertilization__c = 'Low (cada mes)',
      Location__c = 'Indoors',
      Locationes__c = locationes,
      Ideal_Max_Temperature__c = 25,
      Ideal_Min_Temperature__c = 12
    );
    insert species;

    insert new Plant__c(
      Species__c = species.Id,
      Last_Watered__c = System.today(),
      Last_Fertilization__c = System.today()
    );
  }

  @IsTest
  static void checkWeatherReturnsHotAlertCount() {
    Test.setMock(HttpCalloutMock.class, new HotForecastMock());
    WeatherAlertService.skipNotifications = true;

    Test.startTest();
    Integer alerts = WeatherAlertService.checkWeather();
    Test.stopTest();

    System.assertEquals(1, alerts);
  }

  @IsTest
  static void checkWeatherReturnsColdAlertCount() {
    Test.setMock(HttpCalloutMock.class, new ColdForecastMock());
    WeatherAlertService.skipNotifications = true;

    Test.startTest();
    Integer alerts = WeatherAlertService.checkWeather();
    Test.stopTest();

    System.assertEquals(1, alerts);
  }

  @IsTest
  static void checkWeatherReturnsZeroWhenTemperatureIsComfortable() {
    Test.setMock(HttpCalloutMock.class, new ComfortableForecastMock());
    WeatherAlertService.skipNotifications = true;

    Test.startTest();
    Integer alerts = WeatherAlertService.checkWeather();
    Test.stopTest();

    System.assertEquals(0, alerts);
  }
}
