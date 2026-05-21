@isTest
private with sharing class FrequencyServiceTest {
  private class DateServiceMock extends DateService {
    private Integer monthToReturn;
    public DateServiceMock(Integer month) {
      this.monthToReturn = month;
    }
    public override Integer getCurrentMonth() {
      return monthToReturn;
    }
  }

  @isTest
  static void testGetWateringDaysStaticDelegatesToInstance() {
    Species__c species = new Species__c(
      Whatering__c = 'Low (1 vez por semana)'
    );
    Integer days = FrequencyService.getWateringDays(species);
    System.assertEquals(
      7,
      days,
      'getWateringDays debería devolver 7 para frecuencia baja'
    );
  }

  @isTest
  static void testCalculateWateringDaysWithWinterLogic() {
    DateService mockDate = new DateServiceMock(12);
    FrequencyService service = new FrequencyService(mockDate);
    Species__c species = new Species__c(
      Whatering__c = 'Low (1 vez por semana)'
    );
    Integer days = service.calculateWateringDays(species);
    System.assertEquals(
      7,
      days,
      'En invierno debería mantener los días de riego (aún sin modificar)'
    );
  }

  @isTest
  static void testCalculateWateringDaysSummer() {
    DateService mockDate = new DateServiceMock(7);
    FrequencyService service = new FrequencyService(mockDate);
    Species__c species = new Species__c(Whatering__c = 'High (diario)');
    Integer days = service.calculateWateringDays(species);
    System.assertEquals(
      1,
      days,
      'Frecuencia alta debe devolver 1 día en verano'
    );
  }

  @isTest
  static void testCalculateWateringDaysNullSpecies() {
    DateService mockDate = new DateServiceMock(1);
    FrequencyService service = new FrequencyService(mockDate);
    Integer days = service.calculateWateringDays(null);
    System.assertEquals(
      7,
      days,
      'Species nulo debe devolver el valor por defecto (7 días)'
    );
  }

  @isTest
  static void testCalculateWateringDaysInvalidFrequency() {
    DateService mockDate = new DateServiceMock(1);
    FrequencyService service = new FrequencyService(mockDate);
    Species__c species = new Species__c(Whatering__c = 'Unknown');
    Integer days = service.calculateWateringDays(species);
    System.assertEquals(
      7,
      days,
      'Frecuencia desconocida debe devolver el valor por defecto (7)'
    );
  }

  @isTest
  static void testCalculateFertilizationDays() {
    DateService mockDate = new DateServiceMock(1);
    FrequencyService service = new FrequencyService(mockDate);
    Species__c species = new Species__c(Fertilization__c = 'Low (cada mes)');
    Integer days = service.calculateFertilizationDays(species);
    System.assertEquals(30, days, 'Fertilización baja debe devolver 30 días');
  }

  @isTest
  static void testGetFertilizationDaysDefault() {
    Species__c species = new Species__c(Fertilization__c = null);
    Integer days = FrequencyService.getFertilizationDays(species);
    System.assertEquals(
      30,
      days,
      'Fertilización nula debe devolver el valor por defecto (30)'
    );
  }
}
