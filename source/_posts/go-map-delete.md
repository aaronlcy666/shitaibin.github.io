title: Go的map中删除子map，内存会自动释放吗？
date: 2018-09-29 20:06:39
tags: ['Golang', 'map']
-----

结论
--------
在Go中，map中存放map，上层map执行delete，子层map占用的内存会释放，无需手动先释放子map内存，再在上层map执行删除。

实验
--------

在C++中，如果使用了map包含map的数据结构，当要释放上层map的某一项时，需要手动释放对应的子map占用的内存，而在Go中，垃圾回收让内存管理变得如此简单。

```go
package main

import (
	"log"
	"runtime"
)

var lastTotalFreed uint64
var intMap map[int]int
var cnt = 8192

func main() {
	printMemStats()

	initMap()
	runtime.GC()
	printMemStats()

	log.Println(len(intMap))
	for i := 0; i < cnt; i++ {
		delete(intMap, i)
	}
	log.Println(len(intMap))

	runtime.GC()
	printMemStats()

	intMap = nil
	runtime.GC()
	printMemStats()
}

func initMap() {
	intMap = make(map[int]int, cnt)

	for i := 0; i < cnt; i++ {
		intMap[i] = i
	}
}

func printMemStats() {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	log.Printf("Alloc = %v TotalAlloc = %v  Just Freed = %v Sys = %v NumGC = %v\n",
		m.Alloc/1024, m.TotalAlloc/1024, ((m.TotalAlloc-m.Alloc)-lastTotalFreed)/1024, m.Sys/1024, m.NumGC)

	lastTotalFreed = m.TotalAlloc - m.Alloc
}
```

结果
```
2018/09/29 20:09:25 Alloc = 65 TotalAlloc = 65  Just Freed = 0 Sys = 1700 NumGC = 0
2018/09/29 20:09:25 Alloc = 387 TotalAlloc = 391  Just Freed = 3 Sys = 3076 NumGC = 1
2018/09/29 20:09:25 8192
2018/09/29 20:09:25 0
2018/09/29 20:09:25 Alloc = 387 TotalAlloc = 392  Just Freed = 1 Sys = 3140 NumGC = 2
2018/09/29 20:09:25 Alloc = 74 TotalAlloc = 394  Just Freed = 314 Sys = 3140 NumGC = 3
```


```go
package main

import (
	"log"
	"runtime"
)

var intMapMap map[int]map[int]int

var cnt = 1024
var lastTotalFreed uint64 // size of last memory has been freed

func main() {
	// 1
	printMemStats()

	// 2
	initMapMap()
	runtime.GC()
	printMemStats()

	// 3
	fillMapMap()
	runtime.GC()
	printMemStats()

	// 4
	log.Println(len(intMapMap))
	for i := 0; i < cnt; i++ {
		delete(intMapMap, i)
	}
	log.Println(len(intMapMap))
	runtime.GC()
	printMemStats()

	// 5
	intMapMap = nil
	runtime.GC()
	printMemStats()
}

func initMapMap() {
	intMapMap = make(map[int]map[int]int, cnt)
	for i := 0; i < cnt; i++ {
		intMapMap[i] = make(map[int]int, cnt)
	}
}

func fillMapMap() {
	for i := 0; i < cnt; i++ {
		for j := 0; j < cnt; j++ {
			intMapMap[i][j] = j
		}
	}
}

func printMemStats() {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	log.Printf("Alloc = %v TotalAlloc = %v  Just Freed = %v Sys = %v NumGC = %v\n",
		m.Alloc/1024, m.TotalAlloc/1024, ((m.TotalAlloc-m.Alloc)-lastTotalFreed)/1024, m.Sys/1024, m.NumGC)

	lastTotalFreed = m.TotalAlloc - m.Alloc
}
```
结果
```
2018/09/29 20:10:27 Alloc = 64 TotalAlloc = 64  Just Freed = 0 Sys = 1700 NumGC = 0
2018/09/29 20:10:27 Alloc = 41154 TotalAlloc = 41157  Just Freed = 3 Sys = 46026 NumGC = 5
2018/09/29 20:10:27 Alloc = 41241 TotalAlloc = 41293  Just Freed = 48 Sys = 47082 NumGC = 6
2018/09/29 20:10:27 1024
2018/09/29 20:10:27 0
2018/09/29 20:10:27 Alloc = 114 TotalAlloc = 41295  Just Freed = 41128 Sys = 47082 NumGC = 7
2018/09/29 20:10:27 Alloc = 74 TotalAlloc = 41296  Just Freed = 41 Sys = 47082 NumGC = 8
```

参考资料
---------------
- http://blog.cyeam.com/json/2017/11/02/go-map-delete