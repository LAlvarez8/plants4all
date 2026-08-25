import { LightningElement, api } from "lwc";

export default class ProcessPlantList extends LightningElement {
  @api selectedIds;

  get ids() {
    if (!this.selectedIds) return [];
    try {
      return JSON.parse(this.selectedIds);
    } catch (e) {
      console.error("Error al parsear selectedIds:", e);
      return [];
    }
  }
}
