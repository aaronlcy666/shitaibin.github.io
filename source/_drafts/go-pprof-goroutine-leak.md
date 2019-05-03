---
title: go pprof goroutine leak
date: 2019-05-03 10:30:47
tags:
---

### WHAT

### How

### goroutine profile

```go
package main

import (
	"fmt"
	"net/http"
	_ "net/http/pprof"
	"runtime"
)

func main() {
	http.ListenAndServe("0.0.0.0:6060", nil)

	for {
		fmt.Printf("#goroutines: %d\n", runtime.NumGoroutine())
	}
}
```


运行:

```
```

结果

