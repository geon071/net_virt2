# Домашнее задание к занятию 5. «Elasticsearch»

## Задача 1

<details>
  <summary>Описание задачи</summary>

В этом задании вы потренируетесь в:

- установке Elasticsearch,
- первоначальном конфигурировании Elasticsearch,
- запуске Elasticsearch в Docker.

Используя Docker-образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для Elasticsearch,
- соберите Docker-образ и сделайте `push` в ваш docker.io-репозиторий,
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины.

Требования к `elasticsearch.yml`:

- данные `path` должны сохраняться в `/var/lib`,
- имя ноды должно быть `netology_test`.

В ответе приведите:

- текст Dockerfile-манифеста,
- ссылку на образ в репозитории dockerhub,
- ответ `Elasticsearch` на запрос пути `/` в json-виде.

Подсказки:

- возможно, вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum,
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml,
- при некоторых проблемах вам поможет Docker-директива ulimit,
- Elasticsearch в логах обычно описывает проблему и пути её решения.

Далее мы будем работать с этим экземпляром Elasticsearch.
</details>

### Ответ

#### Dockerfile

```
FROM centos:7

EXPOSE 9200 9300

USER 0

RUN export ES_HOME="/var/lib/elasticsearch" && \
    curl -k -o elasticsearch-8.8.2-linux-x86_64.tar.gz https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.8.2-linux-x86_64.tar.gz && \
    curl -k -o elasticsearch-8.8.2-linux-x86_64.tar.gz.sha512 https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.8.2-linux-x86_64.tar.gz.sha512 && \
    yum update -y && yum -y install perl-Digest-SHA && \
    shasum -a 512 -c elasticsearch-8.8.2-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.8.2-linux-x86_64.tar.gz && \
    rm -f elasticsearch-8.8.2-linux-x86_64.tar.gz* && \
    mv elasticsearch-8.8.2 ${ES_HOME} && \
    useradd -m -u 1000 elasticsearch && \
    chown elasticsearch:elasticsearch -R ${ES_HOME} && \
    yum clean all
COPY --chown=elasticsearch:elasticsearch config/* /var/lib/elasticsearch/config/

USER 1000

ENV ES_HOME="/var/lib/elasticsearch" \
    ES_PATH_CONF="/var/lib/elasticsearch/config"
WORKDIR ${ES_HOME}

CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]
```

#### ссылку на образ в репозитории dockerhub

<https://hub.docker.com/repository/docker/dochit/elasticsearch/general>

#### ответ `Elasticsearch` на запрос пути `/` в json-виде

```JSON
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "RQPxOU88Q3ee-JAD9pAeEw",
  "version" : {
    "number" : "8.8.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "98e1271edf932a480e4262a471281f1ee295ce6b",
    "build_date" : "2023-06-26T05:16:16.196344851Z",
    "build_snapshot" : false,
    "lucene_version" : "9.6.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

<details>
  <summary>Описание задачи</summary>
В этом задании вы научитесь:

- создавать и удалять индексы,
- изучать состояние кластера,
- обосновывать причину деградации доступности данных.

Ознакомьтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `Elasticsearch` 3 индекса в соответствии с таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API, и **приведите в ответе** на задание.

Получите состояние кластера `Elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находятся в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера Elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.
</details>

### Ответ

#### Получите список индексов и их статусов, используя API, и **приведите в ответе** на задание

```
vagrant@server1:~$ curl http://localhost:9200/_cat/indices?v
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 G2pOg8fUTyyI37q4USGJpg   1   0          0            0       225b           225b
yellow open   ind-3 XSHE7WhwSVq_edGASvwoyw   4   2          0            0       900b           900b
yellow open   ind-2 IUMtsbenRaihIsufJrO_ug   2   1          0            0       450b           450b
```

#### Получите состояние кластера `Elasticsearch`, используя API.

```
vagrant@server1:~$ curl http://localhost:9200/_cluster/health?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 7,
  "active_shards" : 7,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 41.17647058823529
}
```

#### Как вы думаете, почему часть индексов и кластер находятся в состоянии yellow?

У индексов должны быть реплики, но кластер состоит из одной ноды, поэтому размещать их негде.

#### Удалите все индексы.

```
vagrant@server1:~$ curl -X DELETE 'http://localhost:9200/*'
```

## Задача 3

<details>
  <summary>Описание задачи</summary>
В этом задании вы научитесь:

- создавать бэкапы данных,
- восстанавливать индексы из бэкапов.

Создайте директорию `{путь до корневой директории с Elasticsearch в образе}/snapshots`.

Используя API, [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
эту директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `Elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `Elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:

- возможно, вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `Elasticsearch`.
</details>

### Ответ

#### **Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```
vagrant@server1:~$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
> {
>   "type": "fs",
>   "settings": {
>     "location": "/var/lib/elasticsearch/snapshots",
>     "compress": true
>   }
> }'
{
  "acknowledged" : true
}
```

#### Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```
vagrant@server1:~$ curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "number_of_shards": 1,
>     "number_of_replicas": 0
>   }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}
```

```
vagrant@server1:~$ curl 'localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  6fqYhJZNThuen0J2VetOpA   1   0          0            0       225b           225b
```

#### **Приведите в ответе** список файлов в директории со `snapshot`.

```
[elasticsearch@32890dd35f5c elasticsearch]$ ls /var/lib/elasticsearch/snapshots/ -all
total 48
drwxrwxr-x 3 elasticsearch elasticsearch  4096 Jul 18 20:04 .
drwxr-xr-x 1 elasticsearch elasticsearch  4096 Jul 18 19:59 ..
-rw-r--r-- 1 elasticsearch elasticsearch   586 Jul 18 20:04 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Jul 18 20:04 index.latest
drwxr-xr-x 3 elasticsearch elasticsearch  4096 Jul 18 20:04 indices
-rw-r--r-- 1 elasticsearch elasticsearch 17526 Jul 18 20:04 meta-o1W8k7a5QIqx7gtbc-oXNA.dat
-rw-r--r-- 1 elasticsearch elasticsearch   307 Jul 18 20:04 snap-o1W8k7a5QIqx7gtbc-oXNA.dat
```

#### Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```
[elasticsearch@32890dd35f5c elasticsearch]$ curl -X DELETE "localhost:9200/test?pretty"
{
  "acknowledged" : true
}
```

```
[elasticsearch@32890dd35f5c elasticsearch]$ curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "number_of_shards": 1,
>     "number_of_replicas": 0
>   }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
```

```
[elasticsearch@32890dd35f5c elasticsearch]$ curl 'localhost:9200/_cat/indices?pretty'
green open test-2 DdN6F3OQSNKHfBrUViJ3SQ 1 0 0 0 225b 225b
```

#### **Приведите в ответе** запрос к API восстановления и итоговый список индексов.

```
[elasticsearch@32890dd35f5c elasticsearch]$ curl -X POST "localhost:9200/_snapshot/netology_backup/snapshot_1/_restore?pretty" -H 'Content-Type: application/json' -d'
> {
>   "indices": "*",
>   "include_global_state": true
> }
> '
{
  "accepted" : true
}
```

```
[elasticsearch@32890dd35f5c elasticsearch]$ curl 'localhost:9200/_cat/indices?pretty'
green open test-2 DdN6F3OQSNKHfBrUViJ3SQ 1 0 0 0 225b 225b
green open test   s7bE0_HURSuD4dwiOj-7Lw 1 0 0 0 247b 247b
```