import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class SpeciesTile extends NavigationMixin(LightningElement) {
  @api species;

  handleView() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.species.Id,
        objectApiName: "Species__c",
        actionName: "view"
      }
    });
  }

  get location() {
    return this.species?.Location__c || "";
  }

  get isOutdoors() {
    return this.location.includes("Outdoors");
  }

  get isIndoors() {
    return this.location.includes("Indoors");
  }
}
