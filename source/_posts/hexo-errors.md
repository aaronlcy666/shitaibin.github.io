title: Hexo博客错误汇总
date: 2015-12-13 12:21:33
tags: ["Hexo"]
---


# 博文格式错误

## 错误1

错误提示如下：


<!--more-->


```shell
$ hexo g
ERROR Process failed: _posts/how-mistake-python-introduction.md
YAMLException: can not read a block mapping entry; a multiline key may not be an implicit                                                                                           key at line 4, column 1:

    ^
    at generateError (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\js-yaml\lib\js-                                                                                          yaml\loader.js:160:10)
    at throwError (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\js-yaml\lib\js-yam                                                                                          l\loader.js:166:9)
    at readBlockMapping (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\js-yaml\lib\                                                                                          js-yaml\loader.js:1029:9)
    at composeNode (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\js-yaml\lib\js-ya                                                                                          ml\loader.js:1317:12)
    at readDocument (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\js-yaml\lib\js-y                                                                                          aml\loader.js:1480:3)
    at loadDocuments (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\js-yaml\lib\js-                                                                                          yaml\loader.js:1536:5)
    at Object.load (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\js-yaml\lib\js-ya                                                                                          ml\loader.js:1553:19)
    at parseYAML (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\hexo-front-matter\l                                                                                          ib\front_matter.js:80:21)
    at parse (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\hexo-front-matter\lib\f                                                                                          ront_matter.js:56:12)
    at C:\Users\Brave\MyBlog\node_modules\hexo\lib\plugins\processor\post.js:87:16
    at tryCatcher (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\bluebird\js\main\u                                                                                          til.js:26:23)
    at Promise._settlePromiseFromHandler (C:\Users\Brave\MyBlog\node_modules\hexo\node_mod                                                                                          ules\bluebird\js\main\promise.js:505:31)
    at Promise._settlePromiseAt (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\blue                                                                                          bird\js\main\promise.js:581:18)
    at Promise._settlePromises (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\blueb                                                                                          ird\js\main\promise.js:697:14)
    at Async._drainQueue (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\bluebird\js                                                                                          \main\async.js:123:16)
    at Async._drainQueues (C:\Users\Brave\MyBlog\node_modules\hexo\node_modules\bluebird\j                                                                                          s\main\async.js:133:10)
    at Immediate.Async.drainQueues [as _onImmediate] (C:\Users\Brave\MyBlog\node_modules\h                                                                                          exo\node_modules\bluebird\js\main\async.js:15:14)
    at processImmediate [as _immediateCallback] (timers.js:383:17)
INFO  Files loaded in 3.69 s
INFO  0 files generated in 294 ms
```

重要提示：
`can not read a block mapping entry`。

原因：
```
title: Hexo博客错误汇总
date: 2015-12-13 12:21:33
tags:["Hexo"] #tags冒号后面应当有个空格,其他地方也应当注意
```

正确格式：
```
title: Hexo博客错误汇总
date: 2015-12-13 12:21:33
tags: ["Hexo"]
```