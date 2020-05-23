---
title: VSCode && Goland
date: 2018-06-02 18:40:01
tags: ['Go','IDE']
---

大项目选Goland，小项目选VSCode。

<!--more-->

# VSCODE

我一直使用VSCODE作为Golang的开发工具，并且用起来也很顺手，效率也相对很高，但由于查找函数慢，没有在大的Go项目中使用VSCODE，小项目倾向于使用VSCODE。

## 问题


Mac上如果遇到：

```
Could not create temporary directory: 权限被拒绝
```

使用下面命令解决：

```
sudo chown $USER ~/Library/Caches/com.microsoft.VSCode.ShipIt/  
```

## 插件

1. Docker
2. Go
3. hightligt-words：高亮关键词
4. Markdown All in One：算是增强了自带markdown，有很多方便的命令
5. Partial Diff：比较代码片段，而不是以文件为基础进行比较
6. Drawio. Integration：画图必备


# 转向Goland

原因很简单，VS Code的功能，Golang上基本都能找到，并且还没Goland好：
1. 立马能输出函数、结构体、结构体内的成员的引用，秒杀VS Code

### Goland 快捷键

|功能|快捷键|使用频率|
|------|------|------|
|查找任何| 两下Shift|★|
|跳到定义、查看任何的调用|Cmd + B 或者 Cmd + 单击|★★★★★|
|查看实现某个接口函数的所有函数|Alt + Cmd + 单
|查找类|Cmd + O|★|
|查找符号/函数|Alt + Cmd + O|★★★|
|跳转到文件|Shift + Cmd + O|★|
|前一个位置|Alt + Cmd + <-|★★★|
|行首(尾)|Cmd + <-(->)|★|
|注释|Cmd + /|★★★|
|折叠、可以快速调到函数开头|Alt + -||
|终端|Cmd + F12，自己改为Cmd + 0|★★★|
|TODO 列表| Cmd + 6|★|
|左边文件列表|Cmd + 1|★★★|
|Git面板|Cmd + 9|★★|
|Git提交|Cmd + K|★★|
||||

### Goland其他设置

1. 快捷键添加的注释前面默认是没有空格的，`//comment`，如果要这种效果`// comment`，设置中搜索`Add leading space to comments`。
1. 设置保存自动格式化代码。设置 -> Tools -> File Watcher -> +号 -> go fmt -> 确定。

### Goland插件
1. MultiHighlight：一直高亮单词，方便阅读和查找。