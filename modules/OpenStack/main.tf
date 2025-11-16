#***CREAMOS NETWORK PARA LA RED DEL PROYECTO EN OPENSTACK***
resource "openstack_networking_network_v2" "actividad06-net" {
  name = "actividad06-net"
}

# Crear router desarrollo-router
data "openstack_networking_network_v2" "public1" {
  name = "public1"
}

resource "openstack_networking_router_v2" "actividad06-router" {
  name                = "actividad06-router"
  admin_state_up      = "true"
  external_network_id = data.openstack_networking_network_v2.public1.id
}

# Conectar el router a la subred
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.actividad06-router.id
}


# Grupos de seguridad ya existentes en OpenStack
data "openstack_networking_secgroup_v2" "ssh" {
  name = "ssh"
}

data "openstack_networking_secgroup_v2" "http" {
  name = "http"
}

resource "openstack_networking_port_v2" "mysql_port" {
  name       = "mysql-port"
  network_id = openstack_networking_network_v2.actividad06-net.id
}

resource "openstack_networking_port_v2" "book_api_port" {
  name       = "book-api-port"
  network_id = openstack_networking_network_v2.actividad06-net.id
}

resource "openstack_networking_port_v2" "book_app_port" {
  name       = "book-app-port"
  network_id = openstack_networking_network_v2.actividad06-net.id
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
  availability_zone = "nova"
  key_pair        = var.openstack_keypair
  security_groups = [data.openstack_networking_secgroup_v2.ssh.name]

  network {
    port = openstack_networking_port_v2.mysql_port.id
  }

  user_data = file("install_mysql.sh")
}

resource "openstack_networking_floatingip_v2" "mysql_fip" {
  pool = "public1"
  port_id = openstack_networking_port_v2.mysql_port.id
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
  availability_zone = "nova"
  key_pair        = var.openstack_keypair
  security_groups = [data.openstack_networking_secgroup_v2.ssh.name, data.openstack_networking_secgroup_v2.http.name]

  network {
    port = openstack_networking_port_v2.book_api_port.id
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
  port_id = openstack_networking_port_v2.book_api_port.id
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
  availability_zone = "nova"
  key_pair        = var.openstack_keypair
  security_groups = [data.openstack_networking_secgroup_v2.ssh.name, data.openstack_networking_secgroup_v2.http.name]

  network {
    port = openstack_networking_port_v2.book_app_port.id
  }

  user_data = data.template_file.setup-app-docker.rendered
}

# *** YOUR CODE HERE ***
# Asignarle una dirección IP flotante
# **********************

resource "openstack_networking_floatingip_v2" "book_app_fip" {
  pool = "public1"
  port_id = openstack_networking_port_v2.book_app_port.id
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