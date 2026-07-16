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

  // ─── CALCULAR PRÓXIMA FECHA DE RIEGO ────────────────────────────────────────
  public void calculateNextWateringDate(List<Plant__c> plants) {
    // 1. Validar permisos de actualización del objeto Plant__c (CRUD)
    if (!Schema.sObjectType.Plant__c.isUpdateable()) {
      throw new SecurityException(
        'No tienes permiso para actualizar registros de Plant__c'
      );
    }

    // 2. Validar permisos de actualización del campo específico (FLS)
    if (!Schema.sObjectType.Plant__c.fields.Next_Water__c.isUpdateable()) {
      throw new SecurityException(
        'No tienes permiso para editar el campo Next Water Date en Plant__c'
      );
    }

    // 3. Cargar especies relacionadas (con validación interna)
    Map<Id, Species__c> speciesMap = loadSpecies(plants);

    // 4. Procesar cada planta
    for (Plant__c plant : plants) {
      if (plant.Last_Watered__c == null) {
        plant.Next_Water__c = null;
        continue;
      }

      Species__c sp = speciesMap.get(plant.Species__c);
      if (sp == null) {
        continue;
      }

      Integer days = frequencyService.calculateWateringDays(sp);
      plant.Next_Water__c = plant.Last_Watered__c.addDays(days);
    }
  }

  // ─── CALCULAR PRÓXIMA FECHA DE FERTILIZACIÓN ──────────────────────────────
  public void calculateNextFertilizationDate(List<Plant__c> plants) {
    // 1. Validar permisos de actualización del objeto Plant__c (CRUD)
    if (!Schema.sObjectType.Plant__c.isUpdateable()) {
      throw new SecurityException(
        'No tienes permiso para actualizar registros de Plant__c'
      );
    }

    // 2. Validar permisos de actualización del campo específico (FLS)
    if (
      !Schema.sObjectType.Plant__c.fields.Next_Fertilization__c.isUpdateable()
    ) {
      throw new SecurityException(
        'No tienes permiso para editar el campo Next Fertilization Date en Plant__c'
      );
    }

    // 3. Cargar especies relacionadas (con validación interna)
    Map<Id, Species__c> speciesMap = loadSpecies(plants);

    // 4. Procesar cada planta
    for (Plant__c plant : plants) {
      if (plant.Last_Fertilization__c == null) {
        plant.Next_Fertilization__c = null;
        continue;
      }

      Species__c sp = speciesMap.get(plant.Species__c);
      if (sp == null) {
        continue;
      }

      Integer days = frequencyService.calculateFertilizationDays(sp);
      plant.Next_Fertilization__c = plant.Last_Fertilization__c.addDays(days);
    }
  }

  // ─── CARGAR ESPECIES (con validación CRUD/FLS y WITH SECURITY_ENFORCED) ──
  private Map<Id, Species__c> loadSpecies(List<Plant__c> plants) {
    // Recolectar IDs de especies
    Set<Id> speciesIds = new Set<Id>();
    for (Plant__c p : plants) {
      if (p.Species__c != null) {
        speciesIds.add(p.Species__c);
      }
    }

    if (speciesIds.isEmpty()) {
      return new Map<Id, Species__c>();
    }

    // 1. Validar acceso al objeto Species__c (CRUD)
    if (!Schema.sObjectType.Species__c.isAccessible()) {
      throw new SecurityException(
        'No tienes permiso para acceder a la especie'
      );
    }

    // 2. Validar acceso a los campos necesarios (FLS)
    if (
      !Species__c.Id.getDescribe().isAccessible() ||
      !Species__c.Whatering__c.getDescribe().isAccessible() ||
      !Species__c.Fertilization__c.getDescribe().isAccessible()
    ) {
      throw new SecurityException(
        'No tienes permiso para leer los campos necesarios de Species__c'
      );
    }

    // 3. Consulta con WITH SECURITY_ENFORCED (valida FLS a nivel de consulta)
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
