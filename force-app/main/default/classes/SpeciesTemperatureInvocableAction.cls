public with sharing class SpeciesTemperatureInvocableAction {
  @InvocableMethod(
    label='Species Temperature Warning'
    description='Consulta la temperatura actual y devuelve un mensaje para la especie'
  )
  public static List<String> getTemperatureWarning(List<Id> speciesIds) {
    List<String> messages = new List<String>();

    if (speciesIds == null || speciesIds.isEmpty()) {
      return messages;
    }

    Id speciesId = speciesIds[0];

    try {
      Species__c species = [
        SELECT Id, Name, Ideal_Min_Temperature__c, Ideal_Max_Temperature__c
        FROM Species__c
        WHERE Id = :speciesId
        WITH SECURITY_ENFORCED
      ];

      ForecastService.ForecastResponse forecast = ForecastService.getTodayTemperature();

      if (
        forecast == null ||
        forecast.daily == null ||
        forecast.daily.temperature_2m_max == null ||
        forecast.daily.temperature_2m_min == null ||
        forecast.daily.temperature_2m_max.isEmpty() ||
        forecast.daily.temperature_2m_min.isEmpty()
      ) {
        messages.add('No se pudo obtener la temperatura actual.');
        return messages;
      }

      Integer maxTemp = forecast.daily.temperature_2m_max[0].intValue();
      Integer minTemp = forecast.daily.temperature_2m_min[0].intValue();

      String message;
      if (
        species.Ideal_Min_Temperature__c != null &&
        minTemp < species.Ideal_Min_Temperature__c
      ) {
        message = '⚠️ Cuidado: hace más frío del que tu especie tolera.';
      } else if (
        species.Ideal_Max_Temperature__c != null &&
        maxTemp > species.Ideal_Max_Temperature__c
      ) {
        message = '⚠️ Cuidado: hace más calor del que tu especie tolera.';
      } else {
        message = '🌤️ Temperatura óptima para tu nueva especie.';
      }

      messages.add(message);
    } catch (System.QueryException e) {
      messages.add('No tienes permiso para acceder a la especie.');
    } catch (Exception e) {
      messages.add(
        'No se pudo obtener la temperatura actual: ' + e.getMessage()
      );
    }

    return messages;
  }
}
