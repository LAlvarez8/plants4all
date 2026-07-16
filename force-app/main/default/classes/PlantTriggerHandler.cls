public with sharing class PlantTriggerHandler {
    public static void handle() {
        if (!Trigger.isBefore) {
            return;
        }

        if (Trigger.isInsert) {
            beforeInsert((List<Plant__c>) Trigger.new);
        }

        if (Trigger.isUpdate) {
            beforeUpdate(
                (List<Plant__c>) Trigger.new,
                (Map<Id, Plant__c>) Trigger.oldMap
            );
        }
    }

    private static void beforeInsert(List<Plant__c> newPlants) {
        processPlants(newPlants, null);
    }

    private static void beforeUpdate(
        List<Plant__c> newPlants,
        Map<Id, Plant__c> oldMap
    ) {
        processPlants(newPlants, oldMap);
    }

    private static void processPlants(
        List<Plant__c> newPlants,
        Map<Id, Plant__c> oldMap
    ) {
        PlantService plantService = new PlantService();
        plantService.calculateNextWateringDate(newPlants);
        plantService.calculateNextFertilizationDate(newPlants);
    }
}