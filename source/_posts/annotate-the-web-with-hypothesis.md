title: 用 Hypothes.is 为你喜欢的文字添加评论
tags:
  - JavaScript
  - Tool
categories:
  - Study
cc: true
hljs: true
math: true
comments: true
date: 2015-03-16 02:59:20
---

2015 年 3 月 15 日深夜，我刚从公司回到宿舍。不是加班，是去蹭饭。整整花了一个周末，我才把书的提纲写出来发给编辑。

坐在床边落寞的刷着人人，发现网友[@邵成=undefined](http://www.renren.com/480812352/)分享了一个链接，<https://hypothes.is/>。

点进去一看，发现这个果然是一个高贵冷艳的第三方评论系统，可以对网页内容做圈点，对圈点的内容做点评，界面和功能一样的狂拽酷炫。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

![](https://ws4.sinaimg.cn/large/e724cbefgw1eq6zbr8tnlj20yr0l4gpw.jpg)

Hypothes.is 不同于一般的评论系统。我的博客已经使用了一个叫 “多说” 的第三方评论系统，多说虽然做的不错，但是没有跳出常见的评论系统的桎浩，只能在网页的最下方，正文之后做评论。Hypothes.is 的做法相当于给网页添加了一个图层，用户可以在这个图层上对网页做评论，这样子就把一个平面的网页给立体化起来了。

下面这个是一个介绍的动画。



<div class="video-container">
	<iframe src="https://player.vimeo.com/video/71468316" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href="https://vimeo.com/71468316">Hypothes.is Animated Intro</a> from <a href="https://vimeo.com/user7906166">Hypothes.is</a> on <a href="https://vimeo.com">Vimeo</a>.</p>
</div>

然后是创始人在传教。

<div class="video-container">
	<iframe src="https://player.vimeo.com/video/29633009" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href="https://vimeo.com/29633009">Hypothes.is Intro</a> from <a href="https://vimeo.com/user7906166">Hypothes.is</a> on <a href="https://vimeo.com">Vimeo</a>.</p>
</div>

我们可以轻易地将 Hypothes.is 集成到网站中，只要将下面一段 js 引用添加到页面就好了。

```html
<script async defer src="//hypothes.is/embed.js"></script>
```

Hypothes.is 的效果是显而易见的，网页的右边界出现了一个浮层，点击浮层可以展开评论框。

如果你选中一段文字，文字末尾会弹出一个钢笔小图标，点击小图标就会进入 “引用并评论” 模式。

Hypothes.is 的评论系统做的很不错，支持 Markdown，支持 $\LaTeX{}$ 公式标记，简直不能更赞！

对于那些没有使用 Hypothes.is 的网站，我们也是可以添加评论的！Chrome 用户可以下载 Hypothes.is 的浏览器插件，其他浏览器的用户把下面这段代码添加为书签，打开想要评论的网页之后，点击一下书签执行其中的脚本，就可以尽情的评论了。

```js
javascript:(function(){window.hypothesisConfig=function(){return{showHighlights:true};};var%20d=document,s=d.createElement('script');s.setAttribute('src','https://hypothes.is/app/embed.js');d.body.appendChild(s)})();
```

需要注意的是，用 Hypothes.is “引用并评论” 的地方，会给那段被选中的文字加上 span 标签。对于设计良好的网站，这是没有问题的，要是碰上那些给 span 加了样式的网站，就有可能出现样式崩坏。


最后，祝大家评 (tŭ) 论 (cáo)愉快~

