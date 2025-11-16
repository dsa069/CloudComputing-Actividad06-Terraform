#***CREAMOS NETWORK PARA LA RED DEL PROYECTO EN OPENSTACK***
resource "openstack_networking_network_v2" "actividad06-net" {
  name = "actividad06-net"
}

# Grupos de seguridad ya existentes en OpenStack
data "openstack_networking_secgroup_v2" "ssh" {
  name = "ssh"
}

data "openstack_networking_secgroup_v2" "http" {
  name = "http"
}

# *** YOUR CODE HERE ***
# Crear instancia denominada mysql conectada a la red del proyecto e inicializada
# con el archivo install_mysql.sh
# Asignarle una dirección IP flotante
# **********************

resource "openstack_compute_instance_v2" "mysql" {
  name            = "mysql"
  image_id        = "ubuntu24.04"
  flavor_id       = "m1.medium"
  key_pair        = var.openstack_keypair
  security_groups = [data.openstack_networking_secgroup_v2.ssh.name]

  network {
    name = openstack_networking_network_v2.actividad06-net.id
  }

  user_data = file("install_mysql.sh")
}

resource "openstack_networking_floatingip_v2" "mysql_fip" {
  pool = "public1"
}

resource "openstack_compute_floatingip_associate_v2" "mysql_fip" {
  floating_ip = openstack_networking_floatingip_v2.mysql_fip.address
  instance_id = openstack_compute_instance_v2.mysql.id
}

# Configura el archivo de plantilla para la API
data "template_file" "setup-api-docker" {
  template = file("setup-api-docker.tpl")
  vars = {
    mysql_ip = openstack_compute_instance_v2.mysql.network.0.fixed_ip_v4
  }
  depends_on = [openstack_compute_instance_v2.mysql]
}

# Espera 5 minutos a que se configure la instancia MySQL
# para que no falle el contenedor de la API al conectar a la BD
resource "time_sleep" "wait_5_minutes" {
  depends_on = [openstack_compute_instance_v2.mysql]

  create_duration = "5m"
}

resource "openstack_compute_instance_v2" "book_api" {
# *** YOUR CODE HERE ***
# Configuración de la instancia denominada book_api 
# conectada a la red del proyecto e inicializada 
# con el archivo de la plantilla ya inicializado setup-api-docker
# **********************

  name            = "book_api"
  image_id        = "ubuntu24.04"
  flavor_id       = "m1.medium"
  key_pair        = var.openstack_keypair
  security_groups = [data.openstack_networking_secgroup_v2.ssh.name, data.openstack_networking_secgroup_v2.http.name]

  network {
    name = openstack_networking_network_v2.actividad06-net.id
  }

  user_data = data.template_file.setup-api-docker.rendered

  #Espera a la la mv mysql antes de lanzar la api
  depends_on = [time_sleep.wait_5_minutes ]

}

# *** YOUR CODE HERE ***
# Asignarle una dirección IP flotante
# **********************

resource "openstack_networking_floatingip_v2" "book_api_fip" {
  pool = "public1"
}

resource "openstack_compute_floatingip_associate_v2" "book_api_fip" {
  floating_ip = openstack_networking_floatingip_v2.book_api_fip.address
  instance_id = openstack_compute_instance_v2.book_api.id
}

# Configura el archivo de plantilla para la aplicación
data "template_file" "setup-app-docker" {
  template = file("setup-app-docker.tpl")
  vars = {
    book_api_ip = openstack_compute_instance_v2.book_api.network.0.fixed_ip_v4
  }

  #Espera a la API de libros para crear al app de libros
  depends_on = [openstack_compute_instance_v2.book_api]
}

#Crear nodo APP
resource "openstack_compute_instance_v2" "book_app" {
# *** YOUR CODE HERE ***
# Configuración de la instancia denominada book_app 
# conectada a la red del proyecto e inicializada 
# con el archivo de la aplicación ya inicializado setup-app-docker
# **********************

  name            = "book_app"
  image_id        = "ubuntu24.04"
  flavor_id       = "m1.medium"
  key_pair        = var.openstack_keypair
  security_groups = [data.openstack_networking_secgroup_v2.ssh.name, data.openstack_networking_secgroup_v2.http.name]

  network {
    name = openstack_networking_network_v2.actividad06-net.id
  }

  user_data = data.template_file.setup-app-docker.rendered
}

# *** YOUR CODE HERE ***
# Asignarle una dirección IP flotante
# **********************

resource "openstack_networking_floatingip_v2" "book_app_fip" {
  pool = "public1"
}

resource "openstack_compute_floatingip_associate_v2" "book_app_fip" {
  floating_ip = openstack_networking_floatingip_v2.book_app_fip.address
  instance_id = openstack_compute_instance_v2.book_app.id
}

# *** YOUR CODE HERE ***
# Mostrar las direcciones IP generadas
# **********************

output "mysql_floating_ip" {
  value = openstack_networking_floatingip_v2.mysql_fip.address
  depends_on = [openstack_networking_floatingip_v2.mysql_fip]
}

output "book_api_floating_ip" {
  value = openstack_networking_floatingip_v2.book_api_fip.address
  depends_on = [openstack_networking_floatingip_v2.book_api_fip]
}

output "book_app_floating_ip" {
  value = openstack_networking_floatingip_v2.book_app_fip.address
  depends_on = [openstack_networking_floatingip_v2.book_app_fip]
}