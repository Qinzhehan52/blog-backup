---
layout: macos
title: charlies代理问题
date: 2019-10-16 18:35:26
tags:
categories:
    - 软件使用
---
## 背景

同时使用 `shadowsocks(r)/v2ray` 与 `charles` 时，`charles map remote` 功能工作不正常。

## 解决方案

1. 手机/mac 关闭 `shadowsocks(r)/v2ray`, 相当于去掉这两个软件设置的系统代理

2. 打开 `charles`, 确认 `enable transparent HTTP proxying/ macOS proxy` 功能打开

3. 确认手机`wifi-高级-代理` 或mac `网络偏好设置-高级-代理` 相关配置正常，如自动代理配置、网页代理、安全网页代理