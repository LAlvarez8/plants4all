// without sharing porque este Queueable se ejecuta en contexto de sistema
// y debe procesar todas las plantas, sin restricciones de registro.
public without sharing class WeatherAlertQueueable implements Queueable, Database.AllowsCallouts {
  public void execute(QueueableContext context) {
    WeatherAlertService.checkWeather();
  }
}
