public with sharing class SpeciesPlantController {
  @AuraEnabled
  public static String createSpeciesAndPlant(
    String speciesName,
    String plantName,
    Date lastWatered,
    Date lastFertilization
  ) {
    if (!Schema.sObjectType.Species__c.isCreateable()) {
      throw new AuraHandledException('No tienes permiso para crear especies');
    }
    if (!Schema.sObjectType.Plant__c.isCreateable()) {
      throw new AuraHandledException('No tienes permiso para crear plantas');
    }

    Savepoint sp = Database.setSavepoint();

    try {
      Species__c newSpecies = new Species__c(Name = speciesName);
      insert newSpecies;

      Plant__c newPlant = new Plant__c(
        Plant_Name__c = plantName, // ← Campo personalizado en lugar de Name
        Species__c = newSpecies.Id,
        Last_Watered__c = lastWatered,
        Last_Fertilization__c = lastFertilization
      );
      insert newPlant;

      return newSpecies.Id;
    } catch (Exception e) {
      Database.rollback(sp);
      throw new AuraHandledException(
        'Error al crear la planta: ' + e.getMessage()
      );
    }
  }
}
