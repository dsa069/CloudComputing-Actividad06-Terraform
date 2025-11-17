module "Google-Storage" {
  source              = "./modules/Google-Storage"
}

module "OpenStack" {
  source   = "./modules/OpenStack"
  PASSWORD = var.PASSWORD
}

# Para que se muestren las IPs asignadas a las instancias de OpenStack por consola
output "mysql_floating_ip" {
  value = module.OpenStack.mysql_floating_ip
}

output "book_api_floating_ip" {
  value = module.OpenStack.book_api_floating_ip
}

output "book_app_floating_ip" {
  value = module.OpenStack.book_app_floating_ip
}