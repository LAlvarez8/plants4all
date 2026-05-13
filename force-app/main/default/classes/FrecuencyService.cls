public with sharing class FrecuencyService {

    // =========================
    // MAPA DE RIEGO
    // =========================

    private static final Map<String, Integer>
        DAYS_BY_WATERING_FRECUENCY =
            new Map<String, Integer>{

        'Low (1 vez por semana)' => 7,
        'Medium (2-3 veces por semana)' => 3,
        'High (diario)' => 1
    };

    // =========================
    // MAPA DE FERTILIZACIÓN
    // =========================

    private static final Map<String, Integer>
        DAYS_BY_FERTILIZATION_FRECUENCY =
            new Map<String, Integer>{

        'Low (cada mes)' => 30,
        'Medium (cada 2 semanas)' => 14,
        'High (semanal)' => 7
    };

    // =========================
    // OBTENER DÍAS DE RIEGO
    // =========================

    public static Integer getWateringDays(
        Species__c specie
    ) {

        if (
            specie == null ||
            specie.Whatering__c == null
        ) {

            return 7;
        }

        Integer days =
            DAYS_BY_WATERING_FRECUENCY.get(
                specie.Whatering__c
            );

        return days != null ? days : 7;
    }

    // =========================
    // OBTENER DÍAS DE FERTILIZACIÓN
    // =========================

    public static Integer getFertilizationDays(
        Species__c specie
    ) {

        if (
            specie == null ||
            specie.Fertilization__c == null
        ) {

            return 30;
        }

        Integer days =
            DAYS_BY_FERTILIZATION_FRECUENCY.get(
                specie.Fertilization__c
            );

        return days != null ? days : 30;
    }
}