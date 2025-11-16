#Creamos un nuevo archivo variables.tf en root, ya que en la carpeta del modulo OpenStack
# al definir la variable contraseña no me la reconoce la las variables de entorno Windows
#Tampoco quiero poner la contraseña en texto plano

variable "PASSWORD" {
    description = "The password to connect to OpenStack."
}