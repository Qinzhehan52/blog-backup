---
layout: windows
title: terminal尝试
date: 2019-05-25 18:53:05
tags:
---

## 前置工作（环境搭建）

- 系统版本在 Windows 1903 (build >= 10.0.18362.0) 以上

- 安装Visual Studio 2017 或 2019

- clone 代码到本地 https://github.com/microsoft/terminal.git

<!-- more -->

## 开始编译

- 用 Visual Studio 2019打开 terminal 本地 Repo, 自动弹出了需要安装的依赖项，下载安装，需要比较长时间的等待

- 用Visual Studio 2019编译时需要设置下项目重定向，打开OpenConsole.sln

![设置项目重定向](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/QQ20190525230101.jpg?raw=true)

- 设置编译选项

![设置编译选项](https://github.com/Qinzhehan52/blog-backup/blob/master/source//images/QQ20190525230409.jpg?raw=true)

### 报错

>无法打开包括文件: “wil/Common.h

解决方案：在terminal项目根目录下执行  `git submodule update --init --recursive`, 安装所有terminal项目的 `submodule`

## 成功效果预览

![成功效果预览](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/QQ20190525231337.jpg?raw=true)
