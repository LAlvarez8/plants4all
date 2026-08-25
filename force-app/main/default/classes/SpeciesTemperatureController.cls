public with sharing class SpeciesTemperatureController {
  // Clase de entrada para la acción invocable
  public class FlowInput {
    @InvocableVariable(label='Location' required=true)
    public String location;
  }

  // Clase de salida para la acción invocable
  public class FlowOutput {
    @InvocableVariable(label='Temperature Status')
    public String temperatureStatus;
  }

  // Método invocable
  @InvocableMethod(
    label='Get Temperature Status'
    description='Devuelve un mensaje con la temperatura para la especie'
  )
  public static List<FlowOutput> getTemperatureStatus(List<FlowInput> inputs) {
    List<FlowOutput> outputs = new List<FlowOutput>();

    for (FlowInput input : inputs) {
      FlowOutput out = new FlowOutput();
      out.temperatureStatus = buildStatus(input.location);
      outputs.add(out);
    }
    return outputs;
  }

  // Método auxiliar que genera un mensaje simulado
  private static String buildStatus(String location) {
    String cleanLocation = (location != null &&
      location != '')
      ? location
      : 'desconocida';
    Integer temp = Math.mod(Math.abs(cleanLocation.hashCode()), 15) + 10; // entre 10 y 24 grados
    return 'Temperatura actual en ' +
      cleanLocation +
      ': ' +
      temp +
      '°C. ' +
      (temp >= 15 &&
        temp <= 25
        ? '🌿 La temperatura es adecuada para la especie.'
        : '⚠️ La temperatura podría no ser ideal para la especie.');
  }
}
