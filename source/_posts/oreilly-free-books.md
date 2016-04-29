title: "分享几本 O'Reilly 出品的免费电子书"
tags:
  - Reading
categories:
  - Study
hljs: true
thumbnail: 'https://i.imgur.com/NrX0gRz.jpg'
cc: true
comments: true
date: 2016-04-30 02:40:11
---


有一些书，如果你不是行内人士，那么可能你一辈子都不会看。有一些出版社，就是专门做这种书，比如国内的机工华章，比如国外的 O'Reilly，都是专注计算机和软件行业二十年的好出版社。

这两家出版社的书，都是颇有特色个性鲜明。华章的图书，我在大学期间读了很多，以计算机科学领域的基础和经典居多，这套书在民间诨号「黑皮书」，官方的称谓好像是「计算机科学丛书」。O'Reilly 的图书则诨号「动物书」，因为图书的封面是各种各样的动物，有些动物是技术的吉祥物，比如 Python 书籍的封面是各种各样的蟒蛇，Golang 书籍的封面则是地鼠。至于 Perl，似乎还是 O'Reilly 先在 Programming Perl 这本书的封面上画了骆驼，然后骆驼才成了 Perl 的吉祥物。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

当然，O'Reilly 出的最接地气的一本书，当属下面这本（误

![](https://i.imgur.com/aZEascJl.jpg)

回到正题。前几天我终于用排队打饭、吃饭、上厕所等等碎片时间，看完了大半年之前就保存在手机中的一本电子书，*[Software Architecture Patterns][1]*。

这本书内容挺好，介绍了几种常见的架构模式，比如泥球、事件驱动、插件化，还有时下火热的微服务、云架构等等，详细解释各种架构的设计，为了解决什么问题，做了哪些折衷，有哪些缺陷，还定性地描述可部署性、可测试性、敏捷度等等关键指标。

之前发现这本电子书纯属偶然，最近我养成了个习惯，不管是看过的书还是电影还是动漫，只要是觉得不错的，都在 [Favorite][2] 记录下来。这些文艺作品大多数都能在豆瓣找到相关页面，而这次我看的是电子书，豆瓣里也没人分享，我也懒得去提交申请。

于是我顺藤摸瓜找到 O'Reilly 官网上关于这本书的页面，然后再次顺藤摸瓜找到 O'Reilly 分享的其他免费编程类电子书，[Free Programming Reports][3]。页面下方还有其他主题的免费电子书，商业的，数据的，物联网的……简直就像是一个吃货走进了摆满各种各样 delicious free food 的房间，幸福来得太突然。

![](https://i.imgur.com/wFEdZ5a.jpg)

看到美好的东西，总是忍不住占为己有，看到有用的互联网资源，总是忍不住下载到本地，这叫做落袋为安。

可是，那么多本电子书，难道要我一个一个点开下载吗？

子曰，举一隅，不以三隅反，则不复也。如果点开一个两个下载之后还没找到捷径，那么真的没必要看这些书了。

这里就把下载 O'Reilly 免费电子书的捷径随便分享一下，希望读者看到的时候，这个捷径依旧有效。

万一失效了，请留言告知后来人，别留言请求我跟进修改就好，哈哈。

```js
$.map($('body > article:nth-child(4) > div > section > div > a'), function(e){return e.href.replace(/free/, "free/files").replace(/csp.*/, "pdf")})
```

在页面上上启动检查元素，然后在终端中执行上面这个表达式，我们得到的就是当前页面展示的图书的下载地址了。有了下载地址，无论是扔给 wget 一个一个慢慢下载，还是扔给 axel 多线程并发下载，都是很轻松随意的嘛~

![](https://i.imgur.com/txLqgnx.png)

祝阅读愉快！


[1]: http://www.oreilly.com/programming/free/software-architecture-patterns.csp
[2]: http://blog.jamespan.me/favorite/
[3]: http://www.oreilly.com/programming/free/


