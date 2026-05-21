@isTest
private with sharing class PlantTriggerTest {
  // =========================================
  // TEST SETUP
  // =========================================

  @TestSetup
  static void createData() {
    Species__c aloeVera = new Species__c(
      Name = 'Aloe Vera',
      Whatering__c = 'Low (1 vez por semana)',
      Fertilization__c = 'Low (cada mes)',
      Location__c = 'Indoors'
    );

    insert aloeVera;
  }

  // =========================================
  // TEST NEXT WATER DATE
  // =========================================

  @isTest
  static void updatePlantNextWateringDateCalculatedCorrectly() {
    // ARRANGE

    Species__c specie = [
      SELECT Id
      FROM Species__c
      LIMIT 1
    ];

    Plant__c plant = new Plant__c(
      Species__c = specie.Id,
      Last_Watered__c = System.today(),
      Last_Fertilization__c = System.today()
    );

    // ACT

    Test.startTest();

    insert plant;

    Test.stopTest();

    // ASSERT

    plant = [
      SELECT Next_Water__c
      FROM Plant__c
      WHERE Id = :plant.Id
    ];

    System.assertEquals(
      System.today() + 7,
      plant.Next_Water__c,
      'La fecha de siguiente riego debe ser 7 dias despues del ultimo riego'
    );
  }

  // =========================================
  // TEST NEXT FERTILIZATION DATE
  // =========================================

  @isTest
  static void updatePlantNextFertilizationDateCalculatedCorrectly() {
    // ARRANGE

    Species__c specie = [
      SELECT Id
      FROM Species__c
      LIMIT 1
    ];

    Plant__c plant = new Plant__c(
      Species__c = specie.Id,
      Last_Watered__c = System.today(),
      Last_Fertilization__c = System.today()
    );

    // ACT

    Test.startTest();

    insert plant;

    Test.stopTest();

    // ASSERT

    plant = [
      SELECT Next_Fertilization__c
      FROM Plant__c
      WHERE Id = :plant.Id
    ];

    System.assertEquals(
      System.today() + 30,
      plant.Next_Fertilization__c,
      'La fecha de siguiente fertilizacion debe ser 30 dias despues'
    );
  }
}
