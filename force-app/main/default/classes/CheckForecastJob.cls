public with sharing class CheckForecastJob implements Schedulable {
  public void execute(SchedulableContext sc) {
    System.enqueueJob(new WeatherAlertQueueable());
  }
}
