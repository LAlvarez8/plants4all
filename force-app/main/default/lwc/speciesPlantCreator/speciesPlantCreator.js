import { LightningElement, api, track } from 'lwc';
import createSpeciesAndPlant from '@salesforce/apex/SpeciesPlantController.createSpeciesAndPlant';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SpeciesPlantCreator extends LightningElement {
    @api recordId; // ID de la especie desde la que se lanza la acción

    @track speciesName = '';
    @track plantName = '';
    @track acquisitionDate = '';
    @track loading = false;
    @track message = '';
    @track messageClass = '';

    handleSpeciesChange(event) {
        this.speciesName = event.target.value;
    }

    handlePlantNameChange(event) {
        this.plantName = event.target.value;
    }

    handleDateChange(event) {
        this.acquisitionDate = event.target.value;
    }

    handleCreate() {
        if (!this.speciesName) {
            this.showMessage('El nombre de la especie es obligatorio', 'slds-text-color_error');
            return;
        }

        this.loading = true;
        this.message = '';

        createSpeciesAndPlant({
            speciesName: this.speciesName,
            plantName: this.plantName || 'Planta sin nombre',
            lastWatered: this.acquisitionDate || new Date().toISOString().split('T')[0],
            lastFertilization: this.acquisitionDate || new Date().toISOString().split('T')[0]
        })
        .then(() => {
            this.showToast('✅ Éxito', 'Especie y planta creadas correctamente.', 'success');
            this.showMessage('✅ ¡Creado!', 'slds-text-color_success');
            this.loading = false;
            this.closeModal();
        })
        .catch((error) => {
            this.showMessage('❌ Error: ' + error.body.message, 'slds-text-color_error');
            this.loading = false;
        });
    }

    handleCancel() {
        this.closeModal();
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    showMessage(text, className) {
        this.message = text;
        this.messageClass = className;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }
}