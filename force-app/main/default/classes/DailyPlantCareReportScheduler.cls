public with sharing class DailyPlantCareReportScheduler implements Schedulable {
  public void execute(SchedulableContext context) {
    sendReport();
  }

  private void sendReport() {
    Date today = Date.today();

    // Validación simple de acceso
    if (!Schema.sObjectType.Plant__c.isAccessible()) {
      return;
    }

    // Plantas pendientes de riego
    List<Plant__c> pendingWater = [
      SELECT Id, Name, Species__r.Name, Next_Water__c
      FROM Plant__c
      WHERE Next_Water__c <= :today
      ORDER BY Species__r.Name, Name
    ];

    // Plantas pendientes de fertilización
    List<Plant__c> pendingFertilization = [
      SELECT Id, Name, Species__r.Name, Next_Fertilization__c
      FROM Plant__c
      WHERE Next_Fertilization__c <= :today
      ORDER BY Species__r.Name, Name
    ];

    String body = 'Reporte diario de plantas pendientes\n\n';

    body += '🌿 PENDIENTES DE RIEGO\n';
    if (pendingWater.isEmpty()) {
      body += 'No hay plantas pendientes.\n';
    } else {
      for (Plant__c p : pendingWater) {
        body +=
          '- ' +
          p.Name +
          ' (' +
          p.Species__r.Name +
          ') - ' +
          p.Next_Water__c.format() +
          '\n';
      }
    }

    body += '\n🌱 PENDIENTES DE FERTILIZACIÓN\n';
    if (pendingFertilization.isEmpty()) {
      body += 'No hay plantas pendientes.\n';
    } else {
      for (Plant__c p : pendingFertilization) {
        body +=
          '- ' +
          p.Name +
          ' (' +
          p.Species__r.Name +
          ') - ' +
          p.Next_Fertilization__c.format() +
          '\n';
      }
    }

    String userEmail = UserInfo.getUserEmail();

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new List<String>{ userEmail });
    mail.setSubject('Reporte diario de plantas pendientes');
    mail.setPlainTextBody(body);

    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }
}
