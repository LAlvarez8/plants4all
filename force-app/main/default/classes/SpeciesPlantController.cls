public with sharing class SpeciesPlantController {
    @AuraEnabled
    public static void createSpeciesAndPlant(Species__c species, Plant__c plant) {
        // 1. Validar permisos CRUD
        if (!Schema.sObjectType.Species__c.isCreateable()) {
            throw new AuraHandledException('No tienes permiso para crear especies');
        }
        if (!Schema.sObjectType.Plant__c.isCreateable()) {
            throw new AuraHandledException('No tienes permiso para crear plantas');
        }

        // 2. Guardar punto de control (Savepoint)
        Savepoint sp = Database.setSavepoint();

        try {
            // 3. Insertar la especie
            insert species;

            // 4. Asignar el ID de la especie a la planta
            plant.Species__c = species.Id;

            // 5. Insertar la planta
            insert plant;

        } catch (Exception e) {
            // 6. Si falla la planta, hacer rollback a la especie (la especie se guarda, la planta no)
            Database.rollback(sp);
            throw new AuraHandledException('Error al crear la planta, pero la especie se guardó: ' + e.getMessage());
        }
    }
}