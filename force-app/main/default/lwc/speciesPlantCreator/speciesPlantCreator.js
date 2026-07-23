import { LightningElement, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Importar los nombres de campos
import SPECIES_NAME_FIELD from '@salesforce/schema/Species__c.Name';
import PLANT_NAME_FIELD from '@salesforce/schema/Plant__c.Name';
import PLANT_SPECIES_FIELD from '@salesforce/schema/Plant__c.Species__c';
import PLANT_LAST_WATERED_FIELD from '@salesforce/schema/Plant__c.Last_Watered__c';
import PLANT_LAST_FERTILIZATION_FIELD from '@salesforce/schema/Plant__c.Last_Fertilization__c';

export default class SpeciesPlantCreator extends LightningElement {
    @track speciesId = null;
    @track message = '';
    @track messageClass = '';
    @track loading = false;

    // Campos para el formulario de Species
    speciesFields = [SPECIES_NAME_FIELD];

    // Campos para el formulario de Plant
    plantFields = [
        PLANT_NAME_FIELD,
        PLANT_SPECIES_FIELD,
        PLANT_LAST_WATERED_FIELD,
        PLANT_LAST_FERTILIZATION_FIELD
    ];

    // Crear especie usando LDS
    createSpecies() {
        this.loading = true;
        this.message = '';
        this.messageClass = '';

        // Obtener el formulario de Species
        const speciesForm = this.template.querySelector('lightning-record-form[object-api-name="Species__c"]');
        
        // Crear el registro usando LDS
        createRecord({
            apiName: 'Species__c',
            fields: {
                Name: speciesForm.fields?.Name
            }
        })
        .then((result) => {
            this.speciesId = result.id;
            this.showMessage('✅ Especie creada correctamente. Ahora crea la planta.', 'slds-text-color_success');
            this.loading = false;
        })
        .catch((error) => {
            this.showMessage('❌ Error al crear la especie: ' + error.body.message, 'slds-text-color_error');
            this.loading = false;
        });
    }

    // Crear planta asociada a la especie usando LDS
    createPlant() {
        this.loading = true;
        this.message = '';
        this.messageClass = '';

        // Obtener el formulario de Plant
        const plantForm = this.template.querySelector('lightning-record-form[object-api-name="Plant__c"]');

        // Crear el registro usando LDS
        createRecord({
            apiName: 'Plant__c',
            fields: {
                Name: plantForm.fields?.Name || 'Planta sin nombre',
                Species__c: this.speciesId,
                Last_Watered__c: plantForm.fields?.Last_Watered__c || new Date().toISOString().split('T')[0],
                Last_Fertilization__c: plantForm.fields?.Last_Fertilization__c || new Date().toISOString().split('T')[0]
            }
        })
        .then(() => {
            this.showToast('✅ Éxito', 'Planta y especie creadas correctamente.', 'success');
            this.showMessage('✅ ¡Planta creada correctamente! Especie y planta registradas.', 'slds-text-color_success');
            this.loading = false;
            // Reiniciar el formulario
            this.resetForm();
        })
        .catch((error) => {
            this.showMessage('❌ Error al crear la planta: ' + error.body.message, 'slds-text-color_error');
            this.loading = false;
        });
    }

    // Cancelar y cerrar el pop-up
    handleCancel() {
        this.resetForm();
        // Cerrar el pop-up (si está en un Quick Action)
        this.dispatchEvent(new CustomEvent('close'));
    }

    // Resetear todos los campos
    resetForm() {
        this.speciesId = null;
        this.message = '';
        this.messageClass = '';
        this.loading = false;
        const forms = this.template.querySelectorAll('lightning-record-form');
        forms.forEach(form => form.reset());
    }

    // Mostrar mensaje en el componente
    showMessage(text, className) {
        this.message = text;
        this.messageClass = className;
        this.loading = false;
    }

    // Mostrar toast (notificación)
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Manejadores de éxito para LDS
    handleSpeciesSuccess(event) {
        this.speciesId = event.detail.id;
        this.showMessage('✅ Especie creada correctamente. Ahora crea la planta.', 'slds-text-color_success');
        this.loading = false;
    }

    handlePlantSuccess() {
        this.showToast('✅ Éxito', 'Planta creada correctamente.', 'success');
        this.showMessage('✅ ¡Planta creada correctamente! Especie y planta registradas.', 'slds-text-color_success');
        this.loading = false;
        this.resetForm();
    }

    handleError(event) {
        this.showMessage('❌ Error: ' + event.detail.message, 'slds-text-color_error');
        this.loading = false;
    }
}