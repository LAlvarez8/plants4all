trigger PlantWithProblemsTrigger on Plant_With_Problems__e(after insert) {
  // Solo delega al handler
  PlantWithProblemsHandler.processEvents(Trigger.new);
}
