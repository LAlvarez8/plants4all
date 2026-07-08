import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";

const FIELDS = ["Species__c.Image_URL__c"];

export default class SpeciesDetail extends LightningElement {
  @api recordId;

  isEdit = false;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  record;

  get imageUrl() {
    return this.record?.data?.fields?.Image_URL__c?.value;
  }

  handleEdit() {
    this.isEdit = true;
  }

  handleCancel() {
    this.isEdit = false;
  }

  handleSuccess() {
    this.isEdit = false;
  }
}
