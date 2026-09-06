# Snapshot bastion
resource "yandex_compute_snapshot" "snapshot-bastion" {
  name           = "snapshot-bastion"
  source_disk_id = yandex_compute_instance.bastion.boot_disk[0].disk_id
  description    = "snapshot-bastion boot disk"
}

#Расписание bastion
resource "yandex_compute_snapshot_schedule" "shedule-bastion" {
  name = "shedule-bastion"

  schedule_policy {
    expression = "@daily"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "snapshot-bastion"
    }

  disk_ids = [yandex_compute_instance.bastion.boot_disk[0].disk_id]
}

# Snapshot elk
resource "yandex_compute_snapshot" "snapshot-elk" {
  name           = "snapshot-elk"
  source_disk_id = yandex_compute_instance.elk.boot_disk[0].disk_id
  description    = "snapshot-elk boot disk"
}

#Расписание elk
resource "yandex_compute_snapshot_schedule" "shedule-elk" {
  name = "shedule-elk"

  schedule_policy {
    expression = "@daily"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "snapshot-elk"
    }

  disk_ids = [yandex_compute_instance.elk.boot_disk[0].disk_id]
}

# Snapshot zabbix
resource "yandex_compute_snapshot" "snapshot-zabbix" {
  name           = "snapshot-zabbix"
  source_disk_id = yandex_compute_instance.zabbix.boot_disk[0].disk_id
  description    = "snapshot-zabbix boot disk"
}

#Расписание zabbix
resource "yandex_compute_snapshot_schedule" "shedule-zabbix" {
  name = "shedule-zabbix"

  schedule_policy {
    expression = "@daily"
  }

  snapshot_count = 7

  snapshot_spec {
    description = "snapshot-zabbix"
    }

  disk_ids = [yandex_compute_instance.zabbix.boot_disk[0].disk_id]
}

# Snapshot web. Создаем для каждого web-сервера
resource "yandex_compute_snapshot" "web_snapshots" {
  for_each = yandex_compute_instance.web

  name           = "snapshot-${each.key}"
  source_disk_id = each.value.boot_disk[0].disk_id
  description    = "snapshot for ${each.key} boot disk"
}

#Расписание для всех web-серверов
resource "yandex_compute_snapshot_schedule" "shedule-web1" {
  name = "shedule-web1"

  schedule_policy {
    expression = "@daily"
  }

  snapshot_count = 7


  disk_ids = [
    for instance in yandex_compute_instance.web : instance.boot_disk[0].disk_id
  ]
}


