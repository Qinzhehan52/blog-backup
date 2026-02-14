---
title: macos mojave zlib安装
date: 2020-01-15 18:43:18
tags:
    - macOS
    - PHP
categories:
    - Env Setup
---

## 遇到的问题

编译安装 `php7.2` 时，`configure` 显示找不到 `zlib`

## 解决方法

```bash
installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
```

执行这条命令后反馈安装失败，重新执行 `configure` 仍找不到 `zlib`

先执行

 ```bash
 rm -f /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg
 ```
 
  再执行 

  ```bash
  xcode-select --install
  ```
再执行一次

```bash
installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
```

  成功