resource "yandex_vpc_network" "network2" {
    name = "network2"
}

resource "yandex_vpc_subnet" "subnet_web1" {
    name           = "subnet_web1"
    zone		   = "ru-central1-a"
    v4_cidr_blocks = ["10.0.10.0/24"]
    network_id     = yandex_vpc_network.network2.id
    route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet_web2" {
    name           = "subnet_web2"
    zone		   = "ru-central1-b"
    v4_cidr_blocks = ["10.0.11.0/24"]
    network_id     = yandex_vpc_network.network2.id
    route_table_id = yandex_vpc_route_table.rt.id
}

