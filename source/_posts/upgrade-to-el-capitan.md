title: 终于等到你，OS X El Capitan
tags:
  - OS X
  - Mac
categories:
  - Study
thumbnail: 'http://ww2.sinaimg.cn/small/e724cbefgw1ewm45mnaryj20qz0dt0wt.jpg'
cc: true
comments: true
date: 2015-10-02 04:15:14
---


经过四个多月的等待，我们终于盼来了 OS X 10.11 的升级推送，El Capitan。早上起床后，我带着满怀的激动，开始升级系统。当然，升级之前的时光机备份是必不可少的，虽然每次升级之前都做了备份以防万一，但是从来就没有回滚过系统。

一年多来，OS X 从当初的 10.9 Mavericks，到 10.10 Yosemite，再到如今的 10.11 El Capitan，每次都有让我心动不已无法割舍的杀手级特性，即便最初的版本有一些小小的瑕疵，也是瑕不掩瑜。

<!-- more -->

![](http://ww3.sinaimg.cn/mw1024/e724cbefgw1ewm4jmwty3j20yg0mzn6z.jpg)

备份完成，开始升级。随着下载进程的开始，我的心却一点一点往下沉。下载的速度实在是太慢了啊！之前从 10.9 升级到 10.10 的时候，下载只用了几十分钟，哪有这次这么夸张，居然要两天。过了几分钟后，预计的下载时间稳定在 20+h 的样子。

![](http://ww1.sinaimg.cn/mw1024/e724cbefgw1ewm4va9yy1j20w709y7a9.jpg)

这个下载速度我真的没法接受啊，等安装好了菜都凉了。我只好各种想办法提高下载速度，挂各种 VPN。几经尝试之后，我发现挂 VPN 连到香港可以获得一个可接受的下载时长，两小时左右。

![](http://ww2.sinaimg.cn/mw1024/e724cbefgw1ewm540zwcvj20w609ytf1.jpg)

香港网络有一个好，下载苹果系统的更新，跑的比谁都快！

几个小时很快就过去了，系统升级也进展到了最后时刻，接下来就是安装升级镜像了。

![](http://ww4.sinaimg.cn/mw1024/e724cbefgw1ewm6d1dkulj20m80haaax.jpg)

经过半个多小时的等待，系统终于完成了升级，等待我们的，将会是怎样的结局？

最先感受到的，是桌面背景变了，变得和下载界面的背景一模一样。按理说字体变成了「苹方」，恕我眼拙没看出来，也许是用 iOS 的这些时日已经让我对这个字体司空见惯了。

系统整体上感觉流畅不少，MissionControl 相关的各种动画也没有卡卡的感觉了，一切都如丝般顺滑。新的拼音输入法也比以前好用了很多，但是在词库、自动纠错等功能上还是稍逊搜狗一筹。

传说中的 Split View 果然好用，沉浸模式的实用性大大提高。

![](http://ww2.sinaimg.cn/mw1024/e724cbefgw1ewm6zajwlqj21kw0zknhl.jpg)

然后我开始发现一些问题。

![](http://ww1.sinaimg.cn/mw1024/e724cbefgw1ewm70ozwuwj20n309gt9w.jpg)

明明系统语言是英文，App Store 的几个 tab 下面用的却是中文，这是几个意思？这个问题比较好搞，在 App Store 中把区域切换成美国，tab 下面的字就变成英文了，然后再切回中国，tab 下面的字还是不变。嗯，这是个逼死强迫症的 bug。

还有就是 Bartender 1.x 也没法正常工作了，现象是系统程序的托盘图标没法隐藏，比如蓝牙、备份之类的图标全都跑出来了。于是我果断 brew cask 了一把，升级到 2.x，Bartender 终于正常了，还额外多出了不少新功能。话说 Bartender 虽然升级了，但是在试用期约束方面似乎并没有什么长进，还是可以被用户轻易地突破试用期的限制，无期限地试用下去。

最让我痛心疾首的，其实是 Monosnap 出了点问题。区域截图、屏幕截图一切正常，当我试图对窗口截图的时候，发现它不行了，截出来的是黑乎乎的一片。当我已经习惯了用 Monosnap 截图和编辑，用 Inboard 保存这样的工作流之后，其他的截图工具根本就得不到我的青睐。即使是出自腾讯大名鼎鼎的 Snip，也无法取代 Monosnap，因为它没法轻松地把图片保存到 Inboard 中。

于是我去一个不存在的网站和 Monosnap 的人谈笑风生了了一下下，估计很快这个问题就能从软件更新得到修复。

![](http://ww1.sinaimg.cn/mw1024/e724cbefgw1ewm7h5s5r9j20ge070dgu.jpg)

我还是相信 Monosnap 的开发者的，也许是这个问题没有出现在预览版中吧，否则早就修复了。我喜欢这个软件，也希望有朝一日能写出这样的好软件，值得我们依赖和信赖的软件。

> How else can you stare at an empty canvas and see a work of art? Or sit in silence and hear a song that’s never been written? Or gaze at a red planet and see a laboratory on wheels?
>
> We make tools for these kinds of people.

从 brew cask 安装的 CleanMyMac，不管版本是 2 还是 3，都不知何故的不能使用了，一启动就弹窗，让下载一个新的大版本相同的 CleanMyMac。下载安装之后确实可以使用了，但是我还是花了 50RMB 去购买了 CleanMyMac 3 的 License，现在有升级半价的优惠。

最近苹果的数字娱乐大举入华，前景让人看好。毕竟对于我们这些讲究体面的年轻人，和越来越庞大的中产阶级来说，如果能以合适的价格买到优质的正版内容，谁愿意浪费生命和承受内心的罪恶感去使用盗版呢？

Apple Music 一个月 10 块钱的价格近乎白送，用还不到一顿饭的价格，换一个月的正版音乐授权，怎么看似乎都是赚了。然而今天下午我尝试播放了一会，发现音乐卡顿十分严重，甚至一度无法完整播放一首歌，体验甚是糟糕。

![](http://ww2.sinaimg.cn/mw1024/e724cbefgw1ewm8ofy4msj20xo0n7wnc.jpg)

当时我的内心是崩溃的，只能默默关掉 iTunes 打开了网易云音乐。然而到了深夜再次尝试播放的时候，卡顿消失了。对此我只能怀疑是下午遭遇流量高峰而苹果的流媒体分发不足以支撑这么高的流量了。希望苹果尽快搞定~

不久之前，iBooks 上的中文书籍可以说是寥寥无几，只有基本聊胜于无的古籍，比如红楼梦、西游记之类的早已没有版权的著作。今天再看的时候，似乎让人感觉到 iBooks 的中文内容也在渐渐有了气候，虽然上架的书籍以快餐类为主，但是目前的电子书市场，哪个不是快餐呢？

![](http://ww4.sinaimg.cn/mw1024/e724cbefgw1ewm8di8vwhj20vk0o6n49.jpg)

最近东野圭吾的小说莫名走红，各大电子书内容分发渠道也是跟风推荐，《从 0 到 1》前些日子也是热的不行。我下载了几本电子书的试读章节，想看看电子书的制作程度。结果我只能说非常一般，排版上毫无诚意，相比起多看、亚马逊毫无竞争力，让我仿佛回到了高中那种看盗版小说的年代。

![](http://ww4.sinaimg.cn/mw1024/e724cbefgw1ewm8kef7cnj20x20oy11c.jpg)

至于 iTunes 电影，我找了一部免费电影《智取虎威山》作为尝试。跟购买软件类似，开始下载后不久，就弹出窗口询问是否开始播放。

![](http://ww3.sinaimg.cn/mw1024/e724cbefgw1ewm8y6abilj20ww0mfn2n.jpg)

不知道苹果搞了什么飞机，当 iTunes 正在播放影片时，对 iTunes 做截图，影片部分就变成灰色的了，莫非真是版权保护？

历史总是惊人地相似。在苹果的努力下，Mac 渐渐从生产力工具向内容消费工具靠拢，而苹果又一次扮演交易平台的角色，靠抽成赚得盆满钵满。

苹果出手收割个人和家庭娱乐市场了，国内的视频网站们，你们准备好了吗？


