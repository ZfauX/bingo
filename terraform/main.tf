terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_vpc_network" "default" {
  name = "ya-network"
}

resource "yandex_vpc_subnet" "default" {
  name           = "ya-network"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

provider "yandex" {
  service_account_key_file = "key.json"
  folder_id                = local.folder_id
  zone                     = "ru-central1-a"
}

locals {
  folder_id = "b1g3r5io2o3j9vakp30k"
  service-accounts = toset([
    "bingo-app",
  ])
  bingo-app-roles = toset([
    "admin",
  ])
}

resource "yandex_iam_service_account" "service-accounts" {
  for_each = local.service-accounts
  name     = each.key
}

resource "yandex_resourcemanager_folder_iam_member" "bingo-roles" {
  for_each  = local.bingo-app-roles
  folder_id = local.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.service-accounts["bingo-app"].id}"
  role      = each.key
}

data "yandex_compute_image" "default" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance_group" "app" {
  name                = "bingo-app"
  folder_id           = local.folder_id
  service_account_id  = yandex_iam_service_account.service-accounts["bingo-app"].id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v2"
    resources {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
    scheduling_policy {
      preemptible = true
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        type = "network-hdd"
        image_id = data.yandex_compute_image.default.id
        size     = "30"
      }
    }
    network_interface {
      network_id = "${yandex_vpc_network.default.id}"
      subnet_ids = ["${yandex_vpc_subnet.default.id}"]
      nat = true
    }
  
    metadata = {
      ssh-keys = "ubuntu:${file("C:\\Users\\TH\\.ssh\\id_ed25519.pub")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 1
    max_expansion   = 1
    max_deleting    = 1
  }

  load_balancer {
    target_group_name = "app"
    max_opening_traffic_duration = 180
  }
}

resource "yandex_lb_network_load_balancer" "default" {
  name = "app"
  type = "external"
  deletion_protection = "false"
  listener {
    name = "my-listener"
    port = 8080
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = "${yandex_compute_instance_group.app.load_balancer[0].target_group_id}"
  }
}
output "instance_external_ip_app" {
  value = yandex_compute_instance_group.app.instances.*.network_interface.0.nat_ip_address
}
output "instance_internal_ip_app" {
  value = yandex_compute_instance_group.app.instances.*.network_interface.0.ip_address
}
