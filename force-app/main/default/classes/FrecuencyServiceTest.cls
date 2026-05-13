@isTest
private class FrecuencyServiceTest {

    @isTest
    static void testGetWateringDaysWithHighFrequency() {

        Species__c specie = new Species__c(
            Whatering__c = 'High (diario)'
        );

        Integer days =
            FrecuencyService.getWateringDays(specie);

        System.assertEquals(1, days, 'Los días de riego deberían ser 1 para frecuencia alta');
    }

    @isTest
    static void testGetWateringDaysWithMediumFrequency() {

        Species__c specie = new Species__c(
            Whatering__c =
                'Medium (2-3 veces por semana)'
        );

        Integer days =
            FrecuencyService.getWateringDays(specie);

        System.assertEquals(3, days, 'Los días de riego deberían ser 3 para frecuencia media');
    }

    @isTest
    static void testGetWateringDaysWithLowFrequency() {

        Species__c specie = new Species__c(
            Whatering__c =
                'Low (1 vez por semana)'
        );

        Integer days =
            FrecuencyService.getWateringDays(specie);

        System.assertEquals(7, days, 'Los días de riego deberían ser 7 para frecuencia baja');
    }

    @isTest
    static void testGetWateringDaysWithNullSpecie() {

        Integer days =
            FrecuencyService.getWateringDays(null);

        System.assertEquals(7, days, 'Los días de riego deberían ser 7 por defecto cuando la especie es null');
    }

    @isTest
    static void testGetFertilizationDaysWithHighFrequency() {

        Species__c specie = new Species__c(
            Fertilization__c =
                'High (semanal)'
        );

        Integer days =
            FrecuencyService.getFertilizationDays(specie);

        System.assertEquals(7, days, 'Los días de fertilización deberían ser 7 para frecuencia alta');
    }

    @isTest
    static void testGetFertilizationDaysWithMediumFrequency() {

        Species__c specie = new Species__c(
            Fertilization__c =
                'Medium (cada 2 semanas)'
        );

        Integer days =
            FrecuencyService.getFertilizationDays(specie);

        System.assertEquals(14, days, 'Los días de fertilización deberían ser 14 para frecuencia media');
    }

    @isTest
    static void testGetFertilizationDaysWithLowFrequency() {

        Species__c specie = new Species__c(
            Fertilization__c =
                'Low (cada mes)'
        );

        Integer days =
            FrecuencyService.getFertilizationDays(specie);

        System.assertEquals(30, days, 'Los días de fertilización deberían ser 30 para frecuencia baja');
    }

    @isTest
    static void testGetFertilizationDaysWithNullSpecie() {

        Integer days =
            FrecuencyService.getFertilizationDays(null);

        System.assertEquals(30, days, 'Los días de fertilización deberían ser 30 por defecto cuando la especie es null');
    }
}