# *** YOUR CODE HERE ***
# Crear instancia denominada mysql conectada a la red del proyecto e inicializada
# con el archivo install_mysql.sh
# Asignarle una dirección IP flotante
# **********************

resource "openstack_networking_floatingip_v2" "mysql_fip" {
  pool = "public"
}

resource "openstack_compute_instance_v2" "mysql" {
  name            = "mysql"
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = var.key_pair
  security_groups = [openstack_compute_secgroup_v2.secgroup.name]

  network {
    name = var.network_name
  }

  user_data = file("install_mysql.sh")
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
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = var.key_pair
  security_groups = [openstack_compute_secgroup_v2.secgroup.name]

  network {
    name = var.network_name
  }

  user_data = data.template_file.setup-api-docker.rendered

  depends_on = [time_sleep.wait_5_minutes ]

}

resource "openstack_networking_floatingip_v2" "book_app_fip" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "book_app_fip" {
  floating_ip = openstack_networking_floatingip_v2.book_app_fip.address
  instance_id = openstack_compute_instance_v2.book_app.id
}

# Configura el archivo de plantilla para la aplicación
data "template_file" "setup-app-docker" {
  template = file("setup-app-docker.tpl")
  vars = {
    book_api_ip = openstack_compute_instance_v2.book_api.network.0.fixed_ip_v4
  }
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
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = var.key_pair
  security_groups = [openstack_compute_secgroup_v2.secgroup.name]

  network {
    name = var.network_name
  }

  user_data = data.template_file.setup-app-docker.rendered
}

# *** YOUR CODE HERE ***
# Asignarle una dirección IP flotante
# **********************

output "mysql_floating_ip" {
  value = openstack_networking_floatingip_v2.mysql_fip.address
}

# *** YOUR CODE HERE ***
# Mostrar las direcciones IP generadas
# **********************

output "book_app_floating_ip" {
  value = openstack_networking_floatingip_v2.book_app_fip.address
}