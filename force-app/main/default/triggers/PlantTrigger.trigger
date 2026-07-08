trigger PlantTrigger on Plant__c(before insert, before update) {
  PlantTriggerHandler.handle();

}
