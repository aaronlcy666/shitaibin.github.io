---
title: 让镜像飞，加速你的开发
date: 2019-07-13 11:15:51
tags: ['Linux', 'Mac']
---

由于你知我知的网络原因，开发者遇到了以下问题：

1. brew/apt-get/yum等安装软件慢、更新慢
1. docker下载镜像慢
1. go get某些package无法访问、超时
1. ...

怎么解决？

1. 挂代理，实现科学上网
2. 换镜像，曲线救国

镜像都在国内，所以镜像效果比代理好。

换代理请看[让终端科学上网](http://lessisbetter.site/2018/09/06/Science-and-the-Internet/)。

接下来看几个常用的镜像。

## Linux发行版镜像

[阿里镜像首页](https://opsx.alibaba.com/mirror)列出了所有发行版的镜像状态，以及【帮助】，展示了如何更换源。

这里不仅包含了发行版的镜像，还有homebrew、docker，但我认为这2个阿里的镜像不太好用，但列出来了。

## Brew镜像

你需要[让Homebrew飞](http://lessisbetter.site/2019/07/13/better-brew/)。

## Docker镜像

看如何配置[Docker镜像加速器](https://yeasy.gitbooks.io/docker_practice/install/mirror.html)。

推荐使用七牛或DaoCloud的镜像。

