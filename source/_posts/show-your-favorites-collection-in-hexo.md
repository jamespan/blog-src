title: 做一个照片流，分享你喜欢的书和电影
tags:
  - Hexo
  - Blogging
categories:
  - Study
hljs: true
thumbnail: //i.imgur.com/aGTXZhIm.jpg
cc: true
comments: true
date: 2016-01-28 02:26:02
---

最近开始有网友注意到我博客中的 [Favorite][1] 页面，并在该页面下留言或者邮件咨询页面的实现或者实施问题。有些是想知道我这个页面是怎么实现的，有些是尝试在自己的博客中加入类似页面后发现图像没有加载的。

随着 Hexo 这个静态博客框架越来越流行，它的用户群中也就加入了越来越多的普通用户。作为一个自诩为 Hexo 资深用户的家伙，看到自己信赖的软件被广泛传播，其实是挺高兴的。

<!-- more --><!-- indicate-the-source -->

之前实现这个 Favorite 页面的时候，没有想到还有人会喜欢，也就没有把它实现为一个可以从 npm 安装的 Hexo 插件，而是仅仅作为我维护的主题的一个脚本插件的存在。

于是我当初的一点点偷懒就给喜欢这个页面形式的普通用户带来了困扰，他们不知道如何从我的博客顺藤摸瓜找到我托管在 Github 的站点源码，也不知道如何排查页面行为不符合预期的问题。这些繁琐的细节，普通用户本应无需感知。

于是我决定对当初草草实现的脚本插件做一点修改，使得它能够方便地被重用、配置，尽量做到开箱即用的程度，而且在用户需要定制的时候尽量不束缚用户的手脚。于是为了平衡重用上的和定制上的便利，我依旧没有把插件发布到 npm。

## 安装 ##

Hexo 的脚本插件是 Hexo 插件的一种特殊形式，仅当插件简单到不需要依赖 Hexo 之外的其他模块时使用。

从 Github 上我博客的源码目录下载脚本，然后放到你本地博客源码目录的 `scripts` 目录或者主题目录下的 `scripts` 目录。

```bash
cd myblog
mkdir -p scripts && cd scripts
wget -c https://raw.githubusercontent.com/JamesPan/blog-src/8ac83216ef4f2904d326ec7cddcf7adba56d9757/themes/icarus/scripts/image-stream.js
```

## 配置 ##

为了实现开箱即用，插件自带了默认配置，不做额外配置，和在站点的 `_config.yml` 中使用如下配置等价：

```json
image_stream:
  jquery: //cdn.bootcss.com/jquery/2.1.0/jquery.min.js
  jquery_lazyload: //cdn.bootcss.com/jquery.lazyload/1.9.1/jquery.lazyload.min.js
  img_placeholder: https://ws4.sinaimg.cn/large/e724cbefgw1etyppy7bgwg2001001017.gif
```

前面两个是插件依赖的模块的 CDN 链接，第三个是实现页面中图片懒加载时用到的占位符，如果有需要可以替换为自己喜欢的链接。

如果博客主题已经默认引入了 jQuery，那么建议在配置中将 `image_stream.jquery` 设置为 false。

```
image_stream:
  jquery: false
```

## 使用 ##

在 Hexo 博客的本地目录创建一个目录作为 favorite 页面目录。

```
myblog
├── _config.yml
├── package.json
├── source
│   └── favorite
│       └── index.md
└── themes
```

然后在 index.md 中使用插件定义的两个模板来生成 favorite 页面。

![](//i.imgur.com/r2EVe1y.png)

## 缘由 ##

为什么我会想到要搞这么个 Favorite 页面呢？其实是受到 <http://blog.fantasy.codes/about.html> 这个页面的启发。

这个博主在 About 页面放了一个照片墙，分享的是读过的书和在读的书，数据来自豆瓣，照片墙也是用豆瓣的 widget 弄出来的。

当时我测试了一下这个页面，发现这个页面用的豆瓣 widget 在响应式上做的很糟糕，于是就打算自己搞一套。

但是刚才我在尝试[豆瓣收藏秀][2]的时候，发现豆瓣秀不仅能展示图书，还能展示电影、音乐、舞台剧等等，而且响应式也做得不错，展示效果也勉强可用虽然我并不满意。如果你在豆瓣积累了大量数据，那么我自然会建议你直接在 Favorite 页面插入豆瓣秀，而不是像我这样自行维护。

自己维护一份 Favorite 数据也是有好处的，毕竟豆瓣收藏秀的数据都在豆瓣那里，万一豆瓣把数据弄丢了，或者由于你懂的的原因把一些书籍或者电影之类的给雪藏了，自己又很想在 Favorite 上分享，找谁说理去？

甚至还能够把一段照片墙嵌入到博文里面，就像这篇文章 「[国庆长假，那些吃喝玩乐，那些遗憾][3]」，这个如果用豆瓣秀估计就没有这么容易搞定了。


[1]: /favorite/
[2]: https://www.douban.com/service/badgemakerjs
[3]: /2015/10/07/the-national-days-of-2015/



