---
title: 修改oh my zsh主题
date: 2020-11-18 20:09:49
tags: ['Terminal']
---

习惯使用[gallois主题](https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/gallois.zsh-theme)，但发现它有一个现在无法忍受的缺点，如果当前目录是git仓库，它会在右边显示分支名称和clean状态。当从终端复制文本出来时，分支名称和左边命令的空白，全是空格填充，复制出来就得手动删除。

![](http://img.lessisbetter.site/2020-11-old-gallois.png)

oh my zsh的所有主题配置都在`.oh-my-zsh/themes/`目录，文件名称同主题名称，可以对这些主题的一些配置进行修改。

注释掉配置文件中关于git的设置，打开新终端后，就可以不显示git分支信息了。

![](http://img.lessisbetter.site/2020-11-new-gallois.png)


从此复制出的代码，在也没有多余文本。