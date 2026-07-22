public with sharing class SpeciesService {
    @AuraEnabled(cacheable=true)
    public static List<Species__c> getFilteredSpecies(String searchText) {
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
        if (!Schema.sObjectType.Species__c.isAccessible()) {
            throw new AuraHandledException('No tienes permisos para leer especies');
        }

        if (!Species__c.Id.getDescribe().isAccessible() ||
            !Species__c.Name.getDescribe().isAccessible()) {
            throw new AuraHandledException('No tienes permisos para leer campos de Species');
        }

        if (!Schema.sObjectType.Plant__c.isAccessible()) {
            throw new AuraHandledException('No tienes permisos para leer plantas');
        }

        if (!Plant__c.Id.getDescribe().isAccessible() ||
            !Plant__c.Name.getDescribe().isAccessible()) {
            throw new AuraHandledException('No tienes permisos para leer campos de Plant');
        }

        // NOPMD: La subconsulta está protegida por las validaciones CRUD/FLS anteriores
        return [
            SELECT Id, Name,
                (SELECT Id, Name FROM Plants__r ORDER BY Name)
            FROM Species__c
            ORDER BY Name
        ];
    }
}