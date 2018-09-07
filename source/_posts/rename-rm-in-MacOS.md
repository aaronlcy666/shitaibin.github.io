---
title: 重命名rm命令，防止误删
date: 2018-09-07 08:45:31
tags: ['Mac', 'Bash']
---

Oh Shit！误删数据了。

!<--more-->

既然看这篇文章，你必然也有`rm`命令误删数据的经历了，废话少说，解决办法：使用trash-cli覆盖原有的`rm`命令，把`rm`命令更改为`RM`。

需要的软件:
- [trash-cli](https://github.com/andreafrancia/trash-cli)

安装办法见Github项目的Readme文档。

修改`.bashrc`或`.zshrc`，增加昵称覆盖原有的`rm`命令。
```
alias rm='trash-put'        #文件移动到垃圾桶
alias rl='trash-list'       #列出删除的文件
alias ur='trash-restore'    #恢复删除的文件
alias RM='/bin/rm'          #原有的rm命令
```

