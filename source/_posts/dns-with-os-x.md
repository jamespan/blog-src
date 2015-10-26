title: 在 OS X 10.10.4 上设置 DNS
tags:
  - OS X
categories:
  - Study
cc: true
comments: true
date: 2015-08-03 23:08:36
---


```bash
sudo networksetup -setdnsservers <networkservice> <dns1> [dns2] [...]
sudo networksetup -setdnsservers <networkservice> empty
```

大概有大半年的时间了，连上公司的 VPN 之后，就没法使用 HSF 等等一系列中间件，于是一切的开发、测试都没法做了。一开始的时候忍忍算了，大不了跑去公司写呗，顺便在食堂解决伙食问题。

最近天气炎热，实在不想出门，被逼无奈只好开始分析问题。

<!-- more -->

上周查看异常堆栈的时候发现，最开始抛出的异常是 java.net.UnknownHostException，于是当时我怀疑问题出在 DNS 上，但是没有继续深究，而是在内网发了一个状态，想碰碰运气看一下有没有同事曾经遇到并解决了类似的问题。

![内网求助状态](http://ww2.sinaimg.cn/large/e724cbefgw1eupszi6qbcj20h905qabc.jpg)

有个同事回复了一下，然后就没有然后了。一个星期过去了，又到了周末，问题依旧。

观止巨巨眼看我又要跑去公司，问我咋不用 VPN，我跟他描述了情况，他建议我绑定 DNS 试试。

一般来说电脑连上路由器之后，路由器会充当 DNS 的角色，为了解决这个问题，我可能需要绑定办公网的 DNS。然而，我不知道办公网的 DNS 是什么，在内网各种搜索也没有结果。

无奈之下，只好又跑公司去了。

联网之后记下办公网的 DNS，吭哧吭哧写了几个小时代码之后回家。

晚上吃完饭回来，我还惦记着 DNS 的事情。连上 VPN 之后，跑一个用了 HSF 的测试用例，不出意料地挂了。确认办公网 DNS 能 ping 通，然后配置好 DNS 之后，测试用例！通！过！了！ 

这个世界上的事情，没有那么简单的。连上 VPN，设置了 DNS，HSF 是能用了，那么断开 VPN 之后呢？因为 DNS 设置还在，而此时 DNS 已经连不上了，于是域名解析瘫痪，上不了网了。

虽然我很想吐槽公司的 VPN 软件，很想给他们提需求，但是自己动手解决问题还是最省事的。虽然我没法把连接 VPN 和设置 DNS 两件事自动化起来，但是我至少可以把事情简化一点，不用总是拿鼠标点啊点的。

不得不说，我对 OS X 下面的一系列系统管理工具不是很熟悉，每次都只能 Google 一下。这次可算是有意外收获，不但找到了介绍如何用命令行设置 DNS[^1]，还发现了 [OS X Daily][2] 这个有意思的网站。

[^1]: [How to Change DNS from Command Line of Mac OS X][1]


需要注意的一点，清除 DNS 设置的命令是

```bash
sudo networksetup -setdnsservers Wi-Fi empty
```

而不是

```bash
sudo networksetup -setdnsservers Wi-Fi
```


[1]: http://osxdaily.com/2015/06/02/change-dns-command-line-mac-os-x/
[2]: http://osxdaily.com

