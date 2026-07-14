@isTest
private with sharing class FrequencyServiceTest {
  @TestSetup
  static void createData() {
    // Valor fijo requerido por el campo multiselect
    String locationesValue = 'Tropical (Amazonas, sureste asiático)';

    Species__c aloeVera = new Species__c(
      Name = 'Aloe Vera',
      Whatering__c = 'Low (1 vez por semana)',
      Fertilization__c = 'Low (cada mes)',
      Location__c = 'Indoors',
      Locationes__c = locationesValue
    );
    insert aloeVera;
  }

  @isTest
  static void testGetWateringDaysLowFrequency() {
    FrequencyService service = new FrequencyService();
    Species__c species = [SELECT Whatering__c FROM Species__c LIMIT 1];
    Integer days = service.calculateWateringDays(species);
    System.assertEquals(7, days, 'Low frequency should return 7 days');
  }

  @isTest
  static void testGetWateringDaysMediumFrequency() {
    FrequencyService service = new FrequencyService();
    Species__c species = new Species__c(
      Whatering__c = 'Medium (2-3 veces por semana)',
      Location__c = 'Indoors',
      Locationes__c = 'Tropical (Amazonas, sureste asiático)'
    );
    insert species;
    Integer days = service.calculateWateringDays(species);
    System.assertEquals(3, days, 'Medium frequency should return 3 days');
  }

  @isTest
  static void testGetWateringDaysHighFrequency() {
    FrequencyService service = new FrequencyService();
    Species__c species = new Species__c(
      Whatering__c = 'High (diario)',
      Location__c = 'Indoors',
      Locationes__c = 'Tropical (Amazonas, sureste asiático)'
    );
    insert species;
    Integer days = service.calculateWateringDays(species);
    System.assertEquals(1, days, 'High frequency should return 1 day');
  }

  @isTest
  static void testGetWateringDaysNullFrequency() {
    FrequencyService service = new FrequencyService();
    Species__c species = new Species__c(
      Whatering__c = null,
      Location__c = 'Indoors',
      Locationes__c = 'Tropical (Amazonas, sureste asiático)'
    );
    insert species;
    Integer days = service.calculateWateringDays(species);
    System.assertEquals(7, days, 'Null frequency should return default 7 days');
  }

  @isTest
  static void testGetWateringDaysInvalidFrequency() {
    FrequencyService service = new FrequencyService();
    Species__c species = new Species__c(
      Whatering__c = 'Invalid',
      Location__c = 'Indoors',
      Locationes__c = 'Tropical (Amazonas, sureste asiático)'
    );
    insert species;
    Integer days = service.calculateWateringDays(species);
    System.assertEquals(
      7,
      days,
      'Invalid frequency should return default 7 days'
    );
  }
}
