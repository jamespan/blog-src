title: "说好的 OOM Killer 去哪了"
date: 2015-06-06 12:15:34
tags:
  - Linux
  - Java
categories:
  - Work
cc: true
comments: true
thumbnail: http://ww2.sinaimg.cn/small/e724cbefgw1esu3i3a9rxj20go0af0u1.jpg
---

这两天有几个同事在部署新应用的时候遇到了阻碍，师兄让我去帮忙看看。

一开始我以为是新应用的工程结构不符合集团的部署规范。一番折腾无果之后我给重新搭建了一套，然后把代码迁移过去。然而并没有什么用处。

因为一开始想错了方向，我们折腾了一天才确认是内存不足，只好联系管理开发环境的同事分配更大内存的机器，然后应用终于部署起来了。

<!-- more -->

# 宕机 #

折腾期间我因为调整 JVM 的最大内存参数时过于粗暴，把虚拟机玩坏了两台，表现为机器能 ping 通，就是没法 ssh 登录。

虚拟机大法好，玩坏了再申请一台就是了。但是，Linux 服务器居然能因为内存问题而宕机！感觉我的认知被颠覆了。之前我一直认为 Linux 内核有一个被称为 OOM Killer 的机制，能够在系统内存不足的时候结束内存大户，从而释放出大量内存，让系统回到健康状态。

![OOM Killer](http://ww2.sinaimg.cn/large/e724cbefgw1esu3i3a9rxj20go0af0u1.jpg)

系统把进程结束了不是问题，问题是进程把系统给结束了。为什么说好的 OOM Killer 没有发挥作用力挽狂澜？我要搞个大新闻，把内核批判一番。

# 理论 #

我们可以通过 /proc 文件系统在运行时改变内核的一些行为，我 Google 了一番和 OOM 相关的内核参数，发现有下面这几个比较重要的参数，都和虚拟内存（VM）相关[^1]。

[^1]: [Documentation for /proc/sys/vm/*][1]

1. oom\_kill\_allocating_task
2. panic\_on\_oom

根据内核文档的说法，oom\_kill\_allocating_task 是一个控制在内存耗尽时是否结束那个造成内存耗尽的任务的开关。默认值为 0，表示 OOM Killer 会去扫描完整的任务列表，用启发式算法选一个进程来结束。通常被结束的进程是一个流氓任务内存大户。

如果 oom\_kill\_allocating_task 的值不为 0，那么事情就简单了，哪个任务申请内存的操作造成了内存耗尽，就把那个任务干掉。这样可以避免扫描任务列表这种昂贵的操作。

关于 panic\_on\_oom，文档是这么说的。这是一个决定内存耗尽时是否触发内核错误的开关。默认值为 0，内存耗尽时内核让 OOM Killer 去干掉几个内存流氓，让系统继续干活。如果开关值为 1，那么内存耗尽时触发内核错误。然而在多 CPU 的机器上又是另外一番情景，没用过这种机器就不说了。如果开关值为 2，就算仅仅是一个 cgroup 里面发生了内存耗尽，整个系统都 panic 了。据说 1 和 2 这两个开关值是用来给集群做 failover 用的。

我看了虚拟机的这两个内核参数，都是默认值。也就是说，理论上，OOM 发生的时候，系统不会发生 kernel panic，OOM Killer 会出来干活，而且是在启发式黑魔法的加持下机智的干活。

# 现实 #

{% blockquote Jan L. A. van de Snepscheut http://en.wikiquote.org/wiki/Jan_L._A._van_de_Snepscheut %}
In theory, there is no difference between theory and practice. But, in practice, there is.
{% endblockquote %}

网上找到的大量资料都是关于 MySQL 被 OOM Killer 干掉的悲剧，比如 Fenng 多年前的《[Linux 的 Out-of-Memory (OOM) Killer][3]》，然而我遇到的问题恰恰相反，OOM Killer 躲起来了。

最后，我还是发现了一些少得可怜的资料。

有人在 Ubuntu 论坛提问，[OOM killer not working?][4]。

有人回答说这是一个内核的 bug，还给出了 [bug report][5]。

我比较认可的一个答案是这么说的。

{% blockquote Teresa e Junior  http://askubuntu.com/a/402940 %}
From my own experiences, when a OOM is triggered, the kernel has no more "strength" enough left to do such scan, making the system totally unusable.

Also, it would be more obvious just killing the task that caused the problem, so I fail to understand why it is set to 0 by default.
{% endblockquote %}

也就是说，OOM 发生的时候，内核已经没有足够的资源去做扫描任务列表这种事情，然后整个系统就不可用了。

这两天找时间尝试一下把 oom\_kill\_allocating_task 设置为 1，看看 OOM 发生的时候是什么效果吧~

[1]: https://www.kernel.org/doc/Documentation/sysctl/vm.txt
[2]: http://www.oracle.com/technetwork/articles/servers-storage-dev/oom-killer-1911807.html
[3]: http://dbanotes.net/database/linux_outofmemory_oom_killer.html
[4]: http://askubuntu.com/questions/398236/oom-killer-not-working
[5]: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1359766
