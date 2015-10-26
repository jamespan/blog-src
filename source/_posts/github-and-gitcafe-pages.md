title: Pages 博客 HTTPS 化尝试与 Universal SSL
tags:
  - Blogging
  - Tool
categories:
  - Study
cc: true
comments: true
date: 2015-04-17 00:18:39
---

最近几天晚上我又在折腾博客，主要是博客镜像部署了一份到 Github 上，然后把海外流量解析到 Github 上，最后是尝试着使用 HTTPS 协议访问部署到 Github 上的博客。

前面两件成功了，使用 HTTPS 协议访问博客的尝试却失败了，或者说有可行方案，我却放弃了。

# 起因 #

如果不是 GitCafe 出了点小问题，我是懒得把博客镜像部署到 Github 上的。

<!-- more -->

这两天我突发奇想，在博客的侧栏做了一个 Contact Me 小组件，然后把微信二维码贴出去了。一开始的时候我直接从微信生成的图像，简单的裁剪了大小，弄成 400 × 400 的正方形，就贴到页面上了。

一开始看还好，多看几眼就会发现，二维码的背景色和页面颜色不一致，有着明显的区别。

![](http://ww1.sinaimg.cn/large/e724cbefgw1er7t6il79mj207x086q3q.jpg)

看了几天之后，我实在受不了了，就用 Gimp 对图片稍作修改，把背景的白色，变成了透明，然后用导出的 png 文件替换了原先的 jpg 文件。部署到 GitCafe 之后，各种刷新发现变更没生效。

直接看 gh-pages 分支的文件，能看出我确实是把修改之后的文件 push 上去了。也就是说，GitCafe 的 Pages 服务出现了严重的延迟。

是时候在 Github 为博客做一个镜像了。

# 镜像 #

在 Github 把代码仓库镜像一份是比较简单的，只需要新建仓库，然后把 gh-pages 分支 push 上去就可以了。

问题在于我该如何使用 Github 上的镜像。

我决定把 blog.james.me 的海外流量解析到 Github 上，这样子一来，国内的访客就会访问到 GitCafe 的镜像，国外的读者就会访问 Github 的镜像，应该是个皆大欢喜的方案。这样子我只要把 VPN 一开，就可以访问到 Github 的镜像，很快就知道是不是 GitCafe 出问题了。

# 解析 #

一开始的时候，我直接用万网域名控制台提供的解析页面做 DNS 解析，把海外线路指向了 jamespan.github.io。

挂上 VPN 之后开始刷页面，过了 2 分钟，看到我的修改生效了，然后用电脑和平板的页面一对比，确认我访问的是 Github 的镜像了。

之前我听一个朋友说它的博客是用 [DNSPod][1] 做的域名解析，我突然想试试。

于是我注册了帐号，绑定了域名。DNSPod 直接读取并导入了当前我的域名的解析配置。但是在我选择线路的时候，惊奇的发现它没法配置海外线路。

看来是 DNSPod 目前还无法提供海外线路的域名解析，我只好把 DNSPod 的解析停止，换回万网。

# 加密 #

之前我在 {% post_link the-blogs-migration %} 中提到，我有把博客流量使用 HTTPS 来加密的打算。

我之前的博客也是同时托管在 Github 和 GitCafe 上的，虽然已经停止更新，但是还能访问。我先试着访问 [https://jamespan.github.io/blog/][3]，果然是以 HTTPS 协议传输的。然后我访问这个博客的最后一篇博客，指向文章页面的链接用的相对路径，所以传输协议还是加密的。只不过文章中显式使用 HTTP 协议加载了一些资源，所以地址栏的小锁头变成了灰色，还多出了黄色的三角形。

既然直接访问 github 提供的链接可以使用 HTTPS 协议，那么通过域名解析来访问 Github Pages，是否也可以使用 HTTPS 呢？我挂上 VPN 开始了尝试。

试着访问 https://blog.jamespan.me/ ，然后出乎意料的失败了，页面显示如下。

```
unknown domain: blog.jamespan.me
```

我对这个意外感到好奇，于是打开审查元素，发现请求的远程地址是 23.235.43.133:443，查 IP 之后发现这是“美国 Fastly 公司 CDN 网络节点”，似乎这个确实是 Github 的 CDN。换成 HTTP 协议之后就可以访问了，远程地址是 23.235.43.133:80。

看起来是这个 CDN 只支持 80 端口，不支持 443 端口。想想也是，很少有免费的 CDN 是能够支持 HTTPS 访问的。我随便搜索了一下，也就发现[又拍云][4]提供了一个[常用 JavaScript 库 CDN 服务][5]，为 jQuery 等 5 个常见的库提供双协议 CDN。

我试着使用 Github 提供的 URL，从 HTTPS 协议访问我的新博客，是可以访问的，远程地址是 199.27.74.133:443，明显不同于使用域名解析时候访问的地址，从 HTTPS 协议访问之前的博客，远程地址也是这个，指向了“美国 加利福尼亚州洛杉矶 Wikia”。

然后我就知道 Github Pages 在处理域名解析和原生地址之间的区别了，私有域名被解析到一个不支持 HTTPS 协议的 CDN 上，而原生地址则解析到支持 HTTPS 的机器。

就在我准备放弃折腾的时候，我找到了一根救命稻草，[Setting up SSL on GitHub Pages][6]。这篇文章里面介绍了一个叫 [CloudFlare][7] 的服务，能够为使用域名解析访问 Github Pages 的网站，提供 HTTPS 支持。

![](https://www.cloudflare.com/images/ssl/url-bar.png)

CloudFlare 提供一种被他们称之为 [Universal SSL][8] 的服务，可以让任意 HTTP 站点支持 HTTPS。它的原理是当访客使用 HTTPS 访问站点的时候，从访客到 CloudFlare 这段是加密的，然后从 CloudFlare 到站点这段是明文的。虽然不是全程加密，但是也能很大程度上解决中间人，如果从 CloudFlare 到站点的信道相对可靠的话。

我开心的注册了 CloudFlare，一路配置到最后，结果发现只有使用 CloudFlare 做DNS 解析才能真正使用它的 Universal SSL 服务。想了想，我还是放弃了。一个原因是我不知道用 CloudFlare 做域名解析会给访问速度带来怎样的影响，另一个是我用了很多的第三方服务，都不能 HTTPS 化，比如多说的评论者头像都是 HTTP 协议加载的资源。

{% blockquote WinterIsComing http://www.solidot.org/story?sid=43694 Mozilla起草HTTP淘汰计划 %}
使用明文传输信息的时代已经结束，新一代的 Web 需要使用加密的 HTTPS
{% endblockquote %}

据说 Mozilla 的安全工程师起草了抛弃 HTTP 全面转向 HTTPS 的[计划][9]，随便看了看，不明觉厉！

期望早日进入 HTTPS 时代！


[1]: https://www.dnspod.cn
[3]: https://jamespan.github.io/blog/
[4]: https://www.upyun.com/
[5]: http://jscdn.upai.com/
[6]: https://blog.keanulee.com/2014/10/11/setting-up-ssl-on-github-pages.html
[7]: https://www.cloudflare.com
[8]: https://blog.cloudflare.com/introducing-universal-ssl/
[9]: https://docs.google.com/document/d/1IGYl_rxnqEvzmdAP9AJQYY2i2Uy_sW-cg9QI9ICe-ww/edit
