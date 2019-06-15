---
title: 科学上网n步曲
date: 2019-06-12 14:02:50
tags:
---
## 一. shadowsockr (socks5代理) 搭建
参考博客[一键脚本搭建SS/搭建SSR服务并开启BBR加速
](https://www.flyzy2005.com/fan-qiang/shadowsocks/install-shadowsocks-in-one-command/)

**访问需要配置host** `104.27.133.214 www.flyzy2005.com`

1. 下载一键安装脚本 `git clone -b master https://github.com/flyzy2005/ss-fly`
2. 运行安装脚本	 *ubuntu系统目前默认shell是`dash`,注意切换*
```bash
$ ss-fly/ss-fly.sh -ssr
```

<!-- more -->

3. 按照提示输入所需参数即可，完成后终端显示内容如下
```
Congratulations, ShadowsocksR server install completed!
Your Server IP        :你的服务器ip
Your Server Port      :你的端口
Your Password         :你的密码
Your Protocol         :你的协议
Your obfs             :你的混淆
Your Encryption Method:your_encryption_method
 
Welcome to visit:https://shadowsocks.be/9.html
Enjoy it!
```
4. 一些管理命令
```bash
# ssr略有不同 注意调整
#启动：
/etc/init.d/shadowsocks start
#停止：
/etc/init.d/shadowsocks stop
#重启：
/etc/init.d/shadowsocks restart
#状态：
/etc/init.d/shadowsocks status
 
#配置文件路径：
/etc/shadowsocks.json
#日志文件路径：
/var/log/shadowsocks.log
#代码安装目录：
/usr/local/shadowsocks
```

## 二. socks5 转 http 代理
### cow
cow项目首页具有完善的wiki，可以参考以ss提供的socks5代理搭建http代理[cow on github](https://github.com/cyfdecyf/cow)

### polipo
[mac 安装polipo和使用](https://zxc0328.github.io/2017/03/26/proxy-for-terminal/)

#### 补充内容 
自定义polipo运行的端口，类似文中修改parentrProxy
```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>homebrew.mxcl.polipo</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/opt/polipo/bin/polipo</string>
      <string>socksParentProxy=127.0.0.1:1080</string>
      <!-- 修改运行端口 -->
      <string>proxyPort=7777</string>
    </array>
    <!-- Set `ulimit -n 65536`. The default macOS limit is 256, that's
         not enough for Polipo (displays 'too many files open' errors).
         It seems like you have no reason to lower this limit
         (and unlikely will want to raise it). -->
    <key>SoftResourceLimits</key>
    <dict>
      <key>NumberOfFiles</key>
      <integer>65536</integer>
    </dict>
  </dict>
</plist>
```

## 三. 终端使用代理

### 终端中代理http请求
#### 临时使用
proxychains 其实并不能把socks5代理转成http代理，但是要把他写在前面。对于npm git wget等操作，使用proxychains即可使其通过socks5代理成功访问目标地址。其原理是Hook 了 sockets 相关的操作，让普通程序的 sockets 数据走 SOCKS/HTTP 代理。

##### mac安装proxychains4
1. 重启到安全模式，终端执行

```bash
csrutil disable
```

2. 重启，终端执行

```bash
brew install proxychains-ng #安装
```

3. 修改配置,其中socks5代理可以换成`cow`或`polipo`的http代理
```
cp /usr/local/etc/proxychains.conf ~/.proxychains/proxychains.conf
echo 'socks5  127.0.0.1 1086' >> ~/.proxychains/proxychains.conf
```

**NOTICE: go get操作使用`proxychains`会报错**

#### 长期使用

## shadowsocksr + proxychains + polipo 解决方案
这套方案的好处是具备 http 和 socks5 两套代理，基本可以应对各种情况下的需求，尤其是本地的 golang 开发环境比较特殊，不适合安装`cow`

### 几条方便科学上网的alias

```bash
alias fuckgfw="export http_proxy=127.0.0.1:8123 https_proxy=127.0.0.1:8123&& echo '> You are out!'"
alias unfuckgfw="unset http_proxy https_proxy && echo '> Welcome inside ;)'"
alias myip="curl cip.cc"
alias fq="proxychains4"
```