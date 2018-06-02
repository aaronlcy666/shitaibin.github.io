---
title: 重新安装Hexo博客的流程
date: 2018-06-02 08:45:31
tags: ['Hexo']
---

# 流程
1. 安装Hexo。
1. 新建文件夹`blog`，然后进入。
1. `hexo init`。

<!--more-->


1. `hexo new 'find posts directory'`，记录下新的post地址
1. 把备份的md文件放到新的post的地址，删除掉上一步新建的文件。
1. 把备份的`_config.yaml`配置文件中**有用的选项**放到新的配置文件中，不要覆盖进新版本的Hexo。
1. 建立`hexo_resource`分支，该分支用来存放hexo的配置和博文等文件。master分支留着给博客使用，存放的是博客的静态文件。
1. `hexo g && hexo s`，本地预览效果。
1. 执行`hexo d`，生成的博客文件会上传到Github。
1. 在`hexo_resource`分支下工作即可，写完文章后，执行`sh deploy_and_backup_hexo_br.sh`，备份好分支，博客推送到远端。

# 脚本

- deploy_and_backup_hexo_br.sh:

```
hexo clean
git add .
git commit -m 'auto backup'
git push origin hexo_resource
hexo d
```

# 初次搭建Hexo

- [Github-Pages-Hexo部署总结](/2015/05/01/Github-Pages-Hexo部署总结/)