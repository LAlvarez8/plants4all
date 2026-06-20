@IsTest
private class PlantsDashboardControllerTest {
  @TestSetup
  static void createData() {
    Species__c aloe = new Species__c(
      Name = 'Aloe Vera',
      Location__c = 'Indoors',
      Locationes__c = 'Tropical',
      Whatering__c = 'Low (1 vez por semana)',
      Fertilization__c = 'Low (cada mes)'
    );
    Species__c perejil = new Species__c(
      Name = 'Perejil',
      Location__c = 'Outdoors',
      Locationes__c = 'Tropical',
      Whatering__c = 'High (diario)',
      Fertilization__c = 'Medium (cada 2 semanas)'
    );
    insert new List<Species__c>{ aloe, perejil };

    insert new List<Plant__c>{
      new Plant__c(
        Species__c = aloe.Id,
        Last_Watered__c = Date.today().addDays(-10),
        Last_Fertilization__c = Date.today().addDays(-40),
        Next_Water__c = Date.today().addDays(-1),
        Next_Fertilization__c = Date.today().addDays(-1)
      ),
      new Plant__c(
        Species__c = perejil.Id,
        Last_Watered__c = Date.today(),
        Last_Fertilization__c = Date.today(),
        Next_Water__c = Date.today().addDays(1),
        Next_Fertilization__c = Date.today().addDays(1)
      )
    };
  }

  @IsTest
  static void getDashboardDataReturnsChartRows() {
    Test.startTest();
    PlantsDashboardController.DashboardData data = PlantsDashboardController.getDashboardData();
    Test.stopTest();

    System.assertEquals(
      2,
      data.plantsBySpecies.size(),
      'Debe haber 2 especies con plantas'
    );
    System.assertEquals(
      1,
      data.pendingWatering.size(),
      'Debe haber 1 especie con riego pendiente'
    );
    System.assertEquals(
      1,
      data.pendingFertilization.size(),
      'Debe haber 1 especie con fertilización pendiente'
    );
    System.assertEquals(
      1,
      data.plantsByOwner.size(),
      'Debe haber 1 propietario con plantas'
    );
    System.assertNotEquals(
      null,
      data.generatedAt,
      'La fecha de generación no debe ser nula'
    );
  }

  @IsTest
  static void getDashboardDataWhenNoPlants() {
    delete [SELECT Id FROM Plant__c];

    Test.startTest();
    PlantsDashboardController.DashboardData data = PlantsDashboardController.getDashboardData();
    Test.stopTest();

    System.assertEquals(
      0,
      data.plantsBySpecies.size(),
      'No debe haber especies con plantas'
    );
    System.assertEquals(
      0,
      data.pendingWatering.size(),
      'No debe haber plantas con riego pendiente'
    );
    System.assertEquals(
      0,
      data.pendingFertilization.size(),
      'No debe haber plantas con fertilización pendiente'
    );
    System.assertEquals(
      0,
      data.plantsByOwner.size(),
      'No debe haber propietarios con plantas'
    );
    System.assertNotEquals(
      null,
      data.generatedAt,
      'La fecha de generación no debe ser nula'
    );
  }
}
