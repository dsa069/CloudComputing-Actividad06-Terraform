# *** YOUR CODE HERE ***
# Crear un recurso google_storage_bucket para almacenar imágenes en Google Storage
#
# Crear en el bucket anteior dos recursos google_storage_bucket_object
# (uno para cada imagen de la carpeta ./images)
# Configurar la propiedad source desde la raíz del proyecto (./images/<imagen.jpg>)
#
# Definir una regla de acceso para objeto creado de forma que sea público 
# Configurar google_storage_object_access_control así
#   role   = "READER"
#   entity = "allUsers"
# **********************  

# Recurso para crear el bucket de Google Storage
resource "google_storage_bucket" "images_bucket" {
    name     = var.gcp_bucket_name   # Nombre del bucket, cambiar según necesidad
    location = "US"                # Ubicación del bucket
}

# Recurso para subir la primera imagen al bucket
resource "google_storage_bucket_object" "image1" {
    name   = "enigma.jpg"                                       # Nombre del objeto en el bucket
    bucket = google_storage_bucket.images_bucket.name
    source = "./images/el_enigma_de_la_habitacion_622.jpg"    # Ruta a la imagen desde la raíz del proyecto
}

# Recurso para subir la segunda imagen al bucket
resource "google_storage_bucket_object" "image2" {
    name   = "historia.jpg"                                  # Nombre del objeto en el bucket
    bucket = google_storage_bucket.images_bucket.name
    source = "./images/una_historia_de_espana.jpg"           # Ruta a la imagen desde la raíz del proyecto
}

# Regla de acceso público para la primera imagen
resource "google_storage_object_access_control" "image1_public" {
    object = google_storage_bucket_object.image1.output_name        # Nombre del objeto
    bucket = google_storage_bucket.images_bucket.name               # Nombre del recurso bucket
    role   = "READER"
    entity = "allUsers"
}

# Regla de acceso público para la segunda imagen
resource "google_storage_object_access_control" "image2_public" {
    object = google_storage_bucket_object.image2.output_name
    bucket = google_storage_bucket.images_bucket.name
    role   = "READER"
    entity = "allUsers"
}
