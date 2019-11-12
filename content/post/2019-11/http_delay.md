---
title: "windows和linux环境下网络延迟模拟"
date: 2019-11-12T11:05:37+08:00
draft: false
tags: ["http","延迟"]
tags_weight: 66
categories: ["Learning"]
keywords: ["http","网络延迟","clumsy"]
summary: "利用tc和clumsy模拟网络延迟"
---
#### **前言**
web开发时，应该经常会遇到一些需要mock的场景，简单的时候直接写一个http服务就好，返回需要的数据即可，但需要测试多种异常情况时，就需要自己模拟一些网络异常的场景,本文主要尝试的是模拟网络延迟场景。

#### **网络异常的种类**
   - 网络延迟：当网络信息流过大时，可能导致设备反应缓慢，造成数据传输延迟；
   - 网路掉包：网路掉包是在数据传输的过程中，数据包由于各种原因在信道中丢失的现象；
   - 网络节流：当数据传输量达到网络带宽上限时，数据包可能会被设备拦截下来在之后发出；
   - 网络重发：当网络不稳定是可能会导致发送端判断数据包丢失导致部分数据包重发；
   - 数据乱序：当数据传输有可能出现数据包到达接收端时间不一致，导致数据包乱序问题；
   - 数据篡改：数据传输的过程中可能出现数据被连接篡改的情况.

#### **windows环境下模拟网络延时**

windows下使用clumsy来进行网络异常的模拟，前往 https://jagt.github.io/clumsy/cn/download 下载clumsy工具，
仔细阅读文档后开始使用.


下载压缩包后解压到任意路径后以管理员身份双击 clumsy.exe 执行,打开后可以看到clumy界面
   ![image.png](http://q0u7r88gy.bkt.clouddn.com/1573529681%281%29.png)
   
   - filtering可以接收协议类型，端口号，接收还是发送等条件过滤;
   - 延迟(Lag)，把数据包缓存一段时间后再发出，这样能够模拟网络延迟的状况，本文主要使用这个;
   - 掉包(Drop)，随机丢弃一些数据;
   - 节流(Throttle)，把一小段时间内的数据拦截下来后再在之后的同一时间一同发出去;
   - 重发(Duplicate)，随机复制一些数据并与其本身一同发送;
   - 乱序(Out of order)，打乱数据包发送的顺序;
   - 篡改(Tamper)，随机修改小部分的包裹内容;

将lag设为1000ms，点击start按钮，等待按钮变成stop，工具使用成功

#### **linux环境下模拟网络延时**

netem 是Linux 2.6 及以上内核版本提供的一个网络模拟功能模块。该功能模块可以用来在性能良好的局域网中,模拟出复杂的互联网传输性能,
诸如低带宽、传输延迟、丢包等等情况。使用 Linux 2.6 (或以上) 版本内核的很多发行版 Linux 都开启了该内核功能,
比如 Fedora、Ubuntu、Redhat、OpenSuse、CentOS、Debian 等等。 
tc 是Linux系统中的一个工具,全名为 traffic control(流量控制)。tc 可以用来控制 netem 的工作模式,也就是说,
如果想使用 netem ,需要至少两个条件,一个是内核中的 netem 功能被包含,另一个是要有 tc.

使用ifconfig查看网卡信息，eth0为网卡设备标识
![image.png](http://q0u7r88gy.bkt.clouddn.com/1573537314%281%29.jpg)
使用tc命令模拟网络时延

    tc qdisc add dev eth0 rootnetem delay 1000ms
    
使用其他命令来模拟网络异常

   - 网络丢包,将 eth0 网卡的传输设置为随机丢掉 1% 的数据包
     ```
     tc qdisc add dev eth0 root netem loss 1%
     ```
   - 数据包重复,将 eth0 网卡的传输设置为随机产生 1% 的重复数据包
     ```
     tc qdisc add dev eth0 root netem duplicate 1%
     ``` 
   - 数据包损坏,将 eth0 网卡的传输设置为随机产生 0.2% 的损坏的数据包
     ```
     tc qdisc change dev eth0 root netem delay 10ms reorder 25% 50%
     ```
   - 查看已经配置的网络条件
     ```
     tc qdisc show dev eth0
     ```
   - 删除配置,将add改成del即可
     ```
     tc qdisc del dev eth0 root netem duplicate 1%
     ```

#### **测试**
开启单元测试
![image.png](http://q0u7r88gy.bkt.clouddn.com/1573530536%281%29.jpg)
结果成功捕捉到 java.net.ConnectException 异常.

参考：

https://www.jianshu.com/p/b51f8de58c40

https://jagt.github.io/clumsy/cn/download

