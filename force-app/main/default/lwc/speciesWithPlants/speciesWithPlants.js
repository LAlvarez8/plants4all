import { LightningElement, wire } from 'lwc';
import getSpeciesWithPlants from '@salesforce/apex/SpeciesService.getSpeciesWithPlants';

export default class SpeciesWithPlants extends LightningElement {
    @wire(getSpeciesWithPlants) speciesWithPlants;

    get loading() {
        return this.speciesWithPlants?.loading;
    }

    get error() {
        return this.speciesWithPlants?.error;
    }
}