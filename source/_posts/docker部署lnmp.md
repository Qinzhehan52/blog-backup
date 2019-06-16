---
title: docker 部署 LNMP
date: 2018-10-29 14:02:50
tags:
  - docker
  - php
categories:
  - docker
---
# docker 部署 LNMP

## docker 简介

### 什么是docker

> Docker 使用 Google 公司推出的 [Go 语言](https://golang.org/) 进行开发实现，基于 Linux 内核的 [cgroup](https://zh.wikipedia.org/wiki/Cgroups)，[namespace](https://en.wikipedia.org/wiki/Linux_namespaces)，以及[AUFS](https://en.wikipedia.org/wiki/Aufs) 类的 [Union FS](https://en.wikipedia.org/wiki/Union_mount) 等技术，对进程进行封装隔离，属于 [操作系统层面的虚拟化技术](https://en.wikipedia.org/wiki/Operating-system-level_virtualization)。由于隔离的进程独立于宿主和其它的隔离的进程，因此也称其为容器。

> Docker 在容器的基础上，进行了进一步的封装，从文件系统、网络互联到进程隔离等等，极大的简化了容器的创建和维护。使得 Docker 技术比虚拟机技术更为轻便、快捷。

> 下面的图片比较了 Docker 和传统虚拟化方式的不同之处。传统虚拟机技术是虚拟出一套硬件后，在其上运行一个完整操作系统，在该系统上再运行所需应用进程；而容器内的应用进程直接运行于宿主的内核，容器内没有自己的内核，而且也没有进行硬件虚拟。因此容器要比传统虚拟机更为轻便。

<!-- more -->

![ä¼ ç"èæå](https://yeasy.gitbooks.io/docker_practice/introduction/_images/virtualization.png)

![Docker](https://yeasy.gitbooks.io/docker_practice/introduction/_images/docker.png)

### 为什么要用docker

#### 企业应用

- 更高效的利用系统资源
- 更快速的启动时间
- 一致的运行环境
- 持续交付和部署
- 更轻松的迁移
- 更轻松的维护和拓展

| 特性       | 容器               | 虚拟机      |
| ---------- | ------------------ | ----------- |
| 启动       | 秒级               | 分钟级      |
| 硬盘使用   | 一般为 `MB`        | 一般为 `GB` |
| 性能       | 接近原生           | 弱于        |
| 系统支持量 | 单机支持上千个容器 | 一般几十个  |

#### 个人开发

- 便于搭建部署 （通过下载并修改其他优秀的docker项目）
- 便于备份迁移 （可将docker配置备份于repo，在各个云主机、vps及自己的笔记本上一致）
- 便于实验新特性 （建议在云主机上进行，镜像有一定体积，云主机网速较快）

#### 基本概念

> 镜像：我们都知道，操作系统分为内核和用户空间。对于 Linux 而言，内核启动后，会挂载 `root` 文件系统为其提供用户空间支持。而 Docker 镜像（Image），就相当于是一个 `root` 文件系统。
>
> Docker 镜像是一个特殊的文件系统，除了提供容器运行时所需的程序、库、资源、配置等文件外，还包含了一些为运行时准备的一些配置参数（如匿名卷、环境变量、用户等）。镜像不包含任何动态数据，其内容在构建之后也不会被改变。

> 容器：镜像（`Image`）和容器（`Container`）的关系，就像是面向对象程序设计中的 `类` 和 `实例` 一样，镜像是静态的定义，容器是镜像运行时的实体。容器可以被创建、启动、停止、删除、暂停等。
>
> 按照 Docker 最佳实践的要求，容器不应该向其存储层内写入任何数据，容器存储层要保持无状态化。所有的文件写入操作，都应该使用 数据卷（Volume）、或者绑定宿主目录，在这些位置的读写会跳过容器存储层，直接对宿主（或网络存储）发生读写，其性能和稳定性更高。*_分离服务和数据_*
>
> 数据卷的生存周期独立于容器，容器消亡，数据卷不会消亡。因此，使用数据卷后，容器删除或者重新运行之后，数据却不会丢失。

> 仓库：镜像构建完成后，可以很容易的在当前宿主机上运行，但是，如果需要在其它服务器上使用这个镜像，我们就需要一个集中的存储、分发镜像的服务，[Docker Registry](https://yeasy.gitbooks.io/docker_practice/repository/registry.html) 就是这样的服务。

## docker-compose 简介

### docker 三剑客

- compose
- machine
- swarm

### 简介

> `Compose` 项目是 Docker 官方的开源项目，负责实现对 Docker 容器集群的快速编排。
>
> `Compose` 定位是 「定义和运行多个 Docker 容器的应用（Defining and running multi-container Docker applications）。



> `Compose` 中有两个重要的概念：
>
> - 服务 (`service`)：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。
> - 项目 (`project`)：由一组关联的应用容器组成的一个完整业务单元，在 `docker-compose.yml` 文件中定义。



> `Compose` 项目由 Python 编写，实现上调用了 Docker 服务提供的 API 来对容器进行管理。（也就是说compose只是包装了docker的一些API，便于使用，并没有改变docker的性质）

## 使用他人的 dockerfile/docker-compose.yml

```docker-compose
version: "3"
services:
  nginx:
    image: nginx:alpine #指定镜像
    ports: #端口映射
      - "80:80"
      - "443:443"
    volumes: #数据卷挂载
      - ./www/:/var/www/html/:rw
      - ./conf/conf.d:/etc/nginx/conf.d/:ro
      - ./conf/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./log/:/var/log/dnmp/:rw
    networks: #网络
      - net-php

  php:
    build: ./php/php72 #这里与指定镜像不同的是，指定了一个构建docker镜像的目录，根据目录下的dockerfile构建镜像
    expose:
      - "9000"
    volumes:
      - ./www/:/var/www/html/:rw
      - ./conf/php.ini:/usr/local/etc/php/php.ini:ro
      - ./conf/php-fpm.conf:/usr/local/etc/php-fpm.d/www.conf:rw
      - ./log/:/var/log/dnmp/:rw
    networks:
      - net-php
      - net-mysql
      - net-redis

  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    volumes:
      - ./conf/mysql.cnf:/etc/mysql/conf.d/mysql.cnf:ro
      - ./mysql/:/var/lib/mysql/:rw
    networks:
      - net-mysql
    environment:
      MYSQL_ROOT_PASSWORD: "123456"

  redis:
    image: redis:4.0
    command: redis-server /usr/local/etc/redis/redis.conf --requirepass mypassword #指定镜像运行时使用的命令
    networks:
      - net-redis
    ports:
      - "6379:6379"
    volumes:
      - ./conf/redis.conf:/usr/local/etc/redis/redis.conf

networks:
  net-php:
  net-mysql:
  net-redis:
```



## 部署及使用

```bash
> docker-compose up [-d]
> docker-compose logs
> docker-compose inspect
> docker-compose ps
> docker inspect [container]
```

### 参考示例

[github dnmp](https://github.com/Qinzhehan52/dnmp)



## docker实验新特性（基于资源分离的特性）

```bash
> docker run --name test-mysql -e MYSQL_ROOT_PASSWORD=mypassword -d mysql:5.7
> docker exec -it test-mysql bash
```

参考链接：[Docker—从入门到实践](https://yeasy.gitbooks.io/docker_practice/content/)

