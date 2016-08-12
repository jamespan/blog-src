title: Arc Touch BlueTooth，我的新玩具
tags:
  - Device
  - OS X
categories:
  - Life
thumbnail: 'https://ws4.sinaimg.cn/small/e724cbefgw1ev3ft15d9cj20qo0hr7b9.jpg'
cc: true
comments: true
date: 2015-08-15 18:08:02
---


一直想要拥有一枚蓝牙鼠标，特别是在我拥有了一台蓝牙机械键盘之后。

考虑到我是 Mac 用户，在蓝牙鼠标的选择上，默认选项应该是 Apple Magic Mouse。这款鼠标不仅血统纯正，而且逼格之高简直突破天际。然而我有更多的考虑。

<!-- more --><!-- indicate-the-source -->

首先是实际的使用体验。触摸鼠标、多指触控等等优秀的体验，对于大多数人来说，使用的时候爽得飞起，但是对于一小群手心手指容易出汗的人来说，使用体验简直就是灾难。也正因为如此，当年我使用 Android 手机的时候，一个必不可少的条件就是支持“湿手触摸”。

出于对自身缺陷的考虑，我还是决定对 Magic Mouse 敬而远之。一番搜索之后，找到了 M$ 出品的一款鼠标，[Arc Touch Bluetooth][1]。

我对微软的鼠标是早有切身体会，从早期的经典之作 IE 3.0，到后来的折叠鼠标 Arc Mouse，我都有用过或者试用过，只是后来着了灯厂的道，才在大学之后基本一直在用雷蛇的鼠标。

虽然 Arc Touch Bluetooth 表面上写着仅支持 M$ Windows 8.1 之类的系统，但是网上其他文章表明，这款鼠标是可以连接 Mac 使用的[^1]。于是我在京东下单来一发，第二天就到了。

[^1]: [张弛有度 — 微软 Arc Touch 蓝牙鼠标][2]


值得一提的是，下班之后回家之前，我更新了操作系统，升级到 OS X 10.10.5。

第二天拿到鼠标之后，有些小激动。

![鼠标外包装](https://ws3.sinaimg.cn/mw1024/e724cbefgw1ev3cfyt58tj21kw1kwwyo.jpg)

打开包装之后，里面的鼠标和想象中的一模一样，对我来说，no surprise 就是坠吼的。

![鼠标开箱](https://ws4.sinaimg.cn/mw1024/e724cbefgw1ev3cp4awizj21kw1kw4k3.jpg)

鼠标的使用过程当然不会是一帆风顺，在蓝牙配对上就遇到了困难。

按照说明书的步骤开始配对之后，不知道是不是鼠标的存在感太薄弱，电脑一直无法发现它的存在。各种折腾无果之后，开始向 Google 求助，发现 Apple 的论坛上似乎有相关内容[^2]。

[^2]:[Since upgrading to Yosemite my Apple Bluetooth Mouse ...][3]

然并卵，按照帖子里的操作流程甚至后面给出的链接里面的操作把 Bluetooth PAN 删除之后并重启，也没法在附件的蓝牙设备中发现鼠标。

各种尝试无果之后，我开始考虑是应该退货，还是留着等待奇迹，或许机缘巧合之下我也有能在 Mac 上用上它的一天。

没想到的是，这一天来得这么快。

我拿起刚才一直没有开启的蓝牙键盘，准备写点东西，惊奇地发现电脑没法识别键盘的输入了。从蓝牙设备列表中删除了键盘之后，再次开启配对也没法找到键盘，这场景多么的熟悉，刚才配对鼠标的时候不就是这样么。这时候的心情，既开心又担心，开心的是或许我可以不用把鼠标退回去了，担心的是系统升级引入了 bug，让我连键盘都用不了。

再次求助于 Google 之后发现，我不是一个人！有人遇到了类似的问题[^3]，然后在 MacX 的论坛提问了。

[^3]: [10.10.5 系统更新后蓝牙不能使用了][4]

最终解决问题的过程也是异常的简单，关机，然后在启动的同时按住 Command-Option-P-R 来还原 NVRAM/参数 RAM 设置，然后就可以完成蓝牙设备的配对了。

知乎上面有关于这个组合键的讨论[^4]，看得我云里雾里的。虽然不知道为什么，但是至少把蓝牙给弄好了~

[^4]: [Mac开机时按住Command+Option+P+R 键，重置Pram和Nvram...][5]

总体来说呢，Arc Touch Bluetooth 这款鼠标在手感和灵敏度精确度等等指标上，跟灯厂的鼠标那是相差了十万八千里，但是作为一款便携的蓝牙鼠标，那是相当的赞，也十分贴合它移动办公的定位。

这款鼠标很有意思，能屈能伸的，掰弯开机，掰直关机，想必会深受腐女们的喜爱~

Arc Touch Bluetooth，你值得拥有！

[1]: https://www.microsoft.com/hardware/zh-cn/p/arc-touch-bluetooth-mouse
[2]: http://www.dgtle.com/article-8346-1.html
[3]: https://discussions.apple.com/thread/6778301
[4]: http://www.macx.cn/thread-2168754-1-1.html
[5]: http://www.zhihu.com/question/20401972
