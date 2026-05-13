public with sharing class PlantTriggerHandler {

    // =========================
    // HANDLER PRINCIPAL
    // =========================

    public static void handle() {

        if (Trigger.isBefore) {

            if (Trigger.isInsert) {

                beforeInsert(
                    (List<Plant__c>) Trigger.new
                );
            }

            if (Trigger.isUpdate) {

                beforeUpdate(
                    (List<Plant__c>) Trigger.new,
                    (Map<Id, Plant__c>) Trigger.oldMap
                );
            }
        }
    }

    // =========================
    // BEFORE INSERT
    // =========================

    private static void beforeInsert(
        List<Plant__c> newPlants
    ) {

        processPlants(
            newPlants,
            null
        );
    }

    // =========================
    // BEFORE UPDATE
    // =========================

    private static void beforeUpdate(
        List<Plant__c> newPlants,
        Map<Id, Plant__c> oldMap
    ) {

        processPlants(
            newPlants,
            oldMap
        );
    }

    // =========================
    // PROCESAR PLANTAS
    // =========================

    private static void processPlants(
        List<Plant__c> newPlants,
        Map<Id, Plant__c> oldMap
    ) {

        Set<Id> speciesIds =
            collectSpeciesIds(newPlants);

        Map<Id, Species__c> speciesById =
            loadSpecies(speciesIds);

        for (Plant__c plant : newPlants) {

            Plant__c oldPlant =
                oldMap == null
                ? null
                : oldMap.get(plant.Id);

            Species__c specie =
                speciesById.get(
                    plant.Species__c
                );

            populateNextWateringDate(
                plant,
                oldPlant,
                specie
            );

            populateNextFertilizationDate(
                plant,
                oldPlant,
                specie
            );
        }
    }

    // =========================
    // RECOLECTAR IDS
    // =========================

    private static Set<Id> collectSpeciesIds(
        List<Plant__c> plants
    ) {

        Set<Id> speciesIds =
            new Set<Id>();

        for (Plant__c plant : plants) {

            if (plant.Species__c != null) {

                speciesIds.add(
                    plant.Species__c
                );
            }
        }

        return speciesIds;
    }

    // =========================
    // CARGAR ESPECIES
    // =========================

    private static Map<Id, Species__c> loadSpecies(
        Set<Id> speciesIds
    ) {

        if (speciesIds.isEmpty()) {
            return new Map<Id, Species__c>();
        }

        // Validar permiso de lectura antes de ejecutar SOQL (Security: Apex CRUD)
        if (!Schema.sObjectType.Species__c.isAccessible()) {
            // No hay permiso para leer Species__c: devolver mapa vacío para evitar excepción de seguridad
            return new Map<Id, Species__c>();
        }

        return new Map<Id, Species__c>([
            SELECT
                Id,
                Whatering__c,
                Fertilization__c
            FROM Species__c
            WHERE Id IN :speciesIds
        ]);
    }

    // =========================
    // NEXT WATERING DATE
    // =========================

    private static void populateNextWateringDate(
        Plant__c plant,
        Plant__c oldPlant,
        Species__c specie
    ) {

        Boolean wateringChanged =
            oldPlant == null ||
            oldPlant.Last_Watered__c !=
            plant.Last_Watered__c;

        if (!wateringChanged) {
            return;
        }

        if (plant.Last_Watered__c == null) {

            plant.Next_Water__c = null;
            return;
        }

        Integer wateringDays =
            FrecuencyService.getWateringDays(specie);

        plant.Next_Water__c =
            plant.Last_Watered__c
            .addDays(wateringDays);
    }

    // =========================
    // NEXT FERTILIZATION DATE
    // =========================

    private static void populateNextFertilizationDate(
        Plant__c plant,
        Plant__c oldPlant,
        Species__c specie
    ) {

        Boolean fertilizationChanged =
            oldPlant == null ||
            oldPlant.Last_Fertilization__c !=
            plant.Last_Fertilization__c;

        if (!fertilizationChanged) {
            return;
        }

        if (plant.Last_Fertilization__c == null) {

            plant.Next_Fertilization__c = null;
            return;
        }

        Integer fertilizationDays =
            FrecuencyService.getFertilizationDays(specie);

        plant.Next_Fertilization__c =
            plant.Last_Fertilization__c
            .addDays(fertilizationDays);
    }
}