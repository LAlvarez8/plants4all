import { LightningElement } from "lwc";
import { getLocationService } from "lightning/mobileCapabilities";

export default class PlantLocation extends LightningElement {
  latitude;
  longitude;
  isLoading = false;
  errorMessage = "";

  async handleGetLocation() {
    this.errorMessage = "";
    this.latitude = null;
    this.longitude = null;

    const locationService = getLocationService();

    if (!locationService || !locationService.isAvailable()) {
      this.errorMessage =
        "La ubicación no está disponible en este dispositivo.";
      return;
    }

    this.isLoading = true;
    try {
      const result = await locationService.getCurrentPosition();
      this.latitude = result.coords.latitude;
      this.longitude = result.coords.longitude;
    } catch (error) {
      this.errorMessage =
        "No se pudo obtener la ubicación: " +
        (error.message || "Error desconocido");
    } finally {
      this.isLoading = false;
    }
  }
}
