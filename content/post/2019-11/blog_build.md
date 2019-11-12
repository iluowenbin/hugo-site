---
title: "快速利用Hugo搭建个人博客"
date: 2019-11-03T23:54:09+08:00
draft: false
tags: ["Hugo","Github Pages"]
tags_weight: 66
categories: ["Blog"]
keywords: [ "Hugo", "Blog" ]
summary: "从零开始使用Hugo和Github Pages搭建静态博客"
---
### 前言
踩了一天的坑总算是把博客给搭了起来，看完了各类搭建教程，但每篇总是会少了点东西，本文力争成为全网最舒服的Hugo博客搭建姿势。
#### 1.安装hugo
- 浏览 Hugo 官方的安装指南，浏览了解基础就可以了，可跳过；
- mac系统建议安装Homebrew，已安装可以跳过，打开终端；

``` shell script
brew install hugo
hugo version
```
- 如果是windows系统，则到此处下载Hugo https://github.com/gohugoio/hugo/releases
- 推荐创建好目录D:/Hugo/bin,D:/Hugo/Blog
- 将下载的zip文件解压到bin目录下，并将hugo.exe添加到环境变量path中
```shell script
$Env:path=$Env:Path+";D:/Hugo/bin"
$Env:path
hugo help
```
- hugo help输出没有问题说明安装成功啦

#### 2.新建一个网站项目
- 创建网站根目录，后续主要命令都在此目录下
``` shell script
cd ~/Blog
hugo new site hugo-site
```

#### 3.下载themes并设置
- 推荐even主题，直接套用config框架，酥胡～
``` shell script
cd ~/Blog/hugo-site
mkdir themes
git clone https://github.com/olOwOlo/hugo-theme-even themes/even
rm config.toml
cp themes/even/exampleSite/config.toml . # 直接替换config文件，后续可以慢慢修改配置
```

#### 4.新建一篇文章
- new命令会直接在content目录下创建md文件，并设置好默认的head
- 部分主题是posts，部分是post，如果这里错误可能会导致网站首页没有文章目录
``` shell script
cd ~/Blog/hugo-site
hugo new post/my-first-post.md
```

#### 5.预览并构建网站
- 预览推荐指定目录到dev文件夹，方便区分开发布文件夹
- -D参数表示草稿md也会展示出来，默认不展示草稿文件（是否草稿文件由md文件里的draft头确定）
- -t参数可以指定theme
- http://localhost:1313 preview
``` shell script
hugo server -D -d dev
```
- 预览后没有问题再构建网站，否则再修改下markdown文件，注意修改draft为false
- 构建网站推荐指定到docs目录，方便后续发布到github Pages
- 构建完后会在/docs中看到my-first-post文件夹
``` shell script
hugo -d docs
```

#### 6.添加github仓库
- 创建github账号 <https://pages.github.com>
- 新建一个代码仓库repository，库名为 username.site
- 初始化git仓库，cat后可以看到分支和远端信息
``` shell script
cd ~/Blog/hugo-site
git init
git remote add origin git remote add origin git@github.com:iluowenbin/iluowenbin.site.git
cat .git/config
```
- 修改.gitignore文件
```shell script
/dev
/themes
```
- 提交并推送github
```shell script
git add .
git commit -m "init site"
git push -u origin master
```

#### 7.配置github Pages
- 打开username.site的setting，下滑找到github Pages配置
- 将Source配置为master branch/docs folder
![image.png](https://i.loli.net/2019/11/05/cHPxYajoOGqytX5.png)

点击 <https://username.github.io> 大功告成
