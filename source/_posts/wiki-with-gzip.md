title: 压缩在手，Wiki 不愁
tags:
  - NGINX
categories:
  - Study
cc: true
comments: true
date: 2015-07-29 01:56:25
---


我在之前的一片文章《[个人 Wiki 之殇][1]》中，提到我我正在使用的一个单文件 Wiki 系统，TiddlyWiki。

当时出于对未来 Wiki 页面文件体积的担忧，我感觉它的加载时间会逐渐发展到难以接受的程度。不久之前，我的 Wiki 页面文件就已经有 2.3MB 了，最近不知道是因为 TiddlyWiki 升级到 5.1.9 还是我安装了一个用于渲染 LaTeX 数学公式的插件，体积更是瞬间膨胀到了 2.7MB。

<!-- more -->

之前我总是觉得用手机访问一次 Wiki 就要消耗 2.3M 的流量，代价有点高昂但还可以接受。如今访问一次就得 2.7M，四舍五入将近 100M 啊，完全接受不能。

我习惯用 Opera 来访问和调试我自己的这几个小网站，如今的 Opera 也用了 Chrome 内核，开发者工具十分顺手。我开着开发者工具，在 Opera 中访问部署到 Gitcafe 的 Wiki，惊奇地发现整个页面加载过程只消耗了 664KB 的流量。（当我开始写这篇文字，打算截图的时候，页面的流量消耗就变成 763KB 了，与此相伴的还有 Gitcafe 的 NGINX 版本从 1.6.3 变成了 1.8.0，当时的现场已经找不回来了）

![Opera 开发者工具](http://ww2.sinaimg.cn/large/e724cbefgw1euizo5rnp2j20ht07lwfp.jpg)

这是什么黑科技！说好的 2.7MB 呢？

我于是把本地的 node 服务启动起来，发现访问本地的页面果然是消耗了 2.7MB 的流量的。

这是为什么呢？我陷入了沉思。突然，四个英文字母在脑海中浮现：

**G Z I P**

会不会是 Pages 的服务端开启了 gzip 压缩，而我在本地启动的 node 服务没有压缩，所以有这么明显的流量差别？之前我不知道在哪里看关于 gzip 的文章，具体细节记不得了。

往 Response Header 一看，gzip 字样赫然在目。

为了弄清楚这个压缩是个啥情况，我找了 NGINX 关于压缩模块的文档[^1]，学习一个。

[^1]: [Module ngx_http_gzip_module][2]

很明显很划算的资源置换，压缩页面损耗的 CPU 资源比起节省的带宽和流量费，还有提高的网速，简直可以忽略不计了。记得之前支持我们的 DBA 大大看我们应用的数据库 CPU 使用率太低，还特意开启了压缩，用 CPU 资源换内存资源，让更多的数据页可以缓存到内存中。

有了压缩之后，我的个人 Wiki 应该很长一段时间之内都不用太关心页面太大加载太久的问题了，虽然现在就已经没法做到秒开，但是至少不会好几秒都开不出来。


[1]: http://blog.jamespan.me/2015/06/30/personal-wiki-sucks/
[2]: http://NGINX.org/en/docs/http/ngx_http_gzip_module.html
