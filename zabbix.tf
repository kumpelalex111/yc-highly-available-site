resource "yandex_compute_instance" "zabbix" {
    name        = "zabbix"
    hostname    = "zabbix"
    platform_id = "standard-v1"
    zone        =  "ru-central1-a"
    resources {
        cores  = 2
        memory = 2
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
            type = "network-hdd"
            size = 10
        }
    }
    network_interface {
        subnet_id = yandex_vpc_subnet.subnet_web1.id
        nat       = true
        security_group_ids = [yandex_vpc_security_group.LAN_sec.id, yandex_vpc_security_group.zabbix_sec.id]
    }

    metadata = {
        user-data = file("./cloud-init.yml")
        serial-port-enable = 1
    }
    scheduling_policy { preemptible = true }
}
