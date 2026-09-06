

locals {
    vm_count = 2
    vm_name = [for i in range(local.vm_count): "web${i+1}"]
    zones = ["ru-central1-a", "ru-central1-b"]
    
    web_servers = {
    for name in local.vm_name :
    name => local.zones[index(local.vm_name, name) % length(local.zones)]
    }
    subnet_by_zone = {
    "ru-central1-a" = yandex_vpc_subnet.subnet_web1.id
    "ru-central1-b" = yandex_vpc_subnet.subnet_web2.id
    }
}

resource "yandex_compute_instance" "web" {
    for_each    = local.web_servers
    name        = each.key
    hostname    = each.key
    platform_id = "standard-v1"
    zone        = each.value

    resources {
        cores         = 2
        memory        = 1
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
            type     = "network-hdd"
            size     = 10
        }
    }
    network_interface {
        subnet_id          = local.subnet_by_zone[each.value]
        nat                = false
        security_group_ids = [yandex_vpc_security_group.LAN_sec.id, yandex_vpc_security_group.web_sec.id]
    }

    metadata = {
        user-data          = file("./cloud-init.yml")
        serial-port-enable = 1
    }
    scheduling_policy { preemptible = true }

}

resource "local_file" "inventory" {
    content = <<-EOT
    [bastion]
    ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

    [zabbix]
    ${yandex_compute_instance.zabbix.network_interface.0.ip_address}
    [zabbix:vars]
    ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q alex@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'

    [elastic]
    ${yandex_compute_instance.elk.network_interface.0.ip_address}
    [elastic:vars]
    ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q alex@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'

    [kibana]
    ${yandex_compute_instance.elk.network_interface.0.nat_ip_address}

    [web]
    %{for instance in yandex_compute_instance.web ~}
    ${instance.network_interface.0.ip_address}  
    %{ endfor ~}
    [web:vars]
    ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q alex@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
    EOT
    filename = "/home/alex/yc-highly-available-site/ansible/hosts.ini"
    file_permission = "0644"
}

resource "local_file" "zabbix" {
    content = <<-EOT
    zabbix_ip: ${yandex_compute_instance.zabbix.network_interface.0.ip_address}
    elastic_ip: ${yandex_compute_instance.elk.network_interface.0.ip_address}
    kibana: ${yandex_compute_instance.elk.network_interface.0.nat_ip_address}
    web_hosts:
      %{for instance in yandex_compute_instance.web ~}
      - ${instance.hostname}: ${instance.network_interface.0.ip_address}
      %{ endfor ~}
    elastic_passwd: ""
    EOT
    filename = "/home/alex/yc-highly-available-site/ansible/vars.yml"
    file_permission = "0644"
}
