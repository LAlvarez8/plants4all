import { LightningElement, wire } from 'lwc';
import getFilterSpecies from "@salesforce/apex/SpeciesService.getFilteredSpecies";

export default class SpeciesList extends LightningElement {

    searchText = '';

    @wire(getFilterSpecies, { searchText: '$searchText' })
    species;

    handleInputChange(event) {

        const searchTextAux = event.target.value;

        if (searchTextAux.length >= 2 || searchTextAux === "") {
            this.searchText = searchTextAux;
        }
    }
}