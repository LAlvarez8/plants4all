public with sharing class PlantService {
  private final FrequencyService frequencyService;
  private final DateService dateService;

  public PlantService() {
    this(new FrequencyService(), new DateService());
  }

  public PlantService(FrequencyService freqService, DateService dtService) {
    this.frequencyService = freqService;
    this.dateService = dtService;
  }

  public void calculateNextWateringDate(List<Plant__c> plants) {
    if (!Schema.sObjectType.Plant__c.fields.Next_Water__c.isUpdateable()) {
      throw new SecurityException(
        'No tienes permiso para editar el campo Next Water Date en Plant__c'
      );
    }

    Map<Id, Species__c> speciesMap = loadSpecies(plants);

    for (Plant__c plant : plants) {
      if (plant.Last_Watered__c == null) {
        plant.Next_Water__c = null;
        continue;
      }

      Species__c sp = speciesMap.get(plant.Species__c);
      if (sp == null) {
        continue;
      }

      // ✅ Usamos el método de instancia (no estático)
      Integer days = frequencyService.calculateWateringDays(sp);
      plant.Next_Water__c = plant.Last_Watered__c.addDays(days);
    }
  }

  public void calculateNextFertilizationDate(List<Plant__c> plants) {
    if (
      !Schema.sObjectType.Plant__c.fields.Next_Fertilization__c.isUpdateable()
    ) {
      throw new SecurityException(
        'No tienes permiso para editar el campo Next Fertilization Date en Plant__c'
      );
    }

    Map<Id, Species__c> speciesMap = loadSpecies(plants);

    for (Plant__c plant : plants) {
      if (plant.Last_Fertilization__c == null) {
        plant.Next_Fertilization__c = null;
        continue;
      }

      Species__c sp = speciesMap.get(plant.Species__c);
      if (sp == null) {
        continue;
      }

      // ✅ Usamos el método de instancia (no estático)
      // Nota: FrequencyService no tiene un método de instancia para fertilización aún.
      // Vamos a crear uno (calculateFertilizationDays).
      // Si no existe, puedes agregarlo en FrequencyService.
      Integer days = frequencyService.calculateFertilizationDays(sp);
      plant.Next_Fertilization__c = plant.Last_Fertilization__c.addDays(days);
    }
  }

  private Map<Id, Species__c> loadSpecies(List<Plant__c> plants) {
    Set<Id> speciesIds = new Set<Id>();
    for (Plant__c p : plants) {
      if (p.Species__c != null) {
        speciesIds.add(p.Species__c);
      }
    }

    if (speciesIds.isEmpty()) {
      return new Map<Id, Species__c>();
    }

    if (!Schema.sObjectType.Species__c.isAccessible()) {
      throw new SecurityException(
        'No tienes permiso para acceder a la especie'
      );
    }

    if (
      !Species__c.Id.getDescribe().isAccessible() ||
      !Species__c.Whatering__c.getDescribe().isAccessible() ||
      !Species__c.Fertilization__c.getDescribe().isAccessible()
    ) {
      throw new SecurityException(
        'No tienes permiso para leer los campos necesarios de Species__c'
      );
    }

    return new Map<Id, Species__c>(
      [
        SELECT Id, Whatering__c, Fertilization__c
        FROM Species__c
        WHERE Id IN :speciesIds
        WITH SECURITY_ENFORCED
      ]
    );
  }
}
