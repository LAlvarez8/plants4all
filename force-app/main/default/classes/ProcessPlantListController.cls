public with sharing class ProcessPlantListController {
  public String selectedIds { get; set; }

  public ProcessPlantListController(
    ApexPages.StandardSetController controller
  ) {
    List<Plant__c> selectedPlants = (List<Plant__c>) controller.getSelected();
    List<String> ids = new List<String>();
    for (Plant__c plant : selectedPlants) {
      ids.add(plant.Id);
    }
    selectedIds = JSON.serialize(ids);
  }
}
