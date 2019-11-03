# iluowenbin.github.io

#### 修改themes
```
cd themes
git clone https://github.com/kakawait/hugo-tranquilpeak-theme.git tranquilpeak 
vim config.toml
theme = "tranquilpeak"
```

#### 调试hugo
```
hugo new post/my-first-post.md
hugo server -D  # http://localhost:1313/
hugo
```

#### 推送md
```
git pull
git add .
git commit -m "msg"
git push -u origin master
```
