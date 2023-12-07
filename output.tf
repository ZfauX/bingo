output "instance_external_ip_app" {
  value = yandex_compute_instance_group.app.instances.*.network_interface.0.nat_ip_address
}
output "instance_external_ip_db" {
  value = yandex_compute_instance_group.db.instances.*.network_interface.0.nat_ip_address
}
