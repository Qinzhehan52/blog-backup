---
title: https 从一次SSL证书验证失败讲起
date: 2026-02-14 18:15:43
tags:
---

## 报警响起，但是…?

日常我们的KA会上传菜单，其中自然包含很多菜品的图片 ，某天，后天检测到大量的图片拉取失败。

随便找到一张图片的URL，在服务器上进行请求，出现如下错误。

```jsx
curl: (60) SSL certificate problem: certificate has expired
```

然而使用 MacBook 本地 `curl` 是成功的，在chrome浏览器也实验成功。

观察可以发现，在服务器上 ping 对方 cdn 域名，和在mac 本地 ping 对方 cdn 域名，返回的 IP 是不同的，难道是 cdn 问题？

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image.png?raw=true)

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%201.png?raw=true)

那假如我们在 MacBook 修改 Hosts文件强行将解析指向 IP 呢？ 也是成功的。

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%202.png?raw=true)

有的同学认为，SSL证书验证，和客户端没有关系，一定是服务端的问题，这种观点正确吗 ？

## 回顾 https ，也许是因为它？

我们想象一下，如果我们自己去设计 https ，在验证一个我们不认识的站点的证书时，大概是要依赖一个权威机构的给我们的"名单"，一旦这个"名单"不再准确时，就会发生误判。而事实也的确如此。

SSL证书验证的流程是 :

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%203.png?raw=true)

在3.过程中，客户端验证服务器的证书，检查：

- 证书是否由受信任的 CA 签发
- 证书是否在有效期内
- 证书上的公钥是否与服务器的主机名匹配

而为了完成这些验证，客户端需要有一个预安装的受信任的根证书列表。这些根证书由证书颁发机构（CA）签发，CA 是负责验证和颁发数字证书的机构。

由于不同的操作系统和浏览器在其信任存储中维护各自的根证书列表，我们在使用不同的客户端访问相同的https资源时，会得到不同的验证结果。

举个例子：如果我们手头有事多年前的Chrome浏览器，它大概率是不能访问目前很多合法的https网络服务的，因为他的根证书列表太老了，不包含目前很多流行的根证书。

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%204.png?raw=true)

难道说，我们这次也遇到了这个问题？

## 快速止血

快速恢复的方案大概有三个：

1. 使用 `InsecureSkipVerify` ，跳过 SSL 验证；
2. 更新系统的CA证书列表；
3. 不更新系统的CA证书列表而是在 golang 代码中指定 CA 证书列表。

对比方案优劣，第二个方案被我们首先放弃，更新系统CA证书是一个系统级操作，其影响面是更大的，且运维操作的步骤也非常繁琐。

使用方案三，如果我们可以找到可信的CA证书列表，方案三更适宜作为长期方案，但寻找可信CA证书列表以及进行代码开发部署都不是短时间内最好的选择。

幸运的是，之前的开发同学由于担忧第三方图床技术良莠不齐，已经在代码中实现了通过 `apollo` 配置控制指定域名的图床使用`InsecureSkipVerify` 的功能。通过修改配置我们实现快速止血。

## 回到现场

为了探究问题的根源，并且得到长期的解决方案，我们继续对这个图床进行研究。

（此处将使用与当时同样使用了Let's Encrypt证书的另一网站继续演示）

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%205.png?raw=true)

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%206.png?raw=true)

如此巧合，我们要访问的网站，***最近更新了SSL证书***，使用了 Let's Encrypt 颁发的证书，这家 CA 频发兼容性问题。

在Let's Encrypt官网，一份公告说明最近确实发生了些什么。

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%207.png?raw=true)

使用Chrome查看该图床证书的详细信息，可以看到其证书CA确实是ISRG Root X1。

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/6009e546-24f4-4235-aeea-9134f84bf230.png?raw=true)

不同的软件会使用CA证书列表进行SSL验证，比如 `curl` 使用 `nss`， 而 `wget` 使用 `openssl`，我们运行在服务器上的 golang 服务 `http.Client` 默认使用系统 CA 证书来验证 SSL 证书。

那么我们的服务器到底对 ISRG Root X1 兼容行如何？

我们使用的 docker 镜像基于 CentOS7.9，实际是一个非常老的版本，其内置的 `curl` `wget` 以及 `ca-certificates` 版本都很陈旧，对于较新的CA机构，兼容性比较差。

下面的图片分别展示了`curl` `wget`  `ca-certificates` 版本依赖的 `nss` `openssl` 版本。

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%208.png?raw=true)

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%209.png?raw=true)

![image.png](https://github.com/Qinzhehan52/blog-backup/blob/master/source/images/image%2010.png?raw=true)

在 Let' Encrypt 官网的兼容性文档中，明确了支持 ISRG Root X1 的各种平台版本，其中 `NSS` > 3.26, 明显我们的镜像不满足，对于 RHEL >= 6.10, 7.4 ([with updates applied](https://src.fedoraproject.org/rpms/ca-certificates/c/02204a071d2effe7cdb840c1a2763bcdc396c4be)), 8+ 这一项，我们进入后可以看到

> Platforms that trust ISRG Root X1
>
> - Windows >= [XP SP3, Server 2008](https://learn.microsoft.com/en-us/security/trusted-root/participants-list) (unless [Automatic Root Certificate Updates](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-r2-and-2008/cc733922%28v=ws.10%29) have been disabled)
> - macOS >= [10.12.1 Sierra](https://support.apple.com/en-us/103425)
> - iOS >= [10](https://support.apple.com/en-us/HT207177)
> - Android >= [7.1.1](https://android.googlesource.com/platform/system/ca-certificates/+/android-7.1.1_r15)
> - Firefox >= [50.0](https://bugzilla.mozilla.org/show_bug.cgi?id=1204656)
> - Ubuntu >= [12.04 Precise Pangolin](https://launchpad.net/ubuntu/+source/ca-certificates/20161102) (with updates applied)
> - Debian >= [8 / Jessie](https://tracker.debian.org/news/812114/accepted-ca-certificates-20161102-source-all-into-unstable/) (with updates applied)
> - RHEL >= 6.10, 7.4 ([with updates applied](https://src.fedoraproject.org/rpms/ca-certificates/c/02204a071d2effe7cdb840c1a2763bcdc396c4be)), 8+
> - Java >= [7u151](https://www.oracle.com/java/technologies/javase/7u151-relnotes.html), [8u141](https://www.oracle.com/java/technologies/javase/8u141-relnotes.html), [9+](https://www.oracle.com/java/technologies/javase/9-all-relnotes.html#JDK-8177539)
> - NSS >= [3.26](https://nss-crypto.org/reference/security/nss/legacy/nss_releases/nss_3.26_release_notes/index.html)
> - Chrome >= [105](https://chromium.googlesource.com/chromium/src/+/main/net/data/ssl/chrome_root_store/faq.md#when-are-these-changes-taking-place) (earlier versions use the operating system trust store)
> - PlayStation >= [PS4 v8.0.0](https://web.archive.org/web/20210306180757/https://www.sie.com/content/dam/corporate/jp/guideline/PS4_Web_Content-Guidelines_e.pdf)

而 `openssl` 1.0x版本不支持 ISRG Root X1 的 case，在 stackOverFlow medium askUbuntu Github 等技术网站也有无数的吐槽。

到此，可以得出结论，我们的服务器 golang 服务，`wget` `curl`，均不支持 ISRG Root X1。

## 引申阅读

[**苹果大幅缩短安全证书有效期引发众怒**](https://www.secrss.com/articles/71306)

**突发事件！Apple Music等核心服务因SSL/TLS证书过期发生中断**

## 总结

本篇通过一个案例，我们回顾了下 https 的验证流程，了解了工具的异同、软件版本的差异，带来的SSL验证结果的不同。

软件工程、网络工程发展至今，有了很多规范和广泛被应用的基础建设，然而这些都是人的创造物，没有100%的正确率。我们大概率不是 0 day 的发现者，但是一根绳可能以 n 种方式绊倒不同的人。

### 经验教训

- 在使用第三方服务时，要充分考虑证书兼容性问题
- 系统基础设施要保持更新，避免使用过于陈旧的版本
- 在开发时预留降级和配置开关，方便应急处理
