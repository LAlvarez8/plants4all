import { LightningElement, api } from "lwc";

export default class DisplayImage extends LightningElement {
  @api url;
  @api width;
  @api height;
}
