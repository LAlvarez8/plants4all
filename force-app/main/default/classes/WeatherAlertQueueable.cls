public with sharing class WeatherAlertQueueable implements Queueable, Database.AllowsCallouts {
  public void execute(QueueableContext context) {
    WeatherAlertService.checkWeather();
  }
}
