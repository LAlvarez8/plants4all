@isTest
private with sharing class PlantServiceTest {
  @TestSetup
  static void createData() {
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
  static void testCalculateNextWateringDate() {
    Species__c specie = [SELECT Id, Whatering__c FROM Species__c LIMIT 1];
    Plant__c plant = new Plant__c(
      Species__c = specie.Id,
      Last_Watered__c = System.today(),
      Last_Fertilization__c = System.today()
    );
    PlantService plantService = new PlantService();
    plantService.calculateNextWateringDate(new List<Plant__c>{ plant });
    System.assertEquals(
      System.today().addDays(7),
      plant.Next_Water__c,
      'Next_Water__c should be 7 days after Last_Watered__c'
    );
  }

  @isTest
  static void testCalculateNextFertilizationDate() {
    Species__c specie = [SELECT Id, Fertilization__c FROM Species__c LIMIT 1];
    Plant__c plant = new Plant__c(
      Species__c = specie.Id,
      Last_Watered__c = System.today(),
      Last_Fertilization__c = System.today()
    );
    PlantService plantService = new PlantService();
    plantService.calculateNextFertilizationDate(new List<Plant__c>{ plant });
    System.assertEquals(
      System.today().addDays(30),
      plant.Next_Fertilization__c,
      'Next_Fertilization__c should be 30 days after Last_Fertilization__c'
    );
  }
}
