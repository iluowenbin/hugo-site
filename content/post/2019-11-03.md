---
title: "Hugo博客进阶(二)"
date: 2019-11-04T20:03:20+08:00
draft: false
tags: ["Hugo","Github Pages","gitment"]
tags_weight: 66
categories: ["Blog"]
keywords: [ "Hugo", "DOMAIN","DNS"]
summary: "利用gitment给博客添加评论功能"
---
### 前言
Gitment 基于 GitHub Issues 的评论系统。支持在前端直接引入，不需要任何后端代码。可以在页面进行登录、查看、评论、点赞等操作，同时有完整的 Markdown / GFM 和代码高亮支持。尤为适合各种基于 GitHub Pages 的静态博客或项目页面。

#### 1.申请gitment的Oauth
- 点击https://github.com/settings/applications/new 注册新的oauth id
- Homepage URL 和 Authorization callback URL 填写网站home就好
- 注册完后会得到一个clientId和clientSecret
![image.png](https://i.loli.net/2019/11/05/WIpuv2mrVRwKZXl.png)

#### 2.填写config.toml
- 如果你用的是even主题，直接将信息填写进去就好了
```
[params]
    [params.gitment]          
        owner = "iluowenbin"              
        repo = "hugo-site"               
        clientId = "xxxxx"           
        clientSecret = "xxxxx"
```

#### 3.初始化gitment
- 未初始化之前会有init提醒
- 登录github并init评论，之后其他用户就可以评论你的博客啦
![image.png](https://i.loli.net/2019/11/05/opWvcHOBEaVz9GS.png)
