title: 博客折腾记之网址变更
tags:
  - JavaScript
  - Blogging
categories:
  - Study

cc: true
comments: true
hljs: true
date: 2015-04-12 23:09:46
---

# 背景 #

一开始的时候，我的博客同时托管在 Github Pages 和 GitCafe Pages 上，那时候只能通过 Github 和 GitCafe 提供的域名，panjiabang.gitcafe.io/blog/ 或者 jamespan.github.io/blog/ 来访问。

后来，我在万网买了个域名，jamespan.me，然后把域名解析到了 GitCafe 上。为什么选择解析到 GitCafe 而不是 Github，这得问问世界七大奇迹之一。于是我们可以从 www.jamespan.me/blog/ 访问我的博客了。

过了大概三四个月，我渐渐觉得似乎使用 blog.jamespan.me 作为博客的域名会好一些。于是，就在今天，我开始了切换博客域名的尝试。

我是不折腾会死星人。

<!-- more -->

# 方案 #

我希望在切换了博客域名之后，原先的博客依旧能够照常访问。因为之前的博客已经有不少页面被 Google 索引，如果因为切换域名导致索引失效，对于博客整体的影响还是很坏的。

考虑到原先的博客的 URI 结构，要想在原工程上实现新域名的兼容，对我而言难度极大。新开一个项目来托管新博客是一个相对而言最稳妥的方案。

除了保留原博客之外，我还希望能有一些方式，能够把访问原博客的读者，以比较自然的方式，引导到新博客上来。我想到的方式有两种，一种是页面跳转，一种是原博客博文中给出指向新博客博文的链接。

对于页面跳转而言，比较常见的方式是 Web 服务器给访问老域名的请求返回一个 302，然后跳转到新域名上。考虑到我使用的托管服务是没有可能让我去配置 Web 服务器的，我只能把跳转动作通过 JavaScript 实现。

假设我能通过 JavaScript 实现页面跳转的功能，是不是就万事大吉了呢？不是的，现实世界中有很多的网站访问者，是没法执行 JavaScript 的，比如可爱的爬虫，还有一些把 JavaScript 禁用了的用户。

为了能够应对这种没法执行 JavaScript 的情况，我需要一种降级方案，就是在原博文中给出指向新博文的链接。

# 降级 #

能不能用 JavaScript 实现跳转我不清楚，降级方案我倒是可以分分钟弄出来，先把有把握的事情做了。

我在主题里加了一个 ejs 文件，然后对博文的渲染过程稍作修改，在正文之前插入我新增的 ejs。接下来就是编写文案了。最后做出来是这个效果。

![新博客引导文案](http://ww4.sinaimg.cn/large/e724cbefgw1et2gmz8u3zj20py0d2acc.jpg)

基本上我的每篇博文都有被 Google 收录，比如直接搜索 [babun][3]，就可以在第一页看到我的博文，位置仅次于 Babun 的官网和 Github。

![Google 搜索 babun](http://ww4.sinaimg.cn/large/e724cbefgw1ery7lkoll1j20rp0r8doh.jpg)

在博文之前加上这段文字之后，博客的新域名一下子就多出了不少入链，新博文不但有入链，还有相应的锚文本。

我一直用大三时候从《自然语言与信息检索》这门课里学到的关于搜索引擎的粗浅的知识做简单的 SEO，效果还是有一点的。之前我把博客域名从 www.gitcafe.io 换成 www.jamespan.me 的时候，也是差不多经历了一次砍掉重练。当时博客还没有多少篇文章，重新做 SEO 还是比较简单的，这次估计挑战不小。

# 跳转 #

搞定了降级方案，接下来就是尝试着去用 JavaScript 做跳转了。

之前给博客做[时间轴][1]的时候，用到过页面跳转，当时的博文《{% post_link redirect-with-js %}
》也记录了我的探索过程。

这次和上次稍有不同的是，上次的跳转没有跨域，直接使用相对路径跳转。这次的跳转跨域了。由于我对 JavaScript 的研究并不深入，仅仅是知道语法，能在文档手册的帮助下写出代码的水平，跨域什么的只是有所耳闻。

虽然后来证实页面跳转的功能和是否跨域没有关系，但是正是因为我有着先入为主的顾虑和对未知领域的心虚，让我走了不少弯路。

因为这次的跳转涉及对 URL 的解析操作，像我这种懒人一向是能调用现成的库的绝不自己写，于是就把当初写 Timestamp App 用到的 purl 库又拿来用了。

最开始的代码是这样的。

```js
<script src="http://cdn.bootcss.com/purl/2.3.1/purl.min.js"></script>
<script>
var url = purl();
if (url.attr('host') == 'www.jamespan.me') {
	var old_url = url.attr('source');
	var new_url = old_url.replace('/www.jamespan.me/blog', "blog.jamespan.me");
	window.location.replace(new_url);
}
</script>
```

然后我修改了 hosts 之后试着访问了页面，结果是出错了。

```
Cannot GET /blog.jamespan.me/2015/04/09/babun-the-shell/
```

这时候我就被跨域问题先入为主了，开始各种找跨域问题的解决方案，甚至尝试在页面加载之后把 body 整个替换成 iframe，然后在 iframe 中加载新页面。

后来我才发现，错误的原因很简单，就是我在替换的时候，被替换字符串中多了一个“/”而已。真是个愚蠢的小问题，被自己蠢哭了😭。

于是从浏览器访问 www.jamespan.me/blog/ 的读者，都会被重定向到 blog.jamespan.me，可能前一两次访问会因为浏览器缓存的原因没有跳转，但是缓存失效之后，跳转就开始了。

# 尾声 #

这次更换博客域名，总体上还算顺利，虽然有些愚蠢的小问题发生，但也因此学到了一些关于跨域的知识，有得有失吧。

原先的博客基本上不会再更新了，就让它随着时间的流逝，消失在次元的彼岸吧~

最近电信运营商各种篡改流量插小广告，简直不要碧莲，独立博客要放广告也是博主自己放才是。去年 Github Pages 支持了 HTTPS，有时间的话我会尝试着把网站迁移到 Github Pages 上，直接全站上 HTTPS，看你丫怎么放小广告。

[1]: /timeline/
[3]: https://www.google.com.hk/#q=babun
