---
title: 探索Golang定时器的陷阱
date: 2018-09-04 17:43:41
tags: ['Golang', '定时器']
---

所谓陷阱，就是它不是你认为的那样。刚好`Timer.Reset()`和`Timer.Stop()`的返回值就有陷阱，探索一下。

<!--more-->

`Timer.Reset()`函数的返回值与重设定时器成功和失败没有关系，而是与定时器在重设前的状态有关：
- Timer已经停止或者超时，返回false。
- 只有未超时时，返回true。

`Timer.Reset()`“失败”的情况，与通道中是否存在事件有关。由于`Timer.C`是缓冲大小只为1，当其中存在事件时，即便定时器真正超时，也无法向通道中写入数据，对外通知。


```
// NewTimer creates a new Timer that will send
// the current time on its channel after at least duration d.
func NewTimer(d Duration) *Timer {
	c := make(chan Time, 1) // 缓存通道大小为1
	t := &Timer{
		C: c,
		r: runtimeTimer{
			when: when(d),
			f:    sendTime,
			arg:  c,
		},
	}
	startTimer(&t.r)
	return t
}
```


**如果确保`Timer.Reset()`成功？**不确定，没有一个指标能告诉你它成功了，一定会在将来的某个时间通知你。但我们可以尽量让他成功，在`Timer.Reset()`前清空通道，以免阻塞。


- 当业务场景简单的时候，只要能够保证，下次`Reset()`前通道数据是空的，没有必要主动去判断和清空`Timer.C`中的事件。
- 当业务场景复杂，存在调用`Timer.Stop()`停止定时器，某种条件之后又通过`Reset()`开启定时器的情况，考虑清楚`Reset()`前是否可能存在`Timer.C`未清空的情况，如果存在，最好在`Reset()`前增加判断和清空。
```
if len(Timer.C) > 0{
    <-Timer.C
}
Timer.Reset(time.Second)
```

测试代码
```
package main

import (
	"fmt"
	"time"
)

// 不同情况下，Timer.Reset()的返回值
func test1() {
	fmt.Println("第1个测试：Reset返回值和什么有关？")
	tm := time.NewTimer(time.Second)
	defer tm.Stop()

	quit := make(chan bool)

	// 退出事件
	go func() {
		time.Sleep(3 * time.Second)
		quit <- true
	}()

	// Timer未超时，看Reset的返回值
	if !tm.Reset(time.Second) {
		fmt.Println("未超时，Reset返回false")
	} else {
		fmt.Println("未超时，Reset返回true")
	}

	// 停止timer
	tm.Stop()
	if !tm.Reset(time.Second) {
		fmt.Println("停止Timer，Reset返回false")
	} else {
		fmt.Println("停止Timer，Reset返回true")
	}

	// Timer超时
	for {
		select {
		case <-quit:
			return

		case <-tm.C:
			if !tm.Reset(time.Second) {
				fmt.Println("超时，Reset返回false")
			} else {
				fmt.Println("超时，Reset返回true")
			}
		}
	}
}

func test2() {
	fmt.Println("\n第2个测试:超时后，不读通道中的事件，可以Reset成功吗？")
	sm2Start := time.Now()
	tm2 := time.NewTimer(time.Second)
	time.Sleep(2 * time.Second)
	fmt.Printf("Reset前通道中事件的数量:%d\n", len(tm2.C))
	if !tm2.Reset(time.Second) {
		fmt.Println("不读通道数据，Reset返回false")
	} else {
		fmt.Println("不读通道数据，Reset返回true")
	}
	fmt.Printf("Reset后通道中事件的数量:%d\n", len(tm2.C))

	select {
	case t := <-tm2.C:
		fmt.Printf("tm2开始的时间: %v\n", sm2Start.Unix())
		fmt.Printf("通道中事件的时间：%v\n", t.Unix())
		if t.Sub(sm2Start) <= time.Second+time.Millisecond {
			fmt.Println("通道中的时间是重新设置sm2前的时间，即第一次超时的时间，所以第二次Reset失败了")
		}
	}

	fmt.Printf("读通道后，其中事件的数量:%d\n", len(tm2.C))
	tm2.Reset(time.Second)
	fmt.Printf("再次Reset后，通道中事件的数量:%d\n", len(tm2.C))
	time.Sleep(2 * time.Second)
	fmt.Printf("超时后通道中事件的数量:%d\n", len(tm2.C))
}

func test3() {
	fmt.Println("\n第3个测试：Reset前清空通道，尽可能通畅")
	smStart := time.Now()
	tm := time.NewTimer(time.Second)
	time.Sleep(2 * time.Second)
	if len(tm.C) > 0 {
		<-tm.C
	}
	tm.Reset(time.Second)

	// 超时
	t := <-tm.C
	fmt.Printf("tm开始的时间: %v\n", smStart.Unix())
	fmt.Printf("通道中事件的时间：%v\n", t.Unix())
	if t.Sub(smStart) <= time.Second+time.Millisecond {
		fmt.Println("通道中的时间是重新设置sm前的时间，即第一次超时的时间，所以第二次Reset失败了")
	} else {
		fmt.Println("通道中的时间是重新设置sm后的时间，Reset成功了")
	}
}

func main() {
	test1()
	test2()
	test3()
}
```