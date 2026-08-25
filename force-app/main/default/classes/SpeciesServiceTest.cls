@isTest
private class SpeciesServiceTest {
  @isTest
  static void getFilteredSpecies_emptySearchText_returnsAllSpecies() {
    Integer speciesCount = 3;
    List<Species__c> speciesToInsert = new List<Species__c>();
    for (Integer i = 0; i < speciesCount; i++) {
      speciesToInsert.add(
        new Species__c(
          Name = 'Species ' + i,
          Location__c = 'Outdoors',
          Locationes__c = 'Tropical (Amazonas, sureste asiático)'
        )
      );
    }
    insert speciesToInsert;

    Test.startTest();
    List<Species__c> returnedSpecies = SpeciesService.getFilteredSpecies('');
    Test.stopTest();

    System.assertEquals(
      speciesCount,
      returnedSpecies.size(),
      'Debería devolver todas las especies'
    );
  }
}
