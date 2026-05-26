@isTest
private with sharing class PlantTriggerTest {
  @TestSetup
  static void createData() {
    // Valor fijo del picklist (cualquiera de los 12 valores funciona)
    String locationesValue = '🌴 Tropical (Amazonas, sureste asiático)';

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
  static void updatePlantNextWateringDateCalculatedCorrectly() {
    Species__c specie = [SELECT Id FROM Species__c LIMIT 1];

    Plant__c plant = new Plant__c(
      Species__c = specie.Id,
      Last_Watered__c = System.today(),
      Last_Fertilization__c = System.today()
    );

    Test.startTest();
    insert plant;
    Test.stopTest();

    plant = [SELECT Next_Water__c FROM Plant__c WHERE Id = :plant.Id];

    System.assertEquals(
      System.today().addDays(7),
      plant.Next_Water__c,
      'Next water date should be 7 days after last watered date'
    );
  }

  @isTest
  static void updatePlantNextFertilizationDateCalculatedCorrectly() {
    Species__c specie = [SELECT Id FROM Species__c LIMIT 1];

    Plant__c plant = new Plant__c(
      Species__c = specie.Id,
      Last_Watered__c = System.today(),
      Last_Fertilization__c = System.today()
    );

    Test.startTest();
    insert plant;
    Test.stopTest();

    plant = [SELECT Next_Fertilization__c FROM Plant__c WHERE Id = :plant.Id];

    System.assertEquals(
      System.today().addDays(30),
      plant.Next_Fertilization__c,
      'Next fertilization date should be 30 days after last fertilization date'
    );
  }

  @isTest
  static void updatePlantRecalculatesDatesCorrectly() {
    Species__c specie = [SELECT Id FROM Species__c LIMIT 1];

    Plant__c plant = new Plant__c(
      Species__c = specie.Id,
      Last_Watered__c = System.today(),
      Last_Fertilization__c = System.today()
    );
    insert plant;

    Date newDate = System.today().addDays(1);
    plant.Last_Watered__c = newDate;
    plant.Last_Fertilization__c = newDate;

    Test.startTest();
    update plant;
    Test.stopTest();

    plant = [
      SELECT Next_Water__c, Next_Fertilization__c
      FROM Plant__c
      WHERE Id = :plant.Id
    ];

    System.assertEquals(
      newDate.addDays(7),
      plant.Next_Water__c,
      'Next water date should recalculate after update'
    );

    System.assertEquals(
      newDate.addDays(30),
      plant.Next_Fertilization__c,
      'Next fertilization date should recalculate after update'
    );
  }
}
