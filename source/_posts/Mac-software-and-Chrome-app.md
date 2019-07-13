---
title: 必备Mac软件&Chrome应用
date: 2018-06-01 21:02:19
tags: ['Mac', 'Chrome']
---


# 必备的Mac软件

### 编程

- Dash：开发必备，秒差各语言API
- Kaleidoscope：diff工具，颜值高、简单，但功能不够强大，比BC差太多，不能只进行行的合并，其他Mac下的对比合并工具没这个好。
- iTerm2：The Best Terminal，用好快捷键
- Ominigraff：架构图、流程图画起来爽飞，如果不使用快捷键，效率/1000

<!--more-->

- brew：必备包管理工具，然而某些原因国内慢死，你需要[让Homebrew飞](http://lessisbetter.site/2019/07/13/better-brew/)。
- 命令行临时救命代理`export ALL_PROXY=socks5://127.0.0.1:1080`
- proxychains：命令行代理工具
    运行一下`proxychains curl ip.gs`就能列出来配置文件目录，修改为：
    ```
    dynamic_chain
    socks5 127.0.0.1 1080
    ```
    然后使用`proxychains wget www.google.com`进行测试，成功则配置完成。

- oh-my-zsh:
    - 插件
        - git
        - autojump
    - [历史配置](https://gist.github.com/Shitaibin/16f781ff5b320388efc55ed37d260815)
- [trash-cli](https://github.com/andreafrancia/trash-cli)，配上昵称，解决`rm`误删问题
    ```
    # Reset rm command
    alias rm='trash-put'
    alias rl='trash-list'
    alias ur='trash-restore'
    ```

### 办公
- Copy Clip2：保存复制文本，对于程序员和文字重度工作者很重要
- Clipy：同上，但免费
- 疯狂番茄：番茄工作法，只用来当定时器用，配合Things
- Things：安排好工作（More Than TODO）
- iThoughtx：思维导图
- Paralles Desktop：还是习惯Windows办公全家桶
- Entropy：windows解压无压力的软件，压缩为7z文件更小，zip实际不压缩只是打包。符正确使用姿势：**右键->服务->Archive as 7z**，Keka必须打开软件才能压缩，简直弱爆了。
￼

### Mac截图

许多朋友都觉得Mac的抓图不好用，找好用的截图软件，但那些工具太Low了。

**Ctrl + Command + Shift + 4**，截图后存到剪贴板。

其他：
Command + Shift + 3 截取整个屏幕，保存图片在桌面 
Command + Shift + 4 选取部分屏幕区域，保存图片在桌面 
先 Command + Shift + 4 再空格，可以对指定的窗口或者菜单截屏
以上快捷键，**加上 Ctrl，可以把截屏保存在剪贴板**。


# 必备的Chrome应用

> 安装应用记得翻墙，或者国内保存插件的网站。

- 方片收集：把网页收藏起来，想看的时候🔍一下。
- Diigo Web Collector：最好用的是给网页加标注，就像用PDF一样，可以从库中查看所有标记。
- EasyReader：让浏览网页更清晰，对付杂乱的网站很有用。
- Proxy SwitchyOmega：用Google查资料必备。
- Sourcegraph：在线浏览代码神器，简直在线版的VS Code
- 印象笔记插件
