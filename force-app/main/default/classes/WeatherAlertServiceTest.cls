@isTest
private with sharing class WeatherAlertServiceTest {
  @TestSetup
  static void setupData() {
    String locationesValue = 'Tropical (Amazonas, sureste asiático)';

    Species__c species = new Species__c(
      Name = 'Test Plant',
      Ideal_Max_Temperature__c = 30,
      Ideal_Min_Temperature__c = 10,
      Location__c = 'Indoors',
      Locationes__c = locationesValue,
      Whatering__c = 'Low (1 vez por semana)',
      Fertilization__c = 'Low (cada mes)'
    );
    insert species;

    Plant__c plant = new Plant__c(
      Species__c = species.Id,
      OwnerId = UserInfo.getUserId(),
      Last_Watered__c = Date.today(),
      Last_Fertilization__c = Date.today()
    );
    insert plant;
  }

  @isTest
  static void testCheckWeatherWithHighTemperature() {
    Test.setMock(HttpCalloutMock.class, new WeatherAlertServiceMock(35, 20));

    Test.startTest();
    Integer result = WeatherAlertService.checkWeather();
    Test.stopTest();

    System.assertEquals(
      1,
      result,
      'Debería haber 1 alerta porque la temperatura máxima supera el límite'
    );
  }

  @isTest
  static void testCheckWeatherWithLowTemperature() {
    Test.setMock(HttpCalloutMock.class, new WeatherAlertServiceMock(25, 5));

    Test.startTest();
    Integer result = WeatherAlertService.checkWeather();
    Test.stopTest();

    System.assertEquals(
      1,
      result,
      'Debería haber 1 alerta porque la temperatura mínima está por debajo del límite'
    );
  }

  @isTest
  static void testCheckWeatherWithComfortableTemperature() {
    Test.setMock(HttpCalloutMock.class, new WeatherAlertServiceMock(25, 15));

    Test.startTest();
    Integer result = WeatherAlertService.checkWeather();
    Test.stopTest();

    System.assertEquals(
      0,
      result,
      'No debería haber alertas porque la temperatura está dentro del rango'
    );
  }

  // =========================
  // MOCK HTTP para WeatherAlertService
  // =========================
  private class WeatherAlertServiceMock implements HttpCalloutMock {
    private Decimal maxTemp;
    private Decimal minTemp;

    public WeatherAlertServiceMock(Decimal max, Decimal min) {
      this.maxTemp = max;
      this.minTemp = min;
    }

    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setBody(
        '{"daily":{"temperature_2m_max":[' +
          maxTemp +
          '],"temperature_2m_min":[' +
          minTemp +
          ']}}'
      );
      return response;
    }
  }
}
