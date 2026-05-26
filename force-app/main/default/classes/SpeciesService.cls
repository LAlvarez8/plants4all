public with sharing class SpeciesService {
  @AuraEnabled(cacheable=true)
  public static List<Species__c> getFilteredSpecies(String searchText) {
    // Validate CRUD permissions before querying
    if (!Schema.sObjectType.Species__c.isAccessible()) {
      throw new AuraHandledException(
        'No tienes permisos para leer registros de Species__c'
      );
    }

    String likeValue = '%' + searchText + '%';
    return [
      SELECT
        Id,
        Name,
        Description__c,
        Image_URL__c,
        Location__c,
        Ideal_Max_Temperature__c,
        Ideal_Min_Temperature__c
      FROM Species__c
      WHERE Name LIKE :likeValue
      WITH SECURITY_ENFORCED
    ];
  }
}
