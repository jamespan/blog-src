title: Surge 是一个 Web 开发者工具，你们不要拿来干坏事
tags:
  - Tool
categories:
  - Study
cc: true
thumbnail: https://ws2.sinaimg.cn/small/e724cbefgw1exhepdy2j3j204v04v0sl.jpg
comments: true
date: 2015-10-29 01:01:44
---

最近有一个叫 Surge 的 App 火了。一时间网上出现各种介绍如何科学使用 Surge 的文章，V2EX 还有网友发帖感谢 Surge 的作者。

这个 App 售价 68 RMB，好贵有木有，但是我还是没忍住加入了剁手大军。

<!-- more --><!-- indicate-the-source -->

Surge 是一个支持 HTTP、HTTPS、SOCKS5 等协议的代理工具，通过在设备上添加 VPN 服务来接管设备的网络流量。启动代理的时候，启动一个名为 Surge 的 VPN，然后网络流量就到 Surge 那里去了，至于每个 package 应该直接发送还是借助代理，则由代理规则决定。

这个描述也许会让你想起 ProxySharp、gfwlist 之类的工具，但是它也仅仅是一个代理工具而已，并不是红杏之类的科学上网工具。

不要看到代理就想到科学上网😂不是每一个代理都可以科学上网。

然而，Surge 却是一个非常适合科学上网的代理。之前我还想着 iOS 上面怎么搞个黑科技，通过 SSH Tunnel 代理一下，然后我就可以不用买梯子了，这下好了，黑科技出来了。


Surge 的入门以及使用可以参考「[Surge 新手使用指南][1]」。

在毕勤的[博文][2]中给出了一个好用的配置文件的链接，<http://nat.pw/nat.conf>，可以直接导入 Surge，但是导入之后需要手动修改一下服务器的 IP、端口，服务的密码密码等等关键信息。我这里为它做了个备份，<http://blog.jamespan.me/asset/surge/nat.conf>。网址长了不少，但是可用性还是有保障的，毕竟异地多活~

如果你也买了 Surge，我们还是好好地把它当做开发者工具吧，不要拿来科学上网什么的。

[1]: https://medium.com/@scomper/surge-配置文件-a1533c10e80b#.r4987iufv
[2]: https://www.lifetyper.com/2015/10/shadowsocks_conf_for_surge_on_ios.html

