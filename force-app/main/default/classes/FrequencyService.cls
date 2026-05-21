public with sharing class FrequencyService {
  private static final Integer DEFAULT_WATERING_DAYS = 7;
  private static final Integer DEFAULT_FERTILIZATION_DAYS = 30;

  private final DateService dateService;

  public FrequencyService() {
    this(new DateService());
  }

  public FrequencyService(DateService dateService) {
    this.dateService = dateService;
  }

  private static final Map<String, Integer> DAYS_BY_WATERING_FREQUENCY = new Map<String, Integer>{
    'Low (1 vez por semana)' => 7,
    'Medium (2-3 veces por semana)' => 3,
    'High (diario)' => 1,
    'Once per week' => 7,
    'Twice per week' => 3,
    'Every day' => 1
  };

  private static final Map<String, Integer> DAYS_BY_FERTILIZATION_FREQUENCY = new Map<String, Integer>{
    'Low (cada mes)' => 30,
    'Medium (cada 2 semanas)' => 14,
    'High (semanal)' => 7
  };

  // =========================
  // MÉTODOS ESTÁTICOS (conveniencia)
  // =========================

  public static Integer getWateringDays(Species__c specie) {
    return new FrequencyService().calculateWateringDays(specie);
  }

  public static Integer getFertilizationDays(Species__c specie) {
    return new FrequencyService().calculateFertilizationDays(specie);
  }

  // =========================
  // MÉTODOS DE INSTANCIA (inyectables para tests)
  // =========================

  public Integer calculateWateringDays(Species__c specie) {
    if (specie == null || String.isBlank(specie.Whatering__c)) {
      return DEFAULT_WATERING_DAYS;
    }

    Integer days = DAYS_BY_WATERING_FREQUENCY.get(specie.Whatering__c);
    if (days == null) {
      return DEFAULT_WATERING_DAYS;
    }

    if (isWinter()) {
      return days;
    }

    return days;
  }

  public Integer calculateFertilizationDays(Species__c specie) {
    if (specie == null || String.isBlank(specie.Fertilization__c)) {
      return DEFAULT_FERTILIZATION_DAYS;
    }

    Integer days = DAYS_BY_FERTILIZATION_FREQUENCY.get(specie.Fertilization__c);
    return (days != null) ? days : DEFAULT_FERTILIZATION_DAYS;
  }

  @TestVisible
  private Boolean isWinter() {
    Integer currentMonth = dateService.getCurrentMonth();
    return (currentMonth == 12 || currentMonth == 1 || currentMonth == 2);
  }
}
