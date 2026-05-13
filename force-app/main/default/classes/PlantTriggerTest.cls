@isTest
private with sharing class PlantTriggerTest {

    @isTest
    static void updatePlantNextWateringDateCalculatedCorrectly() {

        // GIVEN
        Species__c aloeVera = new Species__c(
            Name = 'Aloe Vera',
            Whatering__c = 'Low (1 vez por semana)',
            Location__c = 'Indoors'
        );

        insert aloeVera;

        Plant__c plant1 = new Plant__c(
            Species__c = aloeVera.Id,
            Last_Watered__c = System.today(),
            Last_Fertilization__c = System.today()
        );

        // WHEN
        Test.startTest();
        insert plant1;
        Test.stopTest();

        // THEN
        plant1 = [
            SELECT Next_Water__c
            FROM Plant__c
            WHERE Id = :plant1.Id
        ];

        System.assertEquals(
            System.today() + 7,
            plant1.Next_Water__c
        );
    }
}