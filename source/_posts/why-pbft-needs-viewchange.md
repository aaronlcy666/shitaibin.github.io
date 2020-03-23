---
title: 为什么PBFT需要View Changes
date: 2020-03-22 14:10:53
tags: ['区块链','一致性','共识算法', 'PBFT']
---

## 前言

在当前的PBFT资料中，尤其是中文资料，多数都在介绍PBFT的3阶段消息过程，很少提及View Changes（视图切换），View Changes对PBFT的重要性，如同Leader Election对Raft的重要性，它是一个一致性算法中，不可或缺的部分。

作者为大家介绍下，为什么View Changes如此重要，即为什么PBFT需要View Changes，以及View Changes的原理，最后介绍基于View Changes的一些思考。


## 为什么PBFT需要View Changes

一致性算法都要提供：
- safety ：原意指不会出现错误情况，一致性中指操作是正确的，得到相同的结果。
- liveness ：操作过程能在有限时间内完成。

![一致性协议需要满足的特性](http://img.lessisbetter.site/2020-03-consistency-property.png)

**safety通常称为一致性，liveness通常称为可用性**，没有liveness的一致性算法无法长期提供一致性服务，没有safety的一致性算法称不上一致性算法，所以，所有的一致性算法都在做二者之间的折中。


所以对一致性和可用性不同的要求，就出现了你常听见的ACID原理、CAP理论、BASE理论。

PBFT作为一个一致性算法，它也需要提供一致性和可用性。在[为什么PBFT需要3个阶段消息](https://lessisbetter.site/2020/03/15/why-pbft-needs-3-phase-message/)中，介绍了PBFT算法的如何达成一致性，并且请求可以在有限时间内达成一致，客户端得到响应，也满足可用性。

但没有介绍，当遇到以下情况时，是否还能保住一致性和可用性呢？
1. 主节点是拜占庭节点（宕机、拒绝响应...）
2. 主节点不是拜占庭节点，非拜占庭副本节点参与度不足，不足以完成3阶段消息
3. 网络不畅，丢包严重，造成不足以完成3阶段消息
4. ...

在以上场景中，**新的请求无法在有限时间内达成一致，老的数据可以保持一致性，所以一致性是可以满足的，但可用性无法满足**。必须寻找一个方案，恢复集群的可用性。

**PBFT算法使用View Changes，让集群重新具有可用性。**通过View Changes，可以选举出新的、让请求在有限时间内达成一致的主节点，向客户端响应，从而满足可用性的要求。

让集群重新恢复可用，需要做到什么呢？**让至少f+1个非拜占庭节点迁移到，新的一致的状态**。然后这些节点，运行3阶段消息协议，处理新的客户端请求，并达成一致。

## 不同版本的View Changes协议有什么不同？

PBFT算法有1999年和2001年2个版本：
- 99年：[Practical Byzantine Fault Tolerance](http://pmg.csail.mit.edu/papers/osdi99.pdf)，PBFT初次发表。
- 01年：[Practical Byzantine Fault Tolerance and Proactive Recovery](http://www.pmg.csail.mit.edu/papers/bft-tocs.pdf)，又称PBFT-PR，让PBFT受攻击时，具有主动恢复能力。

PBFT-PR并非只是在PBFT上增加了PR，同时也对PBFT算法做了详细的介绍和改进，View Changes的改进就是其中一项。

PBFT中View Changes介绍比较简单，没有说明以下场景下，View Changes协议如何处理：

- 如果下一个View的主节点宕机了怎么办
- 如果下一个View的主节点是恶意节点，作恶怎么办
- 如果非拜占庭恶意发起View Changes，造成主节点切换怎么办？
- 如果参与View Changes的节点数量不足怎么办

如果，以上场景下，节点处在View Changes阶段，持续的等待下去，就无法恢复集群的可用性。

PBFT-PR中的View Changes协议进行了细化，可以解决以上问题。

## 2001年版本View Changes协议原理

每个主节点都拥有一个View，就如同Raft中每个leader都拥有1个term。不同点是term所属的leader是选举出来的，而View所属的主节点是计算出的： `primary = v % R`，R是运行PBFT协议的节点数量。

View Changes的战略是：当副本节点怀疑主节点无法让请求达成一致时，发起视图切换，新的主节点收集当前视图中已经Prepared，但未Committed的请求，传递到下一个视图中，所有非拜占庭节点基于以上请求，会达到一个新的、一致的状态。然后，正常运行3阶段消息协议。

为什么要包含已经Prepared，但未Committed的请求？如果一个请求，在副本节点i上，已经是Prepared状态，证明至少f+1的非拜占庭节点，已经拥有此请求并赞成请求req在视图v中使用序号n。如果没有问题，不发生视图切换，这些请求可以在有限的时间内达成一致，新的主节点把已经Prepared的请求，带到新的view，并证明给其他节点，请求已经Prepared，那只需1轮Commit就可以达成一致。



