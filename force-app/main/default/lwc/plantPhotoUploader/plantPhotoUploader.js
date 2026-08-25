import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import uploadPlantPhoto from "@salesforce/apex/PlantPhotoController.uploadPlantPhoto";

export default class PlantPhotoUploader extends LightningElement {
  @api recordId;

  selectedFile;
  previewUrl;
  isSaving = false;

  handleFileChange(event) {
    const file = event.target.files[0];
    if (!file) return;

    this.selectedFile = file;

    // Leer como Data URL para mostrar vista previa
    const reader = new FileReader();
    reader.onload = () => {
      this.previewUrl = reader.result;
    };
    reader.readAsDataURL(file);
  }

  async handleSave() {
    if (!this.selectedFile) return;

    this.isSaving = true;
    try {
      const base64 = await this.readFileAsBase64(this.selectedFile);
      await uploadPlantPhoto({
        plantId: this.recordId,
        fileName: this.selectedFile.name,
        base64: base64
      });

      this.dispatchEvent(
        new ShowToastEvent({
          title: "Éxito",
          message: "Foto guardada correctamente",
          variant: "success"
        })
      );

      this.selectedFile = null;
      this.previewUrl = null;
      this.template.querySelector("lightning-input").value = "";
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: error.body ? error.body.message : "No se pudo guardar",
          variant: "error"
        })
      );
    } finally {
      this.isSaving = false;
    }
  }

  readFileAsBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        // dataURL = "data:image/jpeg;base64,...."
        const dataUrl = reader.result;
        const base64 = dataUrl.split(",")[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  }
}
