@IsTest
private class SpeciesServiceTest {
  @IsTest
  static void getFilteredSpeciesReturnsMatchingRecords() {
    String locationes = Species__c.Locationes__c
        .getDescribe()
        .getPicklistValues()[0]
      .getValue();

    insert new Species__c(
      Name = 'Aloe Vera',
      Description__c = 'Planta de prueba',
      Image_URL__c = 'https://example.com/aloe.jpg',
      Location__c = 'Indoors',
      Locationes__c = locationes,
      Whatering__c = 'Low (1 vez por semana)',
      Fertilization__c = 'Low (cada mes)',
      Ideal_Max_Temperature__c = 25,
      Ideal_Min_Temperature__c = 12
    );

    Test.startTest();
    List<Species__c> species = SpeciesService.getFilteredSpecies('Aloe');
    Test.stopTest();

    System.assertEquals(1, species.size());
    System.assertEquals('Aloe Vera', species[0].Name);
    System.assertEquals(25, species[0].Ideal_Max_Temperature__c);
    System.assertEquals(12, species[0].Ideal_Min_Temperature__c);
  }
}
