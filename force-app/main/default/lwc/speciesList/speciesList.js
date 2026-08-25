import { LightningElement, wire } from "lwc";
import getFilterSpecies from "@salesforce/apex/SpeciesService.getFilteredSpecies";
import FORM_FACTOR from "@salesforce/client/formFactor";

export default class SpeciesList extends LightningElement {
  searchText = "";
  formFactor = FORM_FACTOR;

  @wire(getFilterSpecies, {
    searchText: "$searchText"
  })
  species;

  get isMobile() {
    return this.formFactor === "Small";
  }

  get isTablet() {
    return this.formFactor === "Medium";
  }

  get isDesktop() {
    return this.formFactor === "Large";
  }

  get containerClass() {
    return this.isMobile ? "container mobile-container" : "container";
  }

  get searchWrapperClass() {
    return this.isMobile
      ? "search-wrapper mobile-search-wrapper"
      : "search-wrapper";
  }

  get inputLabel() {
    return this.isMobile ? "Buscar especie" : "Enter some text";
  }

  handleInputChange(event) {
    const searchTextAux = event.target.value.trim();

    if (searchTextAux.length >= 2 || searchTextAux === "") {
      this.searchText = searchTextAux;
    }
  }
}
