resource "yandex_compute_instance" "elk" {
    name        = "elk"
    hostname    = "elk"
    platform_id = "standard-v1"
    zone        = "ru-central1-a"
    resources {
        cores  = 4
        memory = 10
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
            type = "network-hdd"
            size = 20
        }
    }
    network_interface {
        subnet_id = yandex_vpc_subnet.subnet_web1.id
        nat       = true
        security_group_ids = [yandex_vpc_security_group.LAN_sec.id, yandex_vpc_security_group.elk_sec.id]
    }

    metadata = {
        user-data = file("./cloud-init.yml")
        serial-port-enable = 1
    }
    scheduling_policy { preemptible = true }
}
