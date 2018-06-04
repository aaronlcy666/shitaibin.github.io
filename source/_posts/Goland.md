---
title: VSCode V.S. Goland
date: 2018-06-02 18:40:01
tags: ['Goland', 'Golang']
---

Goland是我目前（2018年06月02日）体验过的最方便/高效的Golang IDE。

<!--more-->

# 丢弃VSCODE

我一直使用VSCODE作为Golang的开发工具，并且用起来也很顺手，效率也相对很高。抛弃它有以下原因：
1. 查找函数引用慢


# 转向Goland

原因很简单，VS Code的功能，Golang上基本都能找到，并且还没Goland好：
1. 立马能输出函数、结构体、结构体内的成员的引用，秒杀VS Code

### Goland 快捷键

|功能|快捷键|
|------|------|
|查找任何| 两下Shift|
|跳到定义、查看任何的调用|Cmd + B 或者 Cmd + 单击|
|查找类|Cmd + O|
|查找符号/函数|Alt + Cmd + O|
|跳转到文件|Shift + Cmd + O|
|前一个位置|Alt + Cmd + <-|
|行首(尾)|Cmd + <-(->)|
|注释|Cmd + /|
|折叠、可以快速调到函数开头|Alt + -|
|终端|Cmd + F12，自己改为Cmd + 0|
|TODO 列表| Cmd + 6|
|左边文件列表|Cmd + 1|
|Git面板|Cmd + 9|
|Git提交|Cmd + K|
|||

### Goland其他设置

1. 快捷键添加的注释前面默认是没有空格的，`//comment`，如果要这种效果`// comment`，设置中搜索`Add leading space to comments`。