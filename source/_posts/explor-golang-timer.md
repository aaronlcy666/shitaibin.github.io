---
title: 可重复利用的Golang定时器
date: 2018-09-04 17:43:41
tags: ['Golang', '定时器']
---

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
