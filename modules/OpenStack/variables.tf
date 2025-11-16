# *** YOUR CODE HERE ***
# Definir estas 4 variables
# * openstack_user_name inicializada con el nombre de usuario en OpenStack
# * openstack_tenant_name inicializada con el nombre del proyecto en OpenStack
# * openstack_password inicializada con la contraseña en OpenStack????
# * openstack_keypair: Nombre del archivo de claves en OpenStack

variable "openstack_user_name" {
    description = "The username to connect to OpenStack."
    default     = "dsa069-MII"
}

variable "openstack_tenant_name" {
    description = "The project name in OpenStack."
    default     = "dsa069-MII"
}

variable "PASSWORD" {
    description = "The password to connect to OpenStack."
}

variable "openstack_keypair" {
    description = "The name of the keypair file in OpenStack."
    default     = "miclave"
}

variable "openstack_auth_url" {
    description = "The endpoint url to connect to OpenStack."
    default  = "http://192.168.64.50:5000/v3"
}


