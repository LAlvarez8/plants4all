import { LightningElement, track } from 'lwc';
import createSpeciesAndPlant from '@salesforce/apex/SpeciesPlantController.createSpeciesAndPlant';

export default class SpeciesPlantCreator extends LightningElement {
    @track species = {
        Name: '',
        Whatering__c: '',
        Fertilization__c: '',
        Location__c: '',
        Locationes__c: ''
    };
    @track plant = {
        Last_Watered__c: '',
        Last_Fertilization__c: ''
    };
    @track loading = false;
    @track message = '';
    @track messageClass = '';

    handleSpeciesChange(event) {
        const field = event.target.dataset.field;
        this.species[field] = event.target.value;
    }

    handlePlantChange(event) {
        const field = event.target.dataset.field;
        this.plant[field] = event.target.value;
    }

    handleCreate() {
        if (!this.species.Name) {
            this.showMessage('El nombre de la especie es obligatorio', 'slds-text-color_error');
            return;
        }
        if (!this.plant.Last_Watered__c) {
            this.showMessage('La fecha de último riego es obligatoria', 'slds-text-color_error');
            return;
        }
        if (!this.plant.Last_Fertilization__c) {
            this.showMessage('La fecha de última fertilización es obligatoria', 'slds-text-color_error');
            return;
        }

        this.loading = true;
        this.message = '';
        this.messageClass = '';

        const speciesRecord = { ...this.species };
        const plantRecord = { ...this.plant };
        plantRecord.Last_Watered__c = new Date(plantRecord.Last_Watered__c);
        plantRecord.Last_Fertilization__c = new Date(plantRecord.Last_Fertilization__c);

        createSpeciesAndPlant({ species: speciesRecord, plant: plantRecord })
            .then(() => {
                this.showMessage('✅ ¡Especie y planta creadas exitosamente!', 'slds-text-color_success');
                this.handleClear();
            })
            .catch((error) => {
                const errorMsg = error.body?.message || error.message || 'Error al crear los registros';
                this.showMessage('❌ ' + errorMsg, 'slds-text-color_error');
            })
            .finally(() => {
                this.loading = false;
            });
    }

    handleClear() {
        this.species = { Name: '', Whatering__c: '', Fertilization__c: '', Location__c: '', Locationes__c: '' };
        this.plant = { Last_Watered__c: '', Last_Fertilization__c: '' };
        this.message = '';
        this.messageClass = '';
    }

    showMessage(text, className) {
        this.message = text;
        this.messageClass = className;
    }
}