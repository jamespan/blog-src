title: Velocity China 2015 见闻录（一）
tags:
  - Speech
categories:
  - Study
photo: 'https://ws2.sinaimg.cn/large/e724cbefgw1ev2oqr6u80j20k203ht98.jpg'
cc: true
comments: true
date: 2015-08-16 22:02:04
---


上周有幸出差去北京参加 [Velocity China 2015][1]，感谢师兄北岩~

Velocity 大会在永泰福朋喜来登酒店召开，刚到帝都那天晚上我和同事下榻在一个偏僻的汉庭快捷酒店，第二天一早换到一个距离会场更近的酒店入住。

第一天，9:30 大会开始，我们踩着时间点来到会场，领取了入场券，开始听分享。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

![大牛们谈笑风生，小菜们学习一个](https://ws1.sinaimg.cn/mw1024/e724cbefgw1ev2obukbsvj21kw16o7kl.jpg)

![入场券](https://ws4.sinaimg.cn/mw1024/e724cbefgw1ev4bunt1akj21hs1hsqrr.jpg)

# 现代互联网标准 #

第一场是关于[现代互联网标准][2]的主题发言。

Mark Nottingham 先是回顾了 Web 标准的发展历程，从 1992 年 [IETF][3] 制定 TCP/IP、FTP、HTTP 等协议的标准，到 1994 年 W3C 的成立以及各种 Web 标准。W3C 也没法逃脱日渐臃肿的命运，几个 Web 技术巨头在 2004 年成立了 [WHATWG][4]，正是这个组织带头弄出了 HTML5。

到了 2013 年，"web standard is trying to put itself out of business"，努力使自己越来越贴近现实工程。Mark 以 [The Extensible Web Manifesto][6] 为例表明 Web 技术正在向着可扩展的方向演进，借助 [Web Components][5] 这种能够自定义 HTML 标签的技术，开发者能够更加容易的对 Web 做出自己的贡献，进而沉淀为标准。

Web 发展到今天，已经不再是过去的文档交换系统了，而是一个全球化的应用交付平台。然而，支撑着 Web 的各种技术和浏览器还在不断地变化，于是 W3C 搞了一种叫做 [Test the Web Forward][7] 的活动，让大家一起贡献 Web 标准的测试用例，促进 Web 的标准化。

最后，Mark 给了一些建议，让开发者能够更好地向 Web 标准贡献力量。

1. Start Small，先要熟悉现在的 Web 是如何协作、工作的，到 [WICG][8] 去提问，给 [Test the Web Forward][7] 贡献测试用例，加入一个讨论组或者创建一个
2. Build Relationships，标准涉及到协作，是一个带有社会性的东西，面对面的沟通必不可少，可以去 HTTP Workshop 之类的地方交流
3. Be Patient，各种标准从出现到正式定稿无不耗时多年，一定要有耐心
4. Stay Backwards Compatible，新事物不要破坏旧事物，通过可扩展性实现渐进式的增强才是王道
5. 最后，成为了标准并不能保证就能获得成功，Runing code wins

# 管理复杂系统 #

第二场是关于[管理复杂系统][9]的发言。

Thomas Jackson 是 LinkedIn 的 Site Reliability Engineer。这个工种国内似乎比较少见，据 Thomas 描述，这个工种有以下几个特点：

1. Hybrid of operations and engineering
2. Heavily involved in architecture and design
3. Application support ninjas
4. Masters of automation

看起来狂拽酷炫，能运维能开发，精通架构和设计，能搞各种自动化，应用挂了还能救火！

Thomas 和我们分享了 LinkedIn 在成长过程中，一点一点把系统对人的依赖降低的故事，最核心的东西就是自动化。

最开始的时候，大概在 2011 年，整个系统的开发运维都是靠人去完成，甚至做了很多本不应该由人去做的事情，主要是以下三点：

1. Manual approval
2. Manual writting of configs for hardware and datacenters
3. Manual deployments

当系统复杂到一定程度之后，现有的人已经搞不定了，LinkedIn 面前有两条路：

1. Stay the same and throw people at it
   + more reviews
   + more tickets
   + more manual latency
   + slow down the change rate
2. Change and automate

这些问题，一个持续发展的技术企业迟早会遇到，然而不同的选择会导致不同的结果。和显然，LinkedIn选着了作出改变，拥抱自动化。

最近有一种观点，是人管代码，代码管机器，Thomas 的分享也支持了这种观点。

> Don't write configs, write code!

定义一个你想要的世界，然后用代码实现它。

在自动化部署方面，LinkedIn 的实践是使用 [SaltStack][10]，一个据说能够轻松管理上万台服务器的运维神器。

> You break something, don't touch it.  
> Don't touch it is not the solution.

故障 Review 是每个开发者的必修课，从故障中吸取经验教训是 review 的目的。LinkedIn 的故障 Review（Post Mortems）主要包含以下几件事：

1. Timeline
   + Go over the timeline(which has been gathered before the metting)
   + Simply walk through what happened in order
2. Discussion
   + Discuss the steps that led to the issue
   + Determine what types of peroblems they were(people, process, or automation)
3. Action Items
   + Agree on and create list of items to do that would avoid/remediate this issue
4. Follow up
   + Follow up on those action items to ensure they get closed out

# 上午茶歇 & 广告 #

茶歇有水果和点心，点心其实就是趣多多之类的饼干，饮料只有黑咖啡+糖或者茶，还得排好长的队才能拿到，排队期间就是各个赞助商的 PLMM 各种安利我们去扫描他们的二维码注册，然后送一些小玩意，最没诚意的小玩意估计就是冰箱贴了`(╯‵□′)╯︵┻━┻`。

茶歇结束之后是赞助商广告时间，这次的赞助商主要集中在 APM 领域，提供 Saas 化的应用监控、性能剖析、性能优化的解决方案，基本上都是说自己能做到什么什么事情，全国有多少多少个 CDN 节点之类的。

# 框架和性能 #

第三场是关于 [Yahoo 前端框架进化史][11]的发言。

朱凌燕是 Yahoo 首页的前端架构师，她以前端开源框架、组件的选型为切入点，为我们分享 Yahoo 首页这几年来的架构变迁。

前端技术正处在一个井喷式发展的时期，如何从琳琅满目的技术中，做出合适业务、合适团队的选择，成了架构师需要考虑的问题。她建议我们从如下方面去做技术选型：

1. Easy to Learn，代码要容易看懂，文档要齐全，最好能够贴合团队的技能点
2. Easy to Debug，开发环境要容易调试，生产环境出了问题也不能抓瞎
3. How Active，产品 release 的频度、贡献者、关注数等等指标都要留意
4. Stability，不仅仅是稳定性，还有各种向后兼容性的承诺
5. Is it Performant，挑选最核心的用例，快速实现原型，做性能基准测试

Yahoo 的首页类似于国内的门户，是一个信息量极大的网页，包含各种模块。最开始的时候，后端使用内部的 PHP 框架，前端使用 YUI。YUI 是 Yahoo 的前端框架，屏蔽了各个浏览器之间的差异，对外提供一致的接口。前后端之间使用 AXJX 交换数据，没有共享代码，没有 Client Side Navigation。开发者总是得在后端开发和前端开发模式中切换，比较痛苦。

后来有了 Node.js，使得前后端开发语言看到了统一的希望。Yahoo 首页的前端架构也跟进升级，YUI 变成了一个跨服务端和客户端的庞大类库，服务端使用 Node.js 和 Express 进行开发。这个时候，前后端共享了 YUI 的代码，也解决了开发人员切换模式的问题，却引入了新的问题：性能。首先是 YUI 类库变得异常庞大，整整 23MB，其运行效率也变得缓慢。

穷则思变，先从服务端开刀，改进性能。首先是 YUI 退出服务端，前后端之间不共享代码，仅共享模板，然后是客户端搞了一个叫 YUI App Framework 的东西。好处是服务端性能上去了，但是有些问题又回来了：前后端之间用的不是一套 MVC，而且客户端性能依旧堪忧。

再接下来就是优化客户端性能，使用原生 JavaScript 以便在现代浏览器上获取高性能，使用 React 和 Flux 取代过时的 YUI App Framework，如今 Yahoo 首页的代码又回到了前后端共享代码的架构上，只不过这次共享的不再是 YUI，而是 Fluxible、React 和 CommonJS。

Yahoo 前端架构的发展历程就像是一个又一个的轮回，盘旋上升。然而我们还不知道系统的未来在哪里，下一次架构变革会是怎样。预测未来的最好方法，就是创造未来，如果创造未来没那么容易，那么我们至少为创造未来做好准备，朱凌燕给了 3 个建议：

1. Simplicity，来自 Unix 的哲学，KISS
2. Don't be Dogmatic，不要教条不要僵化，最牛的人写的最好的软件也有其局限性
3. Embrace Open Source，拥抱开源，站在巨人的肩膀上


[1]: http://velocity.oreilly.com.cn/2015/
[2]: http://velocity.oreilly.com.cn/2015/index.php?func=session&id=21
[3]: https://zh.wikipedia.org/wiki/互联网工程任务组
[4]: https://zh.wikipedia.org/wiki/網頁超文本技術工作小組
[5]: http://www.w3.org/TR/components-intro/
[6]: https://extensiblewebmanifesto.org
[7]: http://testthewebforward.org
[8]: http://discourse.wicg.io
[9]: http://velocity.oreilly.com.cn/2015/index.php?func=session&id=15
[10]: http://saltstack.com
[11]: http://velocity.oreilly.com.cn/2015/index.php?func=session&id=12

