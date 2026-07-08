import { LightningElement } from "lwc";
import { subscribe, unsubscribe } from "lightning/empApi";

export default class EventSubscriber extends LightningElement {
  subscription = {};
  messages = [];

  subscribe() {
    const channel = "/event/Plant_With_Problems__e";
    const replayId = -1; // -1 para solo eventos nuevos
    const callback = (response) => {
      this.messages.push("Evento recibido: " + JSON.stringify(response.data));
    };
    subscribe(channel, replayId, callback).then((response) => {
      this.subscription = response;
      this.messages.push("Suscrito correctamente");
    });
  }

  unsubscribe() {
    unsubscribe(this.subscription);
    this.messages.push("Desuscrito");
  }
}
