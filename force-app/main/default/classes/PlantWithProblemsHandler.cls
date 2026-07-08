public with sharing class PlantWithProblemsHandler {
  public static void processEvents(List<Plant_With_Problems__e> events) {
    Savepoint sp = Database.setSavepoint();

    try {
      // 1. Recolectar todos los IDs de planta
      Set<Id> plantIds = new Set<Id>();
      for (Plant_With_Problems__e evt : events) {
        if (evt.Plant_Id__c != null) {
          plantIds.add(evt.Plant_Id__c);
        }
      }

      // 2. Validar permisos CRUD antes de la consulta
      if (!Schema.sObjectType.Plant__c.isAccessible()) {
        System.debug('⚠️ El usuario no tiene permisos para leer Plant__c');
        return;
      }

      // 3. Consulta en lote (solo campos necesarios)
      Map<Id, Plant__c> plantsMap = new Map<Id, Plant__c>(
        [
          SELECT Id, Name
          FROM Plant__c
          WHERE Id IN :plantIds
        ]
      );

      // 4. Procesar eventos (solo logs, sin actualización de campo)
      for (Plant_With_Problems__e evt : events) {
        Plant__c plant = plantsMap.get(evt.Plant_Id__c);
        if (plant != null) {
          System.debug('✅ Planta encontrada: ' + plant.Name);
        } else {
          System.debug('⚠️ Planta no encontrada: ' + evt.Plant_Id__c);
        }
      }

      // No hay actualizaciones pendientes, todo está bien
    } catch (Exception e) {
      System.debug('❌ Error procesando eventos: ' + e.getMessage());
      Database.rollback(sp);
    }
  }
}
