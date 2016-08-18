title: 使用 JavaScript 实现 iframe 判断和页面重定向
tags:
  - JavaScript
categories:
  - Study
date: 2015-01-12 00:23:13

cc: true
hljs: true
comments: true
---

# 背景

今天我突然发现 Google 已经能够索引[我的博客][1]了，外在特征就是我能用 Google 对博客进行[站内检索][4]。

我随便搜索了一下，发现 Google 索引的 [Timeline][2] 的内容，全都指向了作为 iframe 嵌入的 /blog/timeline/timeline.html 页面，而不是[我期望的页面][2]。这其实也不是 Google 的错，因为 iframe 中的内容，本来就是不会被爬虫认为是当前页面的内容。

从 Google 的搜索结果直接点进 Timeline，就只能看到一个纯净的时间轴，看起来这个页面跟我的博客没有半毛钱关系。那怎么才能让 Google 的搜索结果指向博客页面呢？

<!-- more --><!-- indicate-the-source -->

{% recruit %}

# 方案

我首先想到了用 JavaScript 来控制页面跳转，这个几乎是最经济的实现方式了。

方案选定之后就是定位问题，我要解决的问题有 2 个：
1. 如何判断当前页面是从 iframe 访问的，还是直接访问的？
2. 如何控制页面跳转？

我在 Stack Overflow 找到了两个问题的答案，见[参考文献](#参考文献)。以下是解决问题的代码。

```js
//判断当前页面是否直接显示在浏览器中
if (self == top) {
  //跳转
  window.location.replace("/blog/timeline/");
  // window.location.href='/blog/timeline/';
}
```

这里要指出的是，JavaScript 跳转页面有很多种实现方式，我这里选择的是最简单的实现，不依赖于 jQuery。

其中 `window.location.replace` 跳转时，浏览器历史不记录跳转之前的那一条 URL，而 `window.location.href` 会把跳转前后的 URL 都记录在浏览器中。

如果想要模拟点击链接的跳转效果，使用 `window.location.href`，如果想要模拟 HTTP 跳转，使用 `window.location.replace`。

# 参考文献
1. [to check parent window is iframe or not](http://stackoverflow.com/questions/4594492/to-check-parent-window-is-iframe-or-not)
1. [How can I make a redirect page?](http://stackoverflow.com/questions/503093/how-can-i-make-a-redirect-page)

[1]: http://panjiabang.gitcafe.io/blog/
[2]: http://panjiabang.gitcafe.io/blog/timeline
[4]: https://www.google.com.hk/search?q=site:panjiabang.gitcafe.io/blog
