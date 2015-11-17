title: 异步加载非核心 CSS
tags:
  - JavaScript
categories:
  - Study
hljs: true
cc: true
comments: true
thumbnail: //i.imgur.com/Lj52nPzb.jpg
date: 2015-11-17 03:03:46
---


昨天晚上在公司加班，和同事一起复盘双十一团队内各个系统的情况。突然收到邮件，啊哈，有人评论我的文章了~

从手机上打开页面，发现卡的不要不要的，老半天才打开。回家后从电脑上打开一看，居然是一个 Web Font 挂了导致整个页面加载过程变得十分漫长。

为了让博客里面的代码块稍微好看一点点，我用[中科大的 Google Fonts 服务][1]加载了 Source Code Pro 这个字体。

<!-- more -->

按照设定字体的惯例，我们会为字体设置 fallback，当 Source Code Pro 不可用时，自动降级为其他字体。什么叫「不可用」呢？比如找不到字体，或者加载字体超时之类的，应该算不可用吧。

然而不幸的是，在 Safari 上，加载 Web Font 这种事情，似乎是没有「超时」一说的[^1]。实际上当中科大的 Web Font 挂掉时，甚至连加载 Web Font 都走不到，请求描述 Web Font 的 CSS 就已经超时了。

[^1]: [CSS Font Rendering Controls Module Level 1][2]

好吧，不管怎么说，博客服务器虽然没挂，但是在渲染上却被一个锦上添花的 CSS 给拖垮了。就在刚才我还在复盘中说「对弱依赖要做好容错、超时和自动降级，不要因为弱依赖不稳定而影响主流程」，结果现世报这就来了。

如何加强页面渲染的稳定性呢？一开始我受思维定势的影响，想要给 `<link>` 标签增加 timeout 属性。但是，HTML 标准里面没这种东西啊。好吧，那么像 `<script>` 标签那样来个 async 实现异步加载如何？也没有。

于是我就开始搜索异步加载 CSS 的各种解决方案，也找到一些天马行空不知所云无法重现的文章，比如 ["Async" CSS without JavaScript][3] 和 [Unblocking blocking stylesheets][4]。

最后还是找到一个比较靠谱的 JavaScript 解决方案，[filamentgroup/loadCSS][5]。

loadCSS 要求在页面的 head 区域通过粘贴代码或者引用文件的方式完成初始化，随后只需要简单的调用函数，传入需要异步加载的 CSS 即可。

```html
<head>
  <script type="text/javascript">
    !function(e){"use strict";var n=function(n,t,o){var l,r=e.document,i=r.createElement("link");if(t)l=t;else{var a=(r.body||r.getElementsByTagName("head")[0]).childNodes;l=a[a.length-1]}var d=r.styleSheets;i.rel="stylesheet",i.href=n,i.media="only x",l.parentNode.insertBefore(i,t?l:l.nextSibling);var f=function(e){for(var n=i.href,t=d.length;t--;)if(d[t].href===n)return e();setTimeout(function(){f(e)})};return i.onloadcssdefined=f,f(function(){i.media=o||"all"}),i};"undefined"!=typeof module?module.exports=n:e.loadCSS=n}("undefined"!=typeof global?global:this);
  </script>
</head>

<script type="text/javascript">
  loadCSS("//fonts.lug.ustc.edu.cn/css?family=Source+Code+Pro:300,600");
</script>
```

然后制定的 CSS 就异步加载了，即使某个 CSS 加载出来需要很长时间，也不会阻塞页面渲染，只是在 CSS 成功加载之后去重绘页面。

然后我就用这个神器把页面上能替换的同步 CSS 请求给替换为异步的了~


[1]: https://servers.ustclug.org/2014/06/blog-googlefonts-speedup/
[2]: https://tabatkins.github.io/specs/css-font-display/#intro
[3]: http://codepen.io/Tigt/post/async-css-without-javascript
[4]: http://blog.yoav.ws/2011/10/Unblocking-blocking-stylesheets
[5]: https://github.com/filamentgroup/loadCSS
