public with sharing class SpeciesService {
    // Clase wrapper para devolver especie con sus plantas
    public class SpeciesWithPlantsWrapper {
        @AuraEnabled
        public Species__c species { get; set; }
        @AuraEnabled
        public List<Plant__c> plants { get; set; }
    }

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
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<SpeciesWithPlantsWrapper> getSpeciesWithPlants() {
        if (!Schema.sObjectType.Species__c.isAccessible()) {
            throw new AuraHandledException('No tienes permisos para leer especies');
        }

        // Obtener todas las especies
        List<Species__c> speciesList = [
            SELECT Id, Name
            FROM Species__c
            ORDER BY Name
        ];

        if (speciesList.isEmpty()) {
            return new List<SpeciesWithPlantsWrapper>();
        }

        Set<Id> speciesIds = new Map<Id, Species__c>(speciesList).keySet();

        if (!Schema.sObjectType.Plant__c.isAccessible()) {
            throw new AuraHandledException('No tienes permisos para leer plantas');
        }

        // Obtener todas las plantas relacionadas
        List<Plant__c> allPlants = [
            SELECT Id, Name, Species__c
            FROM Plant__c
            WHERE Species__c IN :speciesIds
            ORDER BY Name
        ];

        // Crear mapa de especies → lista de plantas
        Map<Id, List<Plant__c>> plantsBySpecies = new Map<Id, List<Plant__c>>();
        for (Plant__c plant : allPlants) {
            if (!plantsBySpecies.containsKey(plant.Species__c)) {
                plantsBySpecies.put(plant.Species__c, new List<Plant__c>());
            }
            plantsBySpecies.get(plant.Species__c).add(plant);
        }

        // Construir la lista de wrappers
        List<SpeciesWithPlantsWrapper> result = new List<SpeciesWithPlantsWrapper>();
        for (Species__c species : speciesList) {
            SpeciesWithPlantsWrapper wrapper = new SpeciesWithPlantsWrapper();
            wrapper.species = species;
            wrapper.plants = plantsBySpecies.get(species.Id) != null 
                ? plantsBySpecies.get(species.Id) 
                : new List<Plant__c>();
            result.add(wrapper);
        }

        return result;
    }
}