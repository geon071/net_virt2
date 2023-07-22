### vars for platform-web yandex_compute_instance, yandex_compute_image

variable vm_web_family {
  type        = string
  default     = "ubuntu-2004-lts"
}

variable vm_web_platform_name {
  type        = string
  default     = "netology-develop-platform-web"
}

variable vm_web_platform_id {
  type        = string
  default     = "standard-v1"
}

variable vm_web_scheduling_policy {
  type        = bool
  default     = true
}

variable vm_web_nat {
  type        = bool
  default     = true
}

### vars for platform-db yandex_compute_instance, yandex_compute_image

variable vm_db_family {
  type        = string
  default     = "ubuntu-2004-lts"
}

variable vm_db_platform_name {
  type        = string
  default     = "netology-develop-platform-db"
}

variable vm_db_platform_id {
  type        = string
  default     = "standard-v1"
}

variable vm_db_scheduling_policy {
  type        = bool
  default     = true
}

variable vm_db_nat {
  type        = bool
  default     = true
}

#### общие ресурсная мапа

variable vms_metadata {
  type = map
  default = {
    serial-port-enable = 1
    ssh = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJkjyC8jM6WyALVI5h/cBOLtxO/OsxSU6Matw+HHefF"
  }
}

variable vms_resources {
  type = map
  default = {
        vm_db_resources = {
            cores = 2
            memory = 2
            core_fraction = 20
        }
        vm_web_resources = {
            cores = 2
            memory = 2
            core_fraction = 5
        }
    }
}