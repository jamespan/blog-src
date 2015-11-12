title: 在 Nginx 中处理来自上游的 301 跳转
tags:
  - Nginx
categories:
  - Study
hljs: true
cc: false
comments: false
date: 2015-11-11 20:58:06
---

自从我借助 Nginx 和两台 ECS 把博客的部署结构变成高可用之后，许多意想不到的事情就陆陆续续出现了。

双十一前的最后一个下午，[不如][1]在微博上给我留言，问我的博客是不是挂了。

不不不，我的博客号称可用性 99.999%，怎么会说挂就挂呢（捂脸逃。于是问不如要了没法访问的 URL。

<!-- more -->

链接是下面这个样子的，不如在他介绍「不蒜子」这个访问统计服务的博文中引用了我的博文，作为服务降级的例子。

<http://blog.jamespan.me/2015/05/06/mvn-incremental-compilation>

当时我试着直接访问这个网址，然后就被重定向到了 CNPaas 提供的网址上，空气中顿时布满淡淡的忧伤。

<http://blog-panjiabang.app.cnpaas.io/2015/05/06/mvn-incremental-compilation/>

一看就知道是哪里没弄好被 301 了。从 Chrome 开发者工具可以看出来，我的 Nginx 把 URL 完整地代理到了 CNPaaS，然后就被 CNPaaS 的 Nginx 给 301 到它自己的域名下面去了。

![](//i.imgur.com/gcAaIWa.png)

简直就是天坑。原因很明显，就是 URL 的结尾没有「/」符号，然后触发了 CNPaaS 的重定向规则。

知道了问题所在，于是我就面临着两个选择，一个是绕开，一个是解决。当时正值双十一之前，有点一时半会搞不定的感觉。

先说一下绕开的思路。

既然结尾没有「/」的 URL 会被 upstream 重定向，那么我干脆在入口处先自行重定向到以「/」结尾的 URL 上去，就可以绕开 upstream 的 301 了。

于是我可以在 server 中添加一个重写规则，即 [rewrite][2] 指令，先下手为强地进行重定向：

```nginx
server {
    listen 80;
    server_name blog.jamespan.me;
    rewrite ^([^.]*[^/])$ $1/ permanent;
    location / {...}
}
```

这种绕开的方式简单明了，一行配置搞定，但是有点像打补丁，今天把这个坑堵上了，没准明天还有别的重定向坑。

另外一种解决方案是使用 [proxy_redirect][3]，修改返回报文中的 Location 和 Refresh 字段。



[1]: http://ibruce.info
[2]: http://nginx.org/en/docs/http/ngx_http_rewrite_module.html#rewrite
[3]: http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_redirect

