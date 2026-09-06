# Целевая группа балансировщика 
resource "yandex_alb_target_group" "group1" {
    name = "group1"
    
    dynamic "target" {
      for_each = yandex_compute_instance.web
      content {
        subnet_id    = target.value.network_interface.0.subnet_id
        ip_address   = target.value.network_interface.0.ip_address
        }
      }
    }



# Группа бэкенда
resource "yandex_alb_backend_group" "web-backend-group" {
  name   = "web-backend-group"
  http_backend {
    name                   = "web"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.group1.id]
    load_balancing_config {
      panic_threshold      = 90
    }
    healthcheck {
      timeout              = "8s"
      interval             = "2s"
      healthcheck_port     = 80
      http_healthcheck {
        path               = "/"
      }
    }
  }
}


# HTTP router
resource "yandex_alb_http_router" "web-router" {
  name          = "web-router"
  
}

resource "yandex_alb_virtual_host" "web-virtual-host" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web-router.id

  route {
    name                      = "route1"
    disable_security_profile  = true

    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.web-backend-group.id
        timeout           = "60s"
        idle_timeout      = "60s"
        rate_limit {
          all_requests {
            per_second = "100"
            # или per_minute = <количество_запросов_в_минуту>
          }
          requests_per_ip {
            per_second = "10"
            # или per_minute = <количество_запросов_в_минуту>
          }
        }
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web-balancer" {
  name        = "web-balancer"
  network_id  = yandex_vpc_network.network2.id
  #security_group_ids = [yandex_vpc_security_group.web_sec.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet_web1.id 
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet_web2.id 
    }
  }

  # HTTP-обработчик
  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web-router.id
      }
    }
  }
}

