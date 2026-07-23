public with sharing class SpeciesPlantController {
    @AuraEnabled
    public static void createSpeciesAndPlant(Species__c species, Plant__c plant) {
        // Validar permisos CRUD
        if (!Schema.sObjectType.Species__c.isCreateable()) {
            throw new AuraHandledException('No tienes permiso para crear especies');
        }
        if (!Schema.sObjectType.Plant__c.isCreateable()) {
            throw new AuraHandledException('No tienes permiso para crear plantas');
        }

        // Guardar punto de control (Savepoint) para rollback parcial
        Savepoint sp = Database.setSavepoint();

        try {
            // Insertar especie
            insert species;

            // Asignar el ID de la especie a la planta
            plant.Species__c = species.Id;

            // Insertar planta
            insert plant;

        } catch (Exception e) {
            // Si falla la planta, hacer rollback a la especie (la especie se guarda, la planta no)
            Database.rollback(sp);
            throw new AuraHandledException('Error al crear la planta, pero la especie se guardó: ' + e.getMessage());
        }
    }
}