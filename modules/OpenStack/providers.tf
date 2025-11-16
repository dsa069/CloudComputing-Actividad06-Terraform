provider "openstack" {
# *** YOUR CODE HERE ***
# Configura nombre de usuario, proyecto, contraseña y auth_url 
# con lo definido en variables.tf
# **********************
  user_name   = var.openstack_user_name
  tenant_name = var.openstack_tenant_name
  password    = var.PASSWORD
  auth_url    = var.openstack_auth_url
}

