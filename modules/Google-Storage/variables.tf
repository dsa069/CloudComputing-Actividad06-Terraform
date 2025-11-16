# *** YOUR CODE HERE ***
# Definir 3 variables
# * gcp_username inicializada con el nombre de usuario en GCP
# * gcp_project inicializada con el nombre del proyecto en GCP
# * gcp_bucket_name inicializada con el nombre del bucket a crear en Google Storage
# **********************

variable "gcp_username" {
    description = "Nombre de usuario en GCP"
    type        = string
    default     = "dsa069@inlumine.ual.es"
}

variable "gcp_project" {
    description = "ID del proyecto en GCP"
    type        = string
    default     = "cc2025-dsa069"
}

variable "gcp_bucket_name" {
    description = "Nombre del bucket a crear en Google Cloud Storage"
    type        = string
    default     = "dsa069-bucket"
}
