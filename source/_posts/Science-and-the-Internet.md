---
title: 让终端科学上网
date: 2018-09-06 20:35:40
tags: ['shadowsocks']
---



# 前言

科学上网，为祖国建设添砖加瓦。

- 教你浏览器科学上网，获取学习资料。
- 教你终端科学上网，获取学习资料。



# 软件列表

- [Shadowsocks](https://github.com/shadowsocks/shadowsocks-iOS/wiki/Shadowsocks-for-OSX-%E5%B8%AE%E5%8A%A9):sock5代理
- proxychains-ng:为终端命令设置代理

<!--more-->

# shadowsocks

这是Mac版本，[自行下载](https://github.com/shadowsocks/shadowsocks-iOS/wiki/Shadowsocks-for-OSX-%E5%B8%AE%E5%8A%A9)。

配置如下图2个：

- 设置自动代理模式
- 填写服务器信息

![shadowsocks配置1](http://7xixtr.com1.z0.glb.clouddn.com/image-20180906200452853.png)

![shadowsocks服务器配置](http://7xixtr.com1.z0.glb.clouddn.com/image-20180906200930519.png)

# Chrome设置

应用商店安装[SwitchyOmega](https://github.com/FelisCatus/SwitchyOmega)，shadowsocks默认端口为1080，配置如下：

![Omega代理设置](http://7xixtr.com1.z0.glb.clouddn.com/image-20180906201214614.png)

浏览器启用代理，自动切换代理的方式自行百度：

![image-20180906201322243](http://7xixtr.com1.z0.glb.clouddn.com/image-20180906201322243.png)

浏览器可科学上网了。

# 终端科学上网

作为研发，天天和国外资源打交道，必需让终端也能科学上网，不然下载个攻击、软件包就吐血了。

用下来最稳定省心的办法是proxychains-ng，优点突出：

- 只局限于使用的软件
- 稳定可行



安装proxychains-ng

```
brew install proxychains-ng
```

运行会列出配置文件位置

```
proxychains4 wget www.google.com
[proxychains] config file found: /usr/local/etc/proxychains.conf
[proxychains] preloading /usr/local/Cellar/proxychains-ng/4.13/lib/libproxychains4.dylib
```

打开配置文件：`/usr/local/etc/proxychains.conf`。

- dynamic_chain，取消这行注释
- strict_chain， 注释
- 最后一行添加`socks5 127.0.0.1 1080`

**验证科学上网的唯一标准：能用wget下载google主页**，什么`curl ip.cn`这种不一定准。

```
➜  t proxychains4 wget www.google.com
[proxychains] config file found: /usr/local/etc/proxychains.conf
[proxychains] preloading /usr/local/Cellar/proxychains-ng/4.13/lib/libproxychains4.dylib
[proxychains] DLL init: proxychains-ng 4.13
--2018-09-06 20:24:26--  http://www.google.com/
正在解析主机 www.google.com (www.google.com)... 224.0.0.1
正在连接 www.google.com (www.google.com)|224.0.0.1|:80... [proxychains] Strict chain  ...  127.0.0.1:1080  ...  www.google.com:80  ...  OK
已连接。
已发出 HTTP 请求，正在等待回应... 200 OK
长度：未指定 [text/html]
正在保存至: “index.html.10”

index.html.10                    [ <=>                                           ]  11.11K  --.-KB/s  用时 0s

2018-09-06 20:24:27 (59.9 MB/s) - “index.html.10” 已保存 [11375]
```

为了方便使用proxychains可以设置命令昵称，比如我的：

```
alias py4="proxychains4"
alias brew="py4 brew"
alias wget="py4 wget"
```

