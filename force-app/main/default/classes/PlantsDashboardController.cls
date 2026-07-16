public with sharing class PlantsDashboardController {
  public class ChartRow {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public Integer value { get; set; }

    public ChartRow(String label, Integer value) {
      this.label = String.isBlank(label) ? 'Sin dato' : label;
      this.value = value == null ? 0 : value;
    }
  }

  public class DashboardData {
    @AuraEnabled
    public List<ChartRow> plantsBySpecies { get; set; }
    @AuraEnabled
    public List<ChartRow> pendingFertilization { get; set; }
    @AuraEnabled
    public List<ChartRow> plantsByOwner { get; set; }
    @AuraEnabled
    public List<ChartRow> pendingWatering { get; set; }
    @AuraEnabled
    public Datetime generatedAt { get; set; }
  }

  @AuraEnabled(cacheable=true)
  public static DashboardData getDashboardData() {
    // Validar acceso al objeto Plant__c (CRUD)
    if (!Schema.sObjectType.Plant__c.isAccessible()) {
      throw new AuraHandledException(
        'No tienes permisos para leer registros de Plant__c'
      );
    }

    DashboardData data = new DashboardData();
    data.plantsBySpecies = getPlantsBySpecies();
    data.pendingFertilization = getPendingFertilization();
    data.plantsByOwner = getPlantsByOwner();
    data.pendingWatering = getPendingWatering();
    data.generatedAt = System.now();
    return data;
  }

  private static List<ChartRow> getPlantsBySpecies() {
    // Validar acceso al campo Species__r.Name (FLS)
    if (!Schema.sObjectType.Species__c.fields.Name.isAccessible()) {
      return new List<ChartRow>();
    }

    List<ChartRow> rows = new List<ChartRow>();
    for (AggregateResult result : [
      SELECT Species__r.Name speciesName, COUNT(Id) total
      FROM Plant__c
      WHERE Species__c != NULL
      GROUP BY Species__r.Name
      ORDER BY Species__r.Name
    ]) {
      rows.add(
        new ChartRow(
          (String) result.get('speciesName'),
          (Integer) result.get('total')
        )
      );
    }
    return rows;
  }

  private static List<ChartRow> getPendingFertilization() {
    // Validar acceso al campo Species__r.Name (FLS)
    if (!Schema.sObjectType.Species__c.fields.Name.isAccessible()) {
      return new List<ChartRow>();
    }

    List<ChartRow> rows = new List<ChartRow>();
    Date today = Date.today();
    for (AggregateResult result : [
      SELECT Species__r.Name speciesName, COUNT(Id) total
      FROM Plant__c
      WHERE Species__c != NULL AND Next_Fertilization__c <= :today
      GROUP BY Species__r.Name
      ORDER BY Species__r.Name
    ]) {
      rows.add(
        new ChartRow(
          (String) result.get('speciesName'),
          (Integer) result.get('total')
        )
      );
    }
    return rows;
  }

  private static List<ChartRow> getPlantsByOwner() {
    // Validar acceso al campo Owner.Name (FLS)
    if (!Schema.sObjectType.Plant__c.fields.OwnerId.isAccessible()) {
      return new List<ChartRow>();
    }

    List<ChartRow> rows = new List<ChartRow>();
    for (AggregateResult result : [
      SELECT Owner.Name ownerName, COUNT(Id) total
      FROM Plant__c
      GROUP BY Owner.Name
      ORDER BY Owner.Name
    ]) {
      rows.add(
        new ChartRow(
          (String) result.get('ownerName'),
          (Integer) result.get('total')
        )
      );
    }
    return rows;
  }

  private static List<ChartRow> getPendingWatering() {
    // Validar acceso al campo Species__r.Name (FLS)
    if (!Schema.sObjectType.Species__c.fields.Name.isAccessible()) {
      return new List<ChartRow>();
    }

    List<ChartRow> rows = new List<ChartRow>();
    Date today = Date.today();
    for (AggregateResult result : [
      SELECT Species__r.Name speciesName, COUNT(Id) total
      FROM Plant__c
      WHERE Species__c != NULL AND Next_Water__c <= :today
      GROUP BY Species__r.Name
      ORDER BY Species__r.Name
    ]) {
      rows.add(
        new ChartRow(
          (String) result.get('speciesName'),
          (Integer) result.get('total')
        )
      );
    }
    return rows;
  }
}
