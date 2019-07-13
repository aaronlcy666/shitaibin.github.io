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
- proxychains-ng:为终端命令设置SOCKS5代理

<!--more-->

# shadowsocks

[ShadowsocksX-NG-R8](https://raw.githubusercontent.com/VeniZ/ShadowsocksX-NG-R8-Bakup/master/ShadowsocksX-NG-R8.dmg)是Mac版本，可单独使用，不需要配置Chrome代理插件，使用用的PAC白名单上网模式，可以减少很多配置，并且体验更好。

设置步骤：
1. 添加服务器信息。
2. 设置全局模式
3. 更新PAC列表
4. 访问Google搜索
5. 设置为PAC模式

![](http://img.lessisbetter.site/2019-01-ss-ng.png)


经过以上配置，浏览器可以直接科学上网了，如果让终端和其他服务器上网，可设置Shadowsocks的http代理和socks5代理。

## 开启HTTP代理

点击状态栏shadowsocks图标，【HTTP代理设置...】是配置Http代理。【高级设置...】是socks5代理设置。

![](http://img.lessisbetter.site/2019-07-ss_http.png)


**http代理支持http和https2个协议的代理**，IP设置为0.0.0.0就可以为其他机器做http和https代理，如果只有本机用，可以使用默认的127。

![](http://img.lessisbetter.site/2019-07-ss-http-set.png)

## 开启SOCKS5代理

socks5的ip设置同http代理。

![](http://img.lessisbetter.site/2019-07-ss-socks5.png)


# 终端科学上网

## 用proxychains做socks5代理

> 这种能解决80%的翻墙情况。

作为研发，天天和国外资源打交道，必需让终端也能科学上网，不然下载个、更新软件，或者下载源码就吐血了。

用下来最稳定省心的办法是proxychains-ng，优点突出：

- 必要特性：稳定可行
- 加分特性：代理只局限于使用的软件，不会污染整个系统的代理



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
- 最后一行添加`socks5 127.0.0.1 1086`

**验证科学上网的唯一标准：能用wget下载google主页**，什么`curl ip.cn`这种不一定准，虽然显示你的是国外IP了，说明这次`curl`走了代理，但不代表你能使用wget下载，能更新源码。

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

## 设置环境变量

proxychains不支持https代理，如果设置http和socks5代理，代理一些https的连接的时候，就出问题了，经常超时、握手失败。

终极解决方案是设置全局的http和https代理，建议不要加到`.bash_profile`等，不然始终都走代理了，建议在使用的时候，设置代理即可，执行下面的脚本，或直接黏贴到终端。

```bash
// proxy.sh
export http_proxy=127.0.0.1:1087
export https_proxy=127.0.0.1:1087
```

> golang.org等域名的连接，再也不是问题。