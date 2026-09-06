# Группы безопасности
resource "yandex_vpc_security_group" "bastion_sec" {
    name       = "bastion_sec"
    network_id = yandex_vpc_network.network2.id
    ingress {
        description   = "Allow ssh"
        protocol      = "TCP"
        v4_cidr_blocks = ["0.0.0.0/0"]
        port          = 22
    }
    egress {
        description = "Permit any"
        protocol    = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 65535 
    }
}

resource "yandex_vpc_security_group" "LAN_sec" {
    name = "LAN_sec"
    network_id = yandex_vpc_network.network2.id
    ingress {
        description   = "Allow 10.0.0.0/8"
        protocol      = "ANY"
        v4_cidr_blocks = ["10.0.0.0/8"]
        from_port     = 0
        to_port       = 65535
    }
    egress {
        description = "Allow any"
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 65535
    }
}

resource "yandex_vpc_security_group" "web_sec" {
    name = "web_sec"
    network_id = yandex_vpc_network.network2.id
    ingress {
        description = "Allow 80"
        protocol = "TCP"
        v4_cidr_blocks = ["0.0.0.0/0"]
        port = 80
    }
    egress {
        description = "Allow any"
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 65535
    }
}


resource "yandex_vpc_security_group" "zabbix_sec" {
    name = "zabbix_sec"
    network_id = yandex_vpc_network.network2.id
    ingress {
        description = "Allow 8080"
        protocol = "TCP"
        v4_cidr_blocks = ["0.0.0.0/0"]
        port = 8080
    }
    egress {
        description = "Allow any"
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 65535
    }
}


resource "yandex_vpc_security_group" "elk_sec" {
    name = "elk_sec"
    network_id = yandex_vpc_network.network2.id
    ingress {
        description = "Allow Kibana 5601"
        protocol = "TCP"
        v4_cidr_blocks = ["0.0.0.0/0"]
        port = 5601
    }
    egress {
        description = "Allow any"
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 65535
    }
}
