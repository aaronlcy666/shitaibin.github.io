---
title: Etcd Raft架构设计和源码剖析1：
date: 2019-08-19 09:42:37
tags: ['一致性', '共识']
---

## 序言

以raftexample为例，介绍一条log从客户端发起到raft集群达成共识，将log应用到状态机的过程。

raftexample是etcd中的一个简单的内存分布式KV数据库，实现了多Raft节点间的数据存取，以及集群增删节点，它是学习使用etcd raft的非常好的样例。




## Raft应用架构


架构图

## 总过程

摘要版：


详细版：

1. cli发送req
1. app收到
1. app交给raft.node
1. raft.node交给raft.raft：func (n *node) Propose，pb.MsgProp
1. stepLeader把entry存到raftLog，log加入到unstable。尝试更新本地committed，maybeCommit
1. stepLeader对所有node发起一轮广播，对每个节点执行sendAppend，从它们的Next位置开始，从raftLog提取出一批连续的entry，由于每个节点情况不一样，这些entry可能是applied、committed、append到storage但没committed，也可能是unstable的，生成MsgApp存到raft.msgs

Ready流程：
1. node.run发现可以Ready，利用`newReady`生成Ready
    1. 把unstable取出来，存到Entries，
    1. 把raft.msg取出来，存到Messages
    1. 把已committed但未applied的entry取出来，存到CommittedEntries
1. Ready交给APP
1. App处理Ready消息
    1. 把Entries append到storage，log append到storage，func (ms *MemoryStorage) Append(，由应用层完成
    1. 把CommittedEntries存的msg，apply到状态机
    1. 把Messages中的消息，使用transport发给对应节点
1. App将消息，交给transport发送给对应节点

接收请求：
1. transport收到消息，交给App
1. App利用Step交给raft.node
1. raft.Node交给raft.raft
1. raft.raft处理MsgApp请求：handleAppendEntries，存到unstable，顺便利用消息中committed字段更新本地raftLog中的committed字段
1. raft.raft创建MsgAppResp响应
1. 消息存到raft.msgs
1. raft.node发现可以创建Ready，接下来就是Ready流程

接收响应：
1. stepLeader中对MsgAppResp的处理，更加已有的response，尝试更新committed，maybeCommit，如果committed更新了，说明可以给其他node发送新的MsgApp



### raftLog

```go
type raftLog struct {
	// storage contains all stable entries since the last snapshot.
	storage Storage

	// unstable contains all unstable entries and snapshot.
	// they will be saved into storage.
	unstable unstable

	// committed和applied是storage的2个整数下标
	// committed到applied需要Ready
	// committed is the highest log position that is known to be in
	// stable storage on a quorum of nodes.
	committed uint64
	// applied is the highest log position that the application has
	// been instructed to apply to its state machine.
	// Invariant: applied <= committed
	applied uint64
}
```

client提交的请求会变成entry，最先是unstable状态，保存在raft中，然后发送Ready，让App执行commit，把unstable的entry存入storage，storage存了2个整数，使用下标记录最新commited的entry和最新applied的entry，存在committed为未applied的entry，存在的时候，也会生成Ready消息，让App把committed的entry进行apply，即修改状态机。

