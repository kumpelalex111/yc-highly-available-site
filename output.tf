output "zabbix_nat" {
    value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}
output "zabbix" {
    value = yandex_compute_instance.zabbix.network_interface.0.ip_address
}

output "bastion" {
    value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "web_servers" {
    value = [for instance in yandex_compute_instance.web: instance.network_interface.0.ip_address]
}

output "kibana" {
    value = yandex_compute_instance.elk.network_interface.0.nat_ip_address
}

output "web_address" {
    value = yandex_alb_load_balancer.web-balancer.listener[0].endpoint[0].address[0].external_ipv4_address
}


