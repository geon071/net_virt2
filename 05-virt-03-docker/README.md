# Домашнее задание к занятию "3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## Задача 1

Подготовил образ - <https://hub.docker.com/r/dochit/ng-static/tags>

Проверил его корректность следующим образом:

```console
vagrant@server1:~$ docker run --name test-nginx2 -d -p 8080:80 dochit/ng-static:0.0.1
46661fd4f0036cc7baef38938cc75a9d18d3211a5afda33601a0c43735aaf54d
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS
                NAMES
46661fd4f003   dochit/ng-static:0.0.1   "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   test-nginx2
vagrant@server1:~$ curl -v http://127.0.0.1:8080/index.html
*   Trying 127.0.0.1:8080...
* TCP_NODELAY set
* Connected to 127.0.0.1 (127.0.0.1) port 8080 (#0)
> GET /index.html HTTP/1.1
> Host: 127.0.0.1:8080
> User-Agent: curl/7.68.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Server: nginx/1.23.3
< Date: Sun, 26 Feb 2023 17:02:51 GMT
< Content-Type: text/html
< Content-Length: 91
< Last-Modified: Sun, 26 Feb 2023 16:35:02 GMT
< Connection: keep-alive
< ETag: "63fb8a36-5b"
< Accept-Ranges: bytes
<
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
* Connection #0 to host 127.0.0.1 left intact
```

## Задача 2

### Высоконагруженное монолитное java веб-приложение;

Виртуальная машина, в виду монолитности приложение скорее всего требовательно к ресурсам, Docker отлично подойдет для разворачивания микро-сервисов написанных на базе Java

### Nodejs веб-приложение;

Docker, т.к. снижает трудозатраты на деплой приложения и решает проблему с зависимостями библиотек

### Мобильное приложение c версиями для Android и iOS;

Виртуальная машина, с UI у Docker нет возможности работать

### Шина данных на базе Apache Kafka;

Виртуальная машина, на тесте можно использовать Docker для Кафка, но на проде только ВМ, в виду вопросов производительности и масштабирования кластера

### Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;

Виртуальная машина для кластера Elasticsearch, в Docker непонятно для чего разворачивать кластеруню конфигурацию elastic, если все ноды располагать на одной Docker машине, то почему просто не развернуть одну ноду. logstash и kibana можно на Docker

### Мониторинг-стек на базе Prometheus и Grafana;

Docker, неплохо справится + можно просто масштабировать

### MongoDB, как основное хранилище данных для java-приложения;

Docker, потребуется только подключение/настройка персистентного хранилища, для сохранения данных

### Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

Docker Registry в Docker, поставляется таким образом, Gitlab сервер, так же можно развернуть в Docker для возможности масштабирования если будет много одновременных запусков пайпов

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

```console
vagrant@server1:~$ docker run -it --rm -d --name centos -v $(pwd)/data:/data centos
Unable to find image 'centos:latest' locally
latest: Pulling from library/centos
a1d0c7532777: Pull complete
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
d5bace6a47c4c3c02dc6175d5e4d84347f6e29b6a2ae42fca2baae9b3cef6269
vagrant@server1:~$ docker run -it --rm -d --name debian -v $(pwd)/data:/data debian
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
1e4aec178e08: Pull complete
Digest: sha256:43ef0c6c3585d5b406caa7a0f232ff5a19c1402aeb415f68bcd1cf9d10180af8
Status: Downloaded newer image for debian:latest
6da83605123ef5bad797c7b96874f39a232f8760c3b51b7d1ecd93185919f455
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED              STATUS          PORTS     NAMES
6da83605123e   debian    "bash"        26 seconds ago       Up 24 seconds             debian
d5bace6a47c4   centos    "/bin/bash"   About a minute ago   Up 58 seconds             centos
vagrant@server1:~$ docker exec centos touch /data/new_file.txt
vagrant@server1:~$ touch data/123.txt
vagrant@server1:~$ docker exec debian ls -all /data
total 8
drwxrwxr-x 2 1000 1000 4096 Feb 26 17:47 .
drwxr-xr-x 1 root root 4096 Feb 26 17:41 ..
-rw-rw-r-- 1 1000 1000    0 Feb 26 17:47 123.txt
-rw-r--r-- 1 root root    0 Feb 26 17:47 new_file.txt
```