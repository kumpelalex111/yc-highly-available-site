# Для выхода изолированных машин в Инет создаем nat_gateway
resource "yandex_vpc_gateway" "nat_gateway" {
    name = "gate"
    shared_egress_gateway {}
}

# Создаем сетевой маршрут для выхода в Интернет через NAT
resource "yandex_vpc_route_table" "rt" {
    name       = "rt"
    network_id = yandex_vpc_network.network2.id
    
    static_route {
        destination_prefix = "0.0.0.0/0"
        gateway_id         = yandex_vpc_gateway.nat_gateway.id
    }
}
