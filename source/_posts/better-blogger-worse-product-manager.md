title: 提防那些 Blog 写得好的产品经理
tags:
  - Thinking
categories:
  - Life
math: true
thumbnail: //i.imgur.com/6V8npB7.jpg
cc: true
comments: true
date: 2016-01-30 11:43:25
---

{% blockquote @Fenng http://weibo.com/1577826897/DflYM05Vo %}
小龙哥饭否语录一出，天下产品经理从此歇笔不再写 Blog…
{% endblockquote %}

最近张小龙再次火了起来，一开始是微信公开课上，张小龙分享了它的产品理念，后来是他多年之前的饭否被挖了出来，被捧为为产品经理箴言。

<!-- more --><!-- indicate-the-source -->

前日深夜，一位任职产品经理的朋友从微信给我转发了一张截图，大意是说，博客写得好的产品经理都不靠谱。

![](//i.imgur.com/7sGmMQb.png)

昨晚我未能免俗，注册了饭否，连夜完整翻阅了 [@gzallen][1] 的 2351 条消息。

![](//i.imgur.com/5zakMOR.png)

就是这条饭否消息，让天下产品经理从此歇笔不再写 Blog！哈哈大笑之余，总感觉有点怪怪的，一定是哪里出了问题。

于是我尝试把这个推论翻译成谓词逻辑。

在 Blog 上花的时间越多，在产品上花的时间就越少，无一例外。在产品上花时间越少的产品经理越要被提防。

$$
\forall pm (SpendMuchTime(pm, Blog) \rightarrow SpendLessTime(pm, Product))
\\\\
\forall pm (SpendLessTime(pm, Product) \rightarrow BetterBeBewareOf(pm))
$$

当初在人工智能课程上，跟随教授重温逻辑的时候，他就告诫我们说不要把逻辑学应用在生活中，因为大部分的人其实是没有逻辑的。跟没逻辑的人讲逻辑是自讨没趣。

我终于还是忍不住破戒了。

说得好像在 Blog 上少花时间，就会在 Product 上多花时间似的。在任何非 Product 上多花时间，都会导致在 Product 上少花时间，所以不仅仅是 Blog 写得好的产品经理需要被提防，那些照片拍得好、喜欢旅游、喜欢画画，在产品之外有其他爱好的产品经理都要被提防，他们在业余爱好上花的时间越多，在产品上花的时间就越少。

$$
\forall pm (SpendMuchTime(pm, \neg Product) \rightarrow SpendLessTime(pm, Product))
\\\\
\forall pm (SpendLessTime(pm, Product) \rightarrow BetterBeBewareOf(pm))
$$

至于那些从这段话演绎出「靠谱的产品经理不写博客」、「为了不让别人以为我是不靠谱的产品经理我还是不要写博客了」的家伙，他们开脑洞的方式，没逻辑的方式，挺可爱的。

---

不知何故微信浏览器总是对我的博文做自动重排，影响阅读体验。我因为个人公众号没法认证，也就没法通过配置业务域名来绕过重排，只好在此向各位求助避免微信浏览器对页面做重排版的技术方案，求分享！

[1]: http://fanfou.com/~RLhcIDBjZAM



