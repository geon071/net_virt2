# Домашнее задание к занятию 3. «MySQL»

## Задача 1

<details> 
  <summary>Описание задачи</summary>
      Используя Docker, поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
      
      Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-03-mysql/test_data) и 
      восстановитесь из него.
      
      Перейдите в управляющую консоль `mysql` внутри контейнера.
      
      Используя команду `\h`, получите список управляющих команд.
      
      Найдите команду для выдачи статуса БД и **приведите в ответе** из её вывода версию сервера БД.
      
      Подключитесь к восстановленной БД и получите список таблиц из этой БД.
      
      **Приведите в ответе** количество записей с `price` > 300.
      
      В следующих заданиях мы будем продолжать работу с этим контейнером.
</details>

### Ответ

Содержание файла манифеста
```
version: '3.1'

services:
  mysql:
    image: mysql:8
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=test_db
    volumes:
      - ./data:/var/lib/mysql
      - ./backup:/data/backup/mysql
    ports:
      - "3306:3306"
    restart: always
```
Команда запуска
```
docker-compose up -d
```

### Восстановление бэкапа

```
vagrant@first:~/docker/mysql$ docker exec -it compose-mysql_mysql_1 bash
bash-4.4# mysql -u root -p test_db < /data/backup/mysql/test_dump.sql
Enter password:
```

### Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

```
mysql> status
--------------
mysql  Ver 8.0.33 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          9
Current database:       test_db
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.33 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 5 min 41 sec

Threads: 2  Questions: 7  Slow queries: 0  Opens: 139  Flush tables: 3  Open tables: 58  Queries per second avg: 0.020
--------------
```

### Подключитесь к восстановленной БД и получите список таблиц из этой БД.

```
mysql> use test_db;
Database changed
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.01 sec)
```

### Приведите в ответе количество записей с `price` > 300.

```
mysql> SELECT * FROM orders WHERE price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)


mysql> SELECT count(*) FROM orders WHERE price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.03 sec)

```

## Задача 2

<details> 
  <summary>Описание задачи</summary>
     Создайте пользователя test в БД c паролем test-pass, используя:
     
     - плагин авторизации mysql_native_password
     - срок истечения пароля — 180 дней 
     - количество попыток авторизации — 3 
     - максимальное количество запросов в час — 100
     - аттрибуты пользователя:
         - Фамилия "Pretty"
         - Имя "James".
     
     Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
         
     Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES, получите данные по пользователю `test` и 
     **приведите в ответе к задаче**.
</details>

### Ответ

```
CREATE USER 'test'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'test-pass' 
WITH MAX_QUERIES_PER_HOUR 100
PASSWORD EXPIRE INTERVAL 180 DAY
FAILED_LOGIN_ATTEMPTS 3
ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
```

### Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

```
mysql> GRANT SELECT ON test_db.* TO 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.07 sec)
```

### Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

```
mysql> select * from information_schema.user_attributes where user='test';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

<details> 
  <summary>Описание задачи</summary>
     Установите профилирование `SET profiling = 1`.
     Изучите вывод профилирования команд `SHOW PROFILES;`.
     
     Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
     
     Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
     - на `MyISAM`,
     - на `InnoDB`.
</details>

### Ответ

### Установите профилирование `SET profiling = 1`. Изучите вывод профилирования команд `SHOW PROFILES;`.

```
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> show profiles;
+----------+------------+-------------------+
| Query_ID | Duration   | Query             |
+----------+------------+-------------------+
|        1 | 0.02399225 | SELECT DATABASE() |
|        2 | 0.00029950 | SET profiling = 1 |
+----------+------------+-------------------+
2 rows in set, 1 warning (0.00 sec)
```

### Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
```
mysql> SELECT TABLE_NAME,
    ->        ENGINE
    -> FROM   information_schema.TABLES
    -> WHERE  TABLE_SCHEMA = 'test_db';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.00 sec)
```

### Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**: на `MyISAM`, на `InnoDB`

```
mysql> alter table orders engine = myisam;
Query OK, 5 rows affected (0.87 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> alter table orders engine = innodb;
Query OK, 5 rows affected (0.68 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> show profiles;
+----------+------------+------------------------------------+
| Query_ID | Duration   | Query                              |
+----------+------------+------------------------------------+
|       10 | 0.87218275 | alter table orders engine = myisam |
|       11 | 0.68286425 | alter table orders engine = innodb |
+----------+------------+------------------------------------+
2 rows in set, 1 warning (0.00 sec)
```

## Задача 4

<details> 
  <summary>Описание задачи</summary>
     Изучите файл `my.cnf` в директории /etc/mysql.
     
     Измените его согласно ТЗ (движок InnoDB):
     
     - скорость IO важнее сохранности данных;
     - нужна компрессия таблиц для экономии места на диске;
     - размер буффера с незакомиченными транзакциями 1 Мб;
     - буффер кеширования 30% от ОЗУ;
     - размер файла логов операций 100 Мб.
     
     Приведите в ответе изменённый файл `my.cnf`.
</details>

### Ответ

### Приведите в ответе измененный файл `my.cnf`.

```
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/

innodb_flush_method = O_DSYN
innodb_file_per_table = 1
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 1G
innodb_log_file_size = 100M
```