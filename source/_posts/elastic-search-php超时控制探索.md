---
title: elastic-search-php超时控制探索
date: 2021-11-03 14:42:22
tags:
---
- /vendor/es-client/elasticsearch/src/Elasticsearch/Connections/Connection.php:169
![此处将调用ringPHP的curlHandler](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image2021-5-21_16-9-10.png?raw=true)

此处将调用ringPHP的curlHandler
https://ringphp.readthedocs.io/en/latest/client_handlers.html

根据ringPHP文档，我们可以在此处设法传递我们想要的curl配置
那么，在自己封装框架内，适合的地方开放一个可设置curl参数的接口即可为es定义一个某集群请求全局的超时控制

![ringPHP](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image2021-5-21_16-9-49.png?raw=true)

- es-client/elasticsearch/src/Elasticsearch/Client.php:936
![Client.php](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/source/images/image2021-5-21_16-13-48.png?raw=true)
![Client.php](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/source/images/image2021-5-21_16-14-53.png?raw=true)
![Client.php](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/source/images/image2021-5-21_16-15-58.png?raw=true)
![Client.php](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/source/images/image2021-5-21_16-16-16.png.png?raw=true)
