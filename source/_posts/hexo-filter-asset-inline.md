title: 一个内联展开页面资源的 Hexo 插件
tags:
  - Blogging
  - Node.js
  - Hexo
categories:
  - Study
hljs: true
thumbnail: //i.imgur.com/zVPUz83m.jpg
cc: true
comments: true
date: 2015-11-19 15:32:32
---

这两天我又为 Hexo 写了一个插件，详见 [JamesPan/hexo-filter-asset-inline][4]。

前一篇博文「[异步加载非核心 CSS][1]」中，我使用 loadCSS 实现了非核心 CSS 文件的异步加载，这样子即使这些位于公共 CDN 上的锦上添花的 CSS 不可用，也不至于阻塞博客的访问。

那么，既然有「非核心」CSS，那么什么是「核心」CSS，什么是「核心」JS？在我看来，「核心 CSS」就是那些一旦缺失，整个页面立刻崩坏的 CSS，「核心 JS」就是一旦缺失，页面上某些重要功能就会不可用的 JS。

<!-- more --><!-- indicate-the-source -->

如果我的博客缺失了 <http://blog.jamespan.me/css/style.css>，就会变成下面这种惨不忍睹的模样。

![样式崩坏，惨不忍睹](//i.imgur.com/PMojwhI.png)

同理，当我的页面需要渲染代码的时候，highlight.js 的 JS 和 CSS 都是强依赖。

有没有可能把这些必不可少的 CSS 和 JS 直接内联展开到 HTML 文件里面？内联展开之后，只要 HTML 页面加载完成之后，即使其他的资源全都不可用，比如图床 Imgur 不可访问，或者 BootCDN 挂了，整个页面也是可用的。

我们一般都认可，一个 self contained 的软件，比如一个 Golang 静态编译出来的应用，或者一个自带 Tomcat 的 fat jar，在部署成本上是比较低的，至少不会受到千奇百怪的依赖缺失或者版本不对的困扰。

但是具体到 Web 页面上，一个 self contained 的页面，是否总是比较好的选择？其实并不一定。把资源内联到页面之后，在可用性上自然是提升到了无以加复的程度，甚至还节省了和服务器通信询问文件是否有修改的一个 RTT，但是代价却不菲，它需要更多的带宽来为每个页面下载几乎是重复的资源，浏览器也需要为每个页面重新渲染资源。

关于内联资源的一些说法和讨论，可以看 [Inline small CSS][2] 和 [Inline \<script\> and \<style\> vs. external .js and .css — what's the size threshold?][3]。

没有银弹是软件工程领域唯一的银弹。直面问题，做出取舍，解决问题，自然就成了开发者存在的意义之一。由于我一直不想给域名备案，所以是基本上和国内的各种 CDN 说再见的。不能用堆机器用 CDN 加速的我，只能考虑其他方案让页面加载更快更稳。

考虑到我的博客的前端服务器在新加坡和香港，和大陆地区的 RTT 一直在 200ms 到 300ms，而为了完整加载博客页面，浏览器需要和前端服务器通信三次，分别请求 HTML，CSS 和 JS，即使有浏览器缓存也还是得让服务器返回 304 才可以用缓存的内容。假如我能去掉后两次通信，半秒钟的时间就差不多省下来了。从页面加载的时间线来看，大部分的时间都消耗在等待上了，TTFB 占了大头。

另一方面，假如我把公共 CDN 上的强依赖资源也给内联了，页面发布之后就变相去掉了对 CDN 的强依赖，只要读者能访问我的服务器，只需要一次通信就能得到可用的页面，即使 CDN 挂了影响也基本可以忽略。

不知道什么时候开始，我对服务的可用性有奇怪的追求，总是不希望有单点故障，不希望被非核心功能的故障影响核心功能的可用性，药丸。

简单上网找了一下已有的轮子，发现一个叫 [grunt-inline][5] 的国人写的插件。研究了一下之后发现要用它来对 Hexo 产生的一大堆页面做内联似乎有点难度，于是我决定自己动手造个轮子。

我希望这个插件对整个博客系统能够做到比较低的侵入，装上插件之后就根据一些标记有选择的内联资源，卸载插件之后这些标记也不影响非内联模式的访问。于是我在标记上参考了 grunt-inline 的做法，URL 后面带上参数 `__inline=true`，就认为应该要被内联。要想做到低入侵，比较优雅的方式是在 Hexo 处理页面的流水线上插入一个插件，这就是[过滤器（Filter）][6]。

插件的工作方式是，当 Hexo 完成一个 HTML 的渲染之后，调用 hexo-filter-asset-inline 进一步加工，扫描页面中的 `<link>` 和 `<script>` 元素，把带有 `__inline=true` 的资源给就地展开。

开发过程中遇到的一个坑，是内联展开 highlight.js 之后，JS 代码中的 `</script>` 标签，错误地把外层的 `<script>` 给闭合了。这种坑还没法简单的对 JS 文件整个做 html escape，只能用比较脏的手法，直接在代码中做字符串替换。

```js
cached = cached.toString();
cached = cached.replace(/<\/script>/g, "\\u003c/script\\u003e");
var block = opening_tag + cached + closing_tag;
$(this).replaceWith(block);
```

目前我的实现还不支持资源的递归展开，所以就没法很好地支持有资源嵌套引用的 CSS，比如 font-awsome 和 web font 之类的，虽然这些资源表面上只是一个 CSS，实际上加载了第一层的 CSS 之后，还需要递归地请求多个资源。

我花了一个晚上做实现，一个早上写测试 + README + 各种 Badge。虽然这是我第二次写 Hexo 插件，但是用 Node.js 写单元测试，搞代码覆盖率等等还是头一回。

![](//i.imgur.com/zAMr7sH.png)

虽然覆盖率没到 100%，但是这么多 badge 一字排开还是感觉棒棒哒。

这就是我的博客演化到目前的样子了，强依赖全部内联，弱依赖全部异步。

就在我刚写完 README 不久，我就又找到了一个功能类似的轮子，[remy/inliner][7]，乍一看好像已经支持资源的递归展开了，呜呜呜。其实除了在静态文件上做文章，还可以在 Web 服务器上搞一个，Google 的 ngx_pagespeed 插件，就能在 Nginx 上直接把体积小的资源文件内联到页面中。

看来在我把这个插件改到能支持递归资源展开之前，还是不要轻易提交到 Hexo 的插件列表的好😂


{% blockquote phodal http://mp.weixin.qq.com/s?__biz=MjM5Mjg4NDMwMA==&mid=401925145&idx=1&sn=d7fc0ddc992e265f10fbc355b0223fd4&scene=1&srcid=1115PLNI9oFsLSnlRXajzUxS&from=groupmessage&isappinstalled=0#wechat_redirect CMS的重构与演进 %}
作为一个博主，通常来说我们修改博客的主题的频率会比较低， 可能是半年一次。如果你经常修改博客的主题，你博客上的文章一定是相当的少。
{% endblockquote %}

最近看到一篇博文，说是经常折腾博客的博主，文章一定相当少，看来我是个一边折腾博客一边还写了不少文章的奇葩博主呢~

By the way，最近居然有人对我的博客发起「评论洪泛攻击」。别看我描述得这么高大上，其实是调用 Disqus 的 API 疯狂提交评论，也是醉了。自由开放的网络社区真的这么容易被破坏么？

![](//i.imgur.com/DLNXoMt.png)

[1]: /2015/11/17/load-css-asynchronously/
[2]: https://varvy.com/pagespeed/inline-small-css.html
[3]: https://mathiasbynens.be/notes/inline-vs-separate-file
[4]: https://github.com/JamesPan/hexo-filter-asset-inline
[5]: https://github.com/chyingp/grunt-inline
[6]: https://hexo.io/zh-cn/api/filter.html
[7]: https://github.com/remy/inliner

