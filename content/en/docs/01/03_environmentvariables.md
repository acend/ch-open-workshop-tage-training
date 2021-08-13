---
title: "3. Environment variables"
weight: 13
---


From the [previous lab](../02/):

> Question: What's wrong? Am I an idiot?

Answer: No! You've just done what was stated in the instructions. As a result, an error has popped up!

```
error: database is uninitialized and password option is not specified
  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD
```


## Environment variables

What happened?
The MariaDB server is not able to run without a proper configuration. Docker has the possibility to pass variables into the instantiation process via environment variables.
Environment variables are passed via the parameter `-e` e.g.

```bash
docker run -it -e MYSQL_ROOT_PASSWORD=my-secret-pw mariadb
```

Once you run the command you will see an output like this:

```

Initializing database

PLEASE REMEMBER TO SET A PASSWORD FOR THE MariaDB root USER !
To do so, start the server, then issue the following commands:

'/usr/bin/mysqladmin' -u root password 'new-password'
'/usr/bin/mysqladmin' -u root -h  password 'new-password'

Alternatively you can run:
'/usr/bin/mysql_secure_installation'

which will also give you the option of removing the test
databases and anonymous user created by default.  This is
strongly recommended for production servers.

See the MariaDB Knowledgebase at http://mariadb.com/kb or the
MySQL manual for more instructions.

Please report any problems at http://mariadb.org/jira

The latest information about MariaDB is available at http://mariadb.org/.
You can find additional information about the MySQL part at:
http://dev.mysql.com
Consider joining MariaDB's strong and vibrant community:
https://mariadb.org/get-involved/

Database initialized
MySQL init process in progress...
2020-05-27  6:21:03 0 [Note] mysqld (mysqld 10.3.7-MariaDB-1:10.3.7+maria~jessie) starting as process 101 ...
2020-05-27  6:21:03 0 [Note] InnoDB: Using Linux native AIO
2020-05-27  6:21:03 0 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2020-05-27  6:21:03 0 [Note] InnoDB: Uses event mutexes
2020-05-27  6:21:03 0 [Note] InnoDB: Compressed tables use zlib 1.2.8
2020-05-27  6:21:03 0 [Note] InnoDB: Number of pools: 1
2020-05-27  6:21:03 0 [Note] InnoDB: Using SSE2 crc32 instructions
2020-05-27  6:21:03 0 [Note] InnoDB: Initializing buffer pool, total size = 256M, instances = 1, chunk size = 128M

...

2020-05-27  6:21:08 0 [Note] mysqld: ready for connections.
Version: '10.3.7-MariaDB-1:10.3.7+maria~jessie'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  mariadb.org binary distribution
```

The problem is that you are now stuck in this console.
To return to your shell press `CTRL-p` and then `CTRL-q`.

{{% alert title="Note for Windows" color="primary" %}}
This might not work on Windows since the shortcuts `CTRL-p` and `CTRL-q` are already used for other purposes. Use `docker ps` in a seperate shell to get the container ID and then stop it using `docker stop <container>`
{{% /alert %}}

This will leave the container running while you are back in your shell. To verify that the container is really running use the command:

```bash
docker ps
```

The output should look much like this:

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
7cb31f821233        mariadb             "docker-entrypoint..."   5 minutes ago       Up 5 minutes        3306/tcp            upbeat_blackwell
```

To connect to the container again you can use the following command:

```bash
docker exec -it <container> bash
```

Where `<container>` can refer to the `CONTAINER ID` (the first two characters are normally sufficient) or one of the `NAMES` from the output of `docker ps`.

{{% alert title="Note" color="primary" %}}
The docker exec command needs either the ID or NAME of the container. Additionally, at the end, an executable.
{{% /alert %}}

In this example it's `bash` as we want to do something interactively in the container.

Once the command is executed you should see this:

`root@7cb31f821233:/#`

{{% alert title="Note" color="primary" %}}
Every time you connect yourself to a container you will always be the user that was defined as user in the Dockerfile.
{{% /alert %}}

Now that we are connected let's find out if the MariaDB is working...

```bash
mysql -uroot -pmy-secret-pw
```

If everything works as expected, you should now see the MariaDB command line:

```
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 8
Server version: 10.3.8-MariaDB-1:10.3.8+maria~jessie mariadb.org binary distribution

Copyright (c) 2000, 2020, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
```

Type `exit` to leave the mysql client. Type `exit` one more time to leave the container.


## Daemons

One might think: *This whole starting process is a bit freaky with `CTRL-p` and then `CTRL-q`*.
Therefore, you can run a Docker container "daemonized".
You just have to add the parameter `-d` to the Docker `run` command e.g.:

```bash
docker run -it -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mariadb
```

If you now have a look into the container list, you should come up with two running containers:

```bash
docker ps
```

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
699e82ed8f1f        mariadb             "docker-entrypoint..."   3 minutes ago       Up 3 minutes        3306/tcp            jolly_bardeen
7cb31f821233        mariadb             "docker-entrypoint..."   32 minutes ago      Up 32 minutes       3306/tcp            upbeat_blackwell
```

> Question: Do we need two running MariaDB containers at the same time for this lab?

Find out in the [next lab](../04_deletingcontainers/).
