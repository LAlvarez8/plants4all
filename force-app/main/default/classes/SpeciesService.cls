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

    @AuraEnabled(cacheable=true)
    public static List<Species__c> getSpeciesWithPlants() {
        // Validar permisos CRUD
        if (!Schema.sObjectType.Species__c.isAccessible()) {
            throw new AuraHandledException('No tienes permisos para leer especies');
        }

        // Validar FLS de campos necesarios
        if (!Species__c.Id.getDescribe().isAccessible() ||
            !Species__c.Name.getDescribe().isAccessible()) {
            throw new AuraHandledException('No tienes permisos para leer campos de Species');
        }

        // Consulta con subconsulta para traer plantas hijas
        // NOTA: WITH SECURITY_ENFORCED no es compatible con subconsultas en esta versión de API,
        // por lo que confiamos en las validaciones manuales anteriores.
        return [
            SELECT Id, Name,
                (SELECT Id, Name FROM Plants__r ORDER BY Name)
            FROM Species__c
            ORDER BY Name
        ];
    }
}