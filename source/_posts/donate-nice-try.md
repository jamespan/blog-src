title: 想要捐赠？想得美！
tags:
  - Sketch
categories: [Life, Essay]
cc: true
hljs: true
comments: true
date: 2015-03-18 01:48:26
---

前些日子，我在浏览简书上的文字的时候，注意到了文章的最下方，有一个可以让读者点赞的地方。比如垠神新作[对的人](http://www.jianshu.com/p/8f9a5be17499)，短短几个小时，收获了 61 个喜欢。

![王垠-对的人](http://ww3.sinaimg.cn/large/e724cbefgw1exdxplrrk0j20h908r3yv.jpg)

<!-- more -->

简书是我觉得很赞的一个内容分享社区。从“找回文字的力量”，到“交流故事，沟通想法”，虽然格调日趋下降，但是也因为用户基数的增加，这个社区变得愈发的丰富多彩。

我也曾经在简书写过一篇文章，关于我毕业时候的感想，对不堪回首的本科四年说再见，顺便吐槽所谓的“国之大学”。

后来，为了维护码农博客的高冷，我买了域名搭建了独立博客。其实我是嫌弃简书把我的文章变成了 URL 中一串由散列算法生成的毫无意义的字符串。

至于那些博客园、CSDN，我更是敬而远之，博客园上那个曾经被我用来发 ICPC 算法题解的博客，已经消失在了次元的彼岸。

后来，我在微博文章的最后看到了一个大大的“赏”字。

![微博打赏](http://ww3.sinaimg.cn/large/e724cbefgw1exdxpwrcxlj20go041t8l.jpg)

我开始思考，是否我也能在我的博客弄一个类似的点赞、打赏的东西，让我在写博客之余收获一些虚无的成就感？

考虑到点赞的功能多说已经帮我做好了，我只需要弄一个打赏的功能。

首先想到的是支付宝的付款链接。令人头疼的是，支付宝的付款链接功能已经下线，我只能另辟蹊径。

最终做出来的效果是这样的。

![捐赠](http://ww1.sinaimg.cn/large/e724cbefgw1exdxq749oaj20n1027dg1.jpg)

如果有读者点击了绿色按钮，会在新标签页中打开支付宝的转账页面。为了能够知道是我的哪篇文字让读者产生了鼓 (juān) 励 (zèng)我的冲动，我在备注里写上了文章标题。

![转账](http://ww4.sinaimg.cn/large/e724cbefgw1exdxqhl1kej20f308pwf2.jpg)

这个捐赠按钮的实现很简单，就是向支付宝的转账页面 POST 一个表单而已。

```html
<form accept-charset="GBK" action="https://shenghuo.alipay.com/send/payment/fill.htm" method="POST" target="_blank">
  <input name="optEmail" type="hidden" value="panjiabang@qq.com">
  <input name="payAmount" type="hidden" value="10">
  <input id="title" name="title" type="hidden" value="来自博客读者的鼓励">
  <input name="memo" type="hidden" value="你的文章《<%- page.title %>》写的不错嘛，小小鼓励一下，要继续加油哦~">
  <input name="pay" type = "submit" value="鼓 (juān) 励 (zèng)">
</form>
```
值得一提的是，为了弄这个捐赠表单，我还专门注册了个支付宝小号。假如我就这么大摇大摆的把常用支付宝帐号贴在页面上，谁知道会发生什么事情，哪怕是被无聊的人暴力登录到锁账户，也够你恶心一壶的了。

其实我不是真的求爷爷告奶奶要来自读者的捐赠，这么十块八块的钱我也不缺，就是想看看我的博文到底价值几何。

然后我想明白了，就凭现在的我，即使博文里写出花来，也是收不到捐赠的。

正所谓“藏诸名山，传之其人”，倾注了心血和时间的作品，如此轻易的出卖，岂不可惜？
















