---
title: cmux 多协议服务失败debug记录
date: 2019-06-16 11:26:27
tags:  
    - golang 
    - cmux
categories: 
    - golang
---
## cmux 是什么
> cmux is a generic Go library to multiplex connections based on their payload. Using cmux, you can serve gRPC, SSH, HTTPS, HTTP, Go RPC, and pretty much any other protocol on the same TCP listener.

## cmux 使用过程中的问题

**现象**：

我使用一个tcp链接，同时支持 `websocket`, `http`, `grpc` 协议，发现 `websocket` 服务总是握手失败，而且每次都会打一条 `http` 请求的日志。

**分析**: 

`websocket` 协议握手过程客户端主要是在 `http header` 加入 `Upgrade: websocket`，服务端使用 `cmux` 也是通过匹配这条`http header` 实现。

出现问题的 `golang` 代码如下：

```golang
tcpm := cmux.New(l)
grpc1 := tcpm.MatchWithWriters(cmux.HTTP2MatchHeaderFieldPrefixSendSettings("content-type", "application/grpc"))
http1 := tcpm.Match(cmux.HTTP1Fast())
http2 := tcpm.Match(cmux.HTTP2())
wsl := tcpm.Match(cmux.HTTP1HeaderField("Upgrade", "websocket"))

//开始服务
go serveGPRC(grpc1)
go serveWS(wsl)
go serveHTTP(http1)
go serveHTTP(http2)
```

对比 `cmux` 库自带的 example 没有很大的区别, **但是通过注释我们可以注意到， `Match` 的顺序很重要**

仔细对比之后发现的确两段 `Match` 的顺序有所不同，无论是 `grpc` 请求还是 `websocket` 的握手请求，都只是特殊化的 `http` 请求，使用 `cmux` 时要注意 `Match` 的顺序，避免服务端将 `grpc` 请求和  `websocket` 的握手请求当做 `http2` `http1` 请求处理。

```golang
m := cmux.New(l)

// We first match the connection against HTTP2 fields. If matched, the
// connection will be sent through the "grpcl" listener.
grpcl := m.Match(cmux.HTTP2HeaderFieldPrefix("content-type", "application/grpc"))
//Otherwise, we match it againts a websocket upgrade request.
wsl := m.Match(cmux.HTTP1HeaderField("Upgrade", "websocket"))

// Otherwise, we match it againts HTTP1 methods. If matched,
// it is sent through the "httpl" listener.
httpl := m.Match(cmux.HTTP1Fast())
// If not matched by HTTP, we assume it is an RPC connection.
rpcl := m.Match(cmux.Any())

// Then we used the muxed listeners.
go serveGRPC(grpcl)
go serveWS(wsl)
go serveHTTP(httpl)
go serveRPC(rpcl)
```