---
title: "什么是RPCX？"
date: 2019-11-11T18:15:49+08:00
draft: true
tags: ["go","rpcx"]
tags_weight: 66
categories: ["Learning"]
keywords: ["rpc","rpcx","go"]
summary: "了解一下RPCX框架"
---
#### 什么是rpc
远程过程调用（英语：Remote Procedure Call，缩写为 RPC）是一个计算机通信协议。该协议允许运行于一台计算机的程序调用另一台计算机的子程序，
而程序员无需额外地为这个交互作用编程。如果涉及的软件采用面向对象编程，那么远程过程调用亦可称作远程调用或远程方法调用，例：Java RMI。

简单地说就是能使应用像调用本地方法一样的调用远程的过程或服务。很显然，这是一种client-server的交互形式，调用者(caller)是client,
执行者(executor)是server。典型的实现方式就是request–response通讯机制。

RPC 是进程之间的通讯方式(inter-process communication, IPC), 不同的进程有不同的地址空间。
如果client和server在同一台机器上，尽管物理地址空间是相同的，但是虚拟地址空间不同。
如果它们在不同的主机上，物理地址空间也不同。

一个正常的RPC过程可以分成下面几步：
    - client调用client stub，这是一次本地过程调用
    - client stub将参数打包成一个消息，然后发送这个消息。打包过程也叫做 marshalling
    - client所在的系统将消息发送给server
    - server的系统将收到的包传给server stub
    - server stub解包得到参数。 解包也被称作 unmarshalling
    - 最后server stub调用服务过程. 返回结果按照相反的步骤传给client

RPC只是描绘了 Client 与 Server 之间的点对点调用流程，包括 stub、通信、RPC 消息解析等部分，在实际应用中，
还需要考虑服务的高可用、负载均衡等问题，所以产品级的 RPC 框架除了点对点的 RPC 协议的具体实现外，
还应包括**服务的发现与注销**、提供服务的多台 Server 的**负载均衡**、**服务的高可用**等更多的功能。
目前的 RPC 框架大致有两种不同的侧重方向，一种偏重于**服务治理**，另一种偏重于**跨语言调用**。

服务治理型的 RPC 框架有 Dubbo、DubboX、Motan 等，这类的 RPC 框架的特点是功能丰富，提供高性能的远程调用以及服务发现及治理功能，
适用于大型服务的微服务化拆分以及管理，对于特定语言（Java）的项目可以十分友好的透明化接入。但缺点是语言耦合度较高，跨语言支持难度较大。

跨语言调用型的 RPC 框架有 Thrift、gRPC、Hessian、Hprose 等，这一类的 RPC 框架重点关注于服务的跨语言调用，
能够支持大部分的语言进行语言无关的调用，非常适合于为不同语言提供通用远程服务的场景。但这类框架没有服务发现相关机制，
实际使用时一般需要代理层进行请求转发和负载均衡策略控制。

#### 什么是rpcx
rpcx 属于服务治理类型，是一个基于 Go 开发的高性能的轻量级 RPC 框架，Motan 提供了实用的服务治理功能和基于插件的扩展能力。

rpcx使用Go实现，适合使用Go语言实现RPC的功能。
    - 基于net/rpc,可以将net/rpc实现的RPC项目轻松的转换为分布式的RPC
    - 插件式设计，可以配置所需的插件，比如服务发现、日志、统计分析等
    - 基于TCP长连接,只需很小的额外的消息头
    - 支持多种编解码协议，如Gob、Json、MessagePack、gencode、ProtoBuf等
    - 服务发现：服务发布、订阅、通知等，支持多种发现方式如ZooKeeper、Etcd等
    - 高可用策略：失败重试（Failover）、快速失败（Failfast）
    - 负载均衡：支持随机请求、轮询、低并发优先、一致性 Hash等
    - 规模可扩展，可以根据性能的需求增减服务器
    - 其他：调用统计、访问日志等

#### rpcx架构
rpcx中有服务提供者 RPC Server，服务调用者 RPC Client 和服务注册中心 Registry 三个角色。
    - Server 向 Registry 注册服务，并向注册中心发送心跳汇报状态(基于不同的registry有不同的实现)
    - Client 需要向注册中心查询 RPC 服务者列表，Client 根据 Registry 返回的服务者列表，选取其中一个 Sever 进行 RPC 调用
    - 当 Server 发生宕机时，Registry 会监测到服务者不可用(zookeeper session机制或者手工心跳)，Client 感知后会对本地的服务列表作相应调整。client可能被动感知(zookeeper)或者主动定时拉取
    - 可选地，Server可以定期向Registry汇报调用统计信息，Client可以根据调用次数选择压力最小的Server


rpcx基于Go net/rpc的底层实现， Client和Server之间通讯是通过TCP进行通讯的，它们之间通过Client发送Request，Server返回Response实现。

Request和Response消息的格式都是Header+Body的格式。Header和Body具体的格式根据编码方式的不同而不同，可以是二进制，也可以是结构化数据如JSON。

#### rpcx的特性
1.1 序列化编码
rpcx当前支持多种序列化/反序列化的方式，可以根据需求选择合适的编码库。
|特性  |功能描述|
|  ----  | ----  |
|gob|官方提供的序列化方式，基于一个包含元数据的流|
|jsonrpc|也是官方提供的编码库，以JSON格式传输|
|msgp|类似json格式的编码，但是更小更快，可以直接编码struct|
|gencode|一个超级快的序列化库，需要定义schema,但是定义方式和struct类似|
|protobuf| Google推出的广受关注的序列化库，推荐使用gogo-protobuf，可以获得更高的性能|
