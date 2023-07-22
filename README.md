# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»

## Задача 1

<details>
  <summary>Описание задачи</summary>
1. Изучите проект. В файле variables.tf объявлены переменные для yandex provider.
2. Переименуйте файл personal.auto.tfvars_example в personal.auto.tfvars. Заполните переменные (идентификаторы облака, токен доступа). Благодаря .gitignore этот файл не попадет в публичный репозиторий. **Вы можете выбрать иной способ безопасно передать секретные данные в terraform.**
3. Сгенерируйте или используйте свой текущий ssh ключ. Запишите его открытую часть в переменную **vms_ssh_root_key**.
4. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте в чем заключается их суть?
5. Ответьте, как в процессе обучения могут пригодиться параметры```preemptible = true``` и ```core_fraction=5``` в параметрах ВМ? Ответ в документации Yandex cloud.

В качестве решения приложите:

- скриншот ЛК Yandex Cloud с созданной ВМ,
- скриншот успешного подключения к консоли ВМ через ssh(к OS ubuntu необходимо подключаться под пользователем ubuntu: "ssh ubuntu@vm_ip_address"),
- ответы на вопросы.

</details>

### Ответ

![alt text](img/ya1.png "ya1")

![alt text](img/ya2.png "ya2")

#### 4. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте в чем заключается их суть?

##### первая ошибка

```bash
yandex_compute_instance.platform: Creating...
╷
│ Error: Error while requesting API to create instance: server-request-id = 290e2196-a3e6-4131-91fc-011db79e8306 server-trace-id = 95758d8c351623d8:2ab06f898cae90ae:95758d8c351623d8:1 client-request-id = d49bebfc-8ad0-437a-b6f5-a7882b7620f8 client-trace-id = 8413fb5c-013e-4744-a152-3440507f41ee rpc error: code = FailedPrecondition desc = Platform "standart-v4" not found
│
│   with yandex_compute_instance.platform,
│   on main.tf line 15, in resource "yandex_compute_instance" "platform":
│   15: resource "yandex_compute_instance" "platform" {
│
╵
```

Допущена ошибка в свойстве platform_id, ресурса platform, исправил с "standart-v4" на "standard-v1", согласно доке - <https://cloud.yandex.ru/docs/compute/concepts/vm-platforms> такой платформы нет, взял дефолтную

##### вторая ошибка

```bash
yandex_compute_instance.platform: Creating...
╷
│ Error: Error while requesting API to create instance: server-request-id = 5f25a486-33b9-4b38-86ef-f28994e218c0 server-trace-id = c7b867b6eb20bbd6:7e2a3f24d493ce73:c7b867b6eb20bbd6:1 client-request-id = d2a1a5de-0358-4a32-9725-87edb3a98c6f client-trace-id = d42c493f-f811-4305-ac5d-c7a9eef48d1f rpc error: code = InvalidArgument desc = the specified number of cores is not available on platform "standard-v1"; allowed core number: 2, 4
│
│   with yandex_compute_instance.platform,
│   on main.tf line 15, in resource "yandex_compute_instance" "platform":
│   15: resource "yandex_compute_instance" "platform" {
│
╵
```

Исправил ресурсы согласно требованиям платформы, поменял CPU/RAM на 2/2

#### 5. Ответьте, как в процессе обучения могут пригодиться параметры```preemptible = true``` и ```core_fraction=5``` в параметрах ВМ? Ответ в документации Yandex cloud

preemptible, согласно документации "Прерываемые виртуальные машины — это виртуальные машины, которые могут быть принудительно остановлены в любой момент." Это позволяет меньше тратить денег на ВМ, так же не обязательно помнить о выключении такой ВМ, сама остановится через 24 часа.

core_fraction=5, "Уровни производительности vCPU", минимальная конфигурация для уровня производительности 5%, экономия денег

## Задача 2

<details>
  <summary>Описание задачи</summary>
1. Изучите файлы проекта.
2. Замените все "хардкод" **значения** для ресурсов **yandex_compute_image** и **yandex_compute_instance** на **отдельные** переменные. К названиям переменных ВМ добавьте в начало префикс **vm_web_** .  Пример: **vm_web_name**.
2. Объявите нужные переменные в файле variables.tf, обязательно указывайте тип переменной. Заполните их **default** прежними значениями из main.tf. 
3. Проверьте terraform plan (изменений быть не должно). 

</details>

### Ответ

#### variables.tf

<details>
  <summary>variables.tf</summary>

```JSON
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
```

</details>

#### main.tf (yandex_compute_instance, yandex_compute_image)

<details>
  <summary>main.tf</summary>

```JSON
data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}
resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_platform_name
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_scheduling_policy
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_nat
  }

  metadata = {
    serial-port-enable = var.vm_web_serial_port_enable
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}
```

</details>

#### Вывод terraform plan

```bash
PS D:\Lern_netology\net_virt2\src> .\terraform.exe plan
yandex_vpc_network.develop: Refreshing state... [id=enpud16l8rdt1m3abun5]
data.yandex_compute_image.ubuntu: Reading...
data.yandex_compute_image.ubuntu: Read complete after 1s [id=fd85f37uh98ldl1omk30]
yandex_vpc_subnet.develop: Refreshing state... [id=e9bp11h93i29611orfk9]
yandex_compute_instance.platform: Refreshing state... [id=fhm8ml08mmofqhnr0dd7]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

## Задача 3

<details>
  <summary>Описание задачи</summary>

1. Создайте в корне проекта файл 'vms_platform.tf' . Перенесите в него все переменные первой ВМ.
2. Скопируйте блок ресурса и создайте с его помощью вторую ВМ(в файле main.tf): **"netology-develop-platform-db"** ,  cores  = 2, memory = 2, core_fraction = 20. Объявите ее переменные с префиксом **vm_db_** в том же файле('vms_platform.tf').
3. Примените изменения.

</details>

### Ответ

#### vms_platform.tf

<details>
  <summary>vms_platform.tf</summary>

  ```json
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
  ```

</details>

#### main.tf

<details>
  <summary>main.tf</summary>

  ```json
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}


data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}
resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_platform_name
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_scheduling_policy
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_nat
  }

  metadata = {
    serial-port-enable = var.vm_web_serial_port_enable
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}

resource "yandex_compute_instance" "platform_db" {
  name        = var.vm_db_platform_name
  platform_id = var.vm_db_platform_id
  resources {
    cores         = var.vm_db_resources.cores
    memory        = var.vm_db_resources.memory
    core_fraction = var.vm_db_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_scheduling_policy
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_db_nat
  }

  metadata = {
    serial-port-enable = var.vm_db_serial_port_enable
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}
  ```

</details>

#### вывод успешности apply

```bash
yandex_compute_instance.platform_db: Creating...
yandex_compute_instance.platform_db: Still creating... [10s elapsed]
yandex_compute_instance.platform_db: Still creating... [20s elapsed]
yandex_compute_instance.platform_db: Still creating... [30s elapsed]
yandex_compute_instance.platform_db: Creation complete after 37s [id=fhm428a7ua68012uqojn]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## Задача 4

<details>
  <summary>Описание задачи</summary>

1. Объявите в файле outputs.tf output типа map, содержащий { instance_name = external_ip } для каждой из ВМ.
2. Примените изменения.

В качестве решения приложите вывод значений ip-адресов команды ```terraform output```

</details>

### Ответ

#### outputs.tf

<details>
  <summary>outputs.tf</summary>

```json
output "ext_ip" {
  value       = {
    (yandex_compute_instance.platform.name)        = yandex_compute_instance.platform.network_interface[0].nat_ip_address
    (yandex_compute_instance.platform_db.name)  = yandex_compute_instance.platform_db.network_interface[0].nat_ip_address
  }

}
```

</details>

#### В качестве решения приложите вывод значений ip-адресов команды ```terraform output```

```bash
PS D:\Lern_netology\net_virt2\src> .\terraform.exe output
ext_ip = {
  "netology-develop-platform-db" = "130.193.48.113"
  "netology-develop-platform-web" = "158.160.39.39"
}
```

## Задание 5

<details>
  <summary>Описание задачи</summary>

1. В файле locals.tf опишите в **одном** local-блоке имя каждой ВМ, используйте интерполяцию ${..} с несколькими переменными по примеру из лекции.
2. Замените переменные с именами ВМ из файла variables.tf на созданные вами local переменные.
3. Примените изменения.

</details>

#### locals.tf

<details>
  <summary>locals.tf</summary>

```json
locals {
  env = "develop"
  project = "platform"
  role = ["web", "db"]
}
```

</details>

#### main.tf

<details>
  <summary>main.tf</summary>

```json
resource "yandex_compute_instance" "platform" {
  name        = "netology-${ local.env }-${ local.project }-${ local.role[0] }"
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_scheduling_policy
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_nat
  }

  metadata = {
    serial-port-enable = var.vm_web_serial_port_enable
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}

resource "yandex_compute_instance" "platform_db" {
  name        = "netology-${ local.env }-${ local.project }-${ local.role[1] }"
  platform_id = var.vm_db_platform_id
  resources {
    cores         = var.vm_db_resources.cores
    memory        = var.vm_db_resources.memory
    core_fraction = var.vm_db_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_scheduling_policy
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_db_nat
  }

  metadata = {
    serial-port-enable = var.vm_db_serial_port_enable
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}
```

</details>