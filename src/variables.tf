###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

### vars for yandex_compute_instance, yandex_compute_image

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

###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJkjyC8jM6WyALVI5h/cBOLtxO/OsxSU6Matw+HHefF"
  description = "ssh-keygen -t ed25519"
}
