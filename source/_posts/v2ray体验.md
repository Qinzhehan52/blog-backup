title:  v2ray体验

## 起因

迫于ssr遭遇gfw特殊照顾，听说v2ray效果不错，来体验下风味不同的科学上网姿势。

## 安装

### 本人环境

Linux ubuntu-*** 4.15.0-34-generic #37-Ubuntu SMP Mon Aug 27 15:21:48 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux

### 安装过程

脚本下载一键安装：

```bash
root@ubuntu-***:~# wget https://install.direct/go.sh
--2018-11-27 09:26:40--  https://install.direct/go.sh
Resolving install.direct (install.direct)... 2606:4700:30::681b:af47, 2606:4700:30::681b:ae47, 104.27.175.71, ...
Connecting to install.direct (install.direct)|2606:4700:30::681b:af47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/plain]
Saving to: ‘go.sh’

go.sh                   [ <=>                ]  13.32K  --.-KB/s    in 0s

2018-11-27 09:26:41 (79.6 MB/s) - ‘go.sh’ saved [13636]

root@ubuntu-***:~# bash go.sh
Installing V2Ray v4.6.0 on x86_64
Downloading V2Ray.
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   608    0   608    0     0   2620      0 --:--:-- --:--:-- --:--:--  2620
100 11.9M  100 11.9M    0     0  18.4M      0 --:--:-- --:--:-- --:--:-- 31.1M
Extracting V2Ray package to /tmp/v2ray.
Archive:  /tmp/v2ray/v2ray.zip
  inflating: /tmp/v2ray/config.json
   creating: /tmp/v2ray/doc/
  inflating: /tmp/v2ray/doc/readme.md
  inflating: /tmp/v2ray/geoip.dat
  inflating: /tmp/v2ray/geosite.dat
   creating: /tmp/v2ray/systemd/
  inflating: /tmp/v2ray/systemd/v2ray.service
   creating: /tmp/v2ray/systemv/
  inflating: /tmp/v2ray/systemv/v2ray
  inflating: /tmp/v2ray/v2ctl
 extracting: /tmp/v2ray/v2ctl.sig
  inflating: /tmp/v2ray/v2ray
 extracting: /tmp/v2ray/v2ray.sig
  inflating: /tmp/v2ray/vpoint_socks_vmess.json
  inflating: /tmp/v2ray/vpoint_vmess_freedom.json
PORT:17230
UUID:5da1587f-4685-443a-9e07-4dd681f8c87c
Created symlink /etc/systemd/system/multi-user.target.wants/v2ray.service → /etc/systemd/system/v2ray.service.
```

## 配置

### 协议

VMess 协议是由 V2Ray 原创并使用于 V2Ray 的加密传输协议，如同 Shadowsocks 一样为了对抗墙的[深度包检测](https://zh.wikipedia.org/wiki/%E6%B7%B1%E5%BA%A6%E5%8C%85%E6%A3%80%E6%B5%8B)而研发的。在 V2Ray 上客户端与服务器的通信主要是通过 VMess 协议通信。

本小节给出了 VMess 的配置文件，其实也就是服务器和客户端的基本配置文件，这是 V2Ray 能够运行的最简单的配置。

V2Ray 使用 inbound(传入) 和 outbound(传出) 的结构，这样的结构非常清晰地体现了数据包的流动方向，同时也使得 V2Ray 功能强大复杂的同时而不混乱，清晰明了。形象地说，我们可以把 V2Ray 当作一个盒子，这个盒子有入口和出口(即 inbound 和 outbound)，我们将数据包通过某个入口放进这个盒子里，然后这个盒子以某种机制（这个机制其实就是路由，后面会讲到）决定这个数据包从哪个出口吐出来。以这样的角度理解的话，V2Ray 做客户端，则 inbound 接收来自浏览器数据，由 outbound 发出去(通常是发到 V2Ray 服务器)；V2Ray 做服务器，则 inbound 接收来自 V2Ray 客户端的数据，由 outbound 发出去(通常是如 Google 等想要访问的目标网站)。

