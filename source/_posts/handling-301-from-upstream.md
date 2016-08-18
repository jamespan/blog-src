title: 在 NGINX 中处理来自上游的 301 跳转
tags:
  - NGINX
categories:
  - Study
hljs: true
cc: true
comments: true
thumbnail: //i.imgur.com/bGls4RPl.jpg
date: 2015-11-11 20:58:06
---

自从我借助 NGINX 和两台 ECS 把博客的部署结构变成高可用之后，许多意想不到的事情就陆陆续续出现了。

双十一前的最后一个下午，[不如][1]在微博上给我留言，问我的博客是不是挂了。

不不不，我的博客号称可用性 99.999%，怎么会说挂就挂呢（捂脸逃。于是问不如要了没法访问的 URL。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

链接是下面这个样子的，不如在他介绍「不蒜子」这个访问统计服务的博文中引用了我的博文，作为服务降级的例子。

<http://blog.jamespan.me/2015/05/06/mvn-incremental-compilation>

当时我试着直接访问这个网址，然后就被重定向到了 CNPaas 提供的网址上，空气中顿时布满淡淡的忧伤。

<http://blog-panjiabang.app.cnpaas.io/2015/05/06/mvn-incremental-compilation/>

一看就知道是哪里没弄好被 301 了。从 Chrome 开发者工具可以看出来，我的 NGINX 把 URL 完整地代理到了 CNPaaS，然后就被 CNPaaS 的 NGINX 给 301 到它自己的域名下面去了。

![](//i.imgur.com/gcAaIWa.png)

简直就是天坑。原因很明显，就是 URL 的结尾没有「/」符号（slash），然后触发了 CNPaaS 的重定向规则。之所以会让人感觉挂了，也许是因为它返回了重定向之后，浏览器再次访问的时候，服务有些不稳定吧？

知道了问题所在，于是我就面临着两个选择，一个是绕开，一个是解决。当时正值双十一之前，有点一时半会搞不定的感觉。

先说一下绕开的思路。

既然结尾没有「/」的 URL 会被 upstream 重定向，那么我干脆在入口处先自行重定向到以「/」结尾的 URL 上去，就可以绕开 upstream 的 301 了。

于是我可以在 server 中添加一个重写规则，即 [rewrite][2] 指令，先下手为强地进行重定向：

```NGINX
server {
    listen 80;
    server_name blog.jamespan.me;
    rewrite ^([^.]*[^/])$ $1/ permanent;
    location / {...}
}
```

这种绕开的方式简单明了，一行配置搞定，但是有点像打补丁，今天把这个坑堵上了，没准明天还有别的重定向坑。

另外一种解决方案是使用 [proxy_redirect][3]，修改返回报文中的 Location 和 Refresh 字段。

```NGINX
server {
    listen 4002;
    port_in_redirect off;
    proxy_redirect http://$proxy_host/ http://$host/;
    location / {
        proxy_pass http://blog-panjiabang.app.cnpaas.io/;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

这种方式处理来自 upstream 的 301 比较彻底，直接从源头把各种 upstream 的域名转换成自己的域名。

最后在 [SSH::Batch][4] 的帮助下，我在很短的时间内搞定了这个问题。或许以后用 SSH::Batch 的机会不多了，因为我已经把服务器运维工具全面转向 [Ansible][5]！

最近在开始认真学习 NGINX，先跟着 agentzh 菊苣的教程看看。之前一直是把 NGINX 配置起来用用，需要加缓存就 Google 一下，这个那个问题出现了就 Google 一下。这种面向 Google 的编程确实能帮助我解决问题，但是没法帮助我成为专家。

关于 URL 的结尾是否需要「/」，有一篇文章讲的不错，「[Why do URLs often end with a slash?][6]」。当一个 URL 以「/」结尾时，就明确告诉服务器，去访问一个目录，否则服务器会先去试图访问文件，找不到文件就通过重定向去访问目录。由于这个策略的存在，访问一个文件的时候，如果 URL 结尾带了「/」，就会因为找不到目录直接 404 了。

所以说，贴链接的时候，尽可能明确地给出要访问的资源是目录还是文件，是一种好习惯~

[1]: http://ibruce.info
[2]: http://NGINX.org/en/docs/http/ngx_http_rewrite_module.html#rewrite
[3]: http://NGINX.org/en/docs/http/ngx_http_proxy_module.html#proxy_redirect
[4]: /2015/11/07/ops-with-ssh-batch/
[5]: http://www.ansible.com/
[6]: http://webdesign.about.com/od/beginningtutorials/f/why-urls-end-in-slash.htm
