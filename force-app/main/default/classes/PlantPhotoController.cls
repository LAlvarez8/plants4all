public with sharing class PlantPhotoController {
  @AuraEnabled
  public static void uploadPlantPhoto(
    Id plantId,
    String fileName,
    String base64
  ) {
    if (String.isBlank(base64)) {
      throw new AuraHandledException('No se pudo leer la imagen');
    }

    // Permiso de creación sobre ContentVersion
    if (!Schema.sObjectType.ContentVersion.isCreateable()) {
      throw new AuraHandledException('No tienes permisos para subir archivos');
    }

    // Crear ContentVersion
    ContentVersion cv = new ContentVersion();
    cv.ContentLocation = 'S';
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = fileName;
    cv.PathOnClient = fileName;

    insert cv;

    // Permiso de lectura sobre ContentVersion
    if (!Schema.sObjectType.ContentVersion.isAccessible()) {
      throw new AuraHandledException(
        'No tienes permisos para consultar el archivo'
      );
    }

    // Obtener el ContentDocumentId
    ContentVersion insertedCv = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
      LIMIT 1
    ];

    // Permiso de creación sobre ContentDocumentLink
    if (!Schema.sObjectType.ContentDocumentLink.isCreateable()) {
      throw new AuraHandledException(
        'No tienes permisos para vincular el archivo con la planta'
      );
    }

    // Vincular la foto a la planta
    ContentDocumentLink link = new ContentDocumentLink();
    link.ContentDocumentId = insertedCv.ContentDocumentId;
    link.LinkedEntityId = plantId;
    link.ShareType = 'V';

    insert link;
  }
}
