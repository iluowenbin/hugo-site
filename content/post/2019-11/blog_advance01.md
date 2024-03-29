---
title: "Hugo博客进阶(一)"
date: 2019-11-04T16:24:14+08:00
draft: false
tags: ["Hugo","Github Pages","DOMAIN","DNS"]
tags_weight: 66
categories: ["Blog"]
keywords: [ "Hugo", "DOMAIN","DNS"]
summary: "Github Pages配置个人域名，DNS解析配置"
---
### 前言
本文介绍了如何将自己的静态网站托管到github后，在阿里云上购买个人域名并利用免费的DNS服务在github Pages上以https协议加载个人域名。

#### 1.前提
- 保证访问https://username.github.io 能够正确访问你的网站
- 如果你还没有试过使用Hugo+github Pages搭建博客，欢迎查看我的上一篇教程https://luowenbin.site/post/2019-11-03-1/

#### 2.购买域名
- 前往https://account.aliyun.com/ 挑选域名，推荐暂时购买1年，后续网站稳定了再购买5年或者10年
- 域名最好买可以备案的域名，后续可以省很多事
- 购买域名前需要验证邮箱，实名认证，阿里十分迅速，大约5分钟可以搞掂

#### 3.配置个人域名到githubPages
- 添加CNAME文件到/static目录，以后构建时就会自动生成一份到/docs，文件内容即为domain
```
username.site
```
- 构建hugo并提交
- 到settting页面检查是否自动加载了domain
![image.png](https://i.loli.net/2019/11/05/j6bNMmzq5Rsa2LK.png)
- 如果失败，检查一下/docs目录下是否有CNAME文件

#### 4.添加DNS解析
- 重复ping一下你的username.github.io，得到2个以上ip
- 到域名控制台进入解析设置，添加3个记录
![image.png](https://i.loli.net/2019/11/05/luByswWTp1L2afo.png)
- 1-2分钟后查看githubPages配置，已经被解析成功
![image.png](https://i.loli.net/2019/11/05/TGBHhUOplPv7mW6.png)
- 开启https
![image.png](https://i.loli.net/2019/11/05/enWzcgyE9x18aOR.png)
- 如果提示失败，请检查下域名是否正常状态；添加的记录ip是否正确

#### 5.打开个人域名
- 点击https://luowenbin.site/ 访问成功
