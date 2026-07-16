// without sharing porque este job debe procesar todas las plantas del sistema,
// independientemente del usuario que lo ejecute (contexto de sistema).
// Usamos public en lugar de global porque no es necesario exponerlo en un paquete gestionado.
public without sharing class CheckForecastJob implements Schedulable {
  public void execute(SchedulableContext sc) {
    System.enqueueJob(new WeatherAlertQueueable());
  }
}
