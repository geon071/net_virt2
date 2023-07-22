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

variable vm_web_resources {
  type = object({
    cores = number
    memory = number
    core_fraction = number
  })
  default = {
      cores = 2
      memory = 2
      core_fraction = 5
    }
}

variable vm_web_scheduling_policy {
  type        = bool
  default     = true
}

variable vm_web_nat {
  type        = bool
  default     = true
}

variable vm_web_serial_port_enable {
  type        = number
  default     = 1
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

variable vm_db_resources {
  type = object({
    cores = number
    memory = number
    core_fraction = number
  })
  default = {
      cores = 2
      memory = 2
      core_fraction = 20
    }
}

variable vm_db_scheduling_policy {
  type        = bool
  default     = true
}

variable vm_db_nat {
  type        = bool
  default     = true
}

variable vm_db_serial_port_enable {
  type        = number
  default     = 1
}