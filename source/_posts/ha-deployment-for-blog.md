title: 静态博客高可用部署实践
tags:
  - High Availability
  - Blogging
  - Nginx
categories:
  - Study
hljs: true
cc: true
thumbnail: 'http://ww1.sinaimg.cn/small/e724cbefgw1exdvnnztdgj20rs0rs0u5.jpg'
comments: true
date: 2015-10-26 01:08:49
---


前几天我的博客挂了，6 个多小时不可用。准确来说，是部署在 Gitcafe Pages 上的我的博客不可用，影响了墙内用户的访问。与此同时，我部署在 Github Pages 上的博客依然坚挺，墙外用户访问正常。

独立博客是博主分享想法、和读者交流的根据地，技术博客则是一个程序员的名片。都是我维护的系统，为什么我的博客不能和生产系统拥有差不多的可用性保障？

<!-- more -->

可惜那时是凌晨，我还在公司加班搞双 11 的预案演习，不方便修改域名解析。不幸的是，五点多演习结束，托管在 Gitcafe Pages 的博客依然没有恢复，而我也因为通宵失去了抢救博客的精力。于是博客就这样挂了 6 个小时，加上之前断断续续的不可用的时间，可用性已然跌破 99.9%。

我决定为博客实施高可用的部署。必须实施高可用部署。

## 低可用の冗余部署 ##

![博客部署结构 v1.0.0](http://ww1.sinaimg.cn/large/e724cbefgw1exdnntkml4j2079044jrd.jpg)

改造之前的博客部署结构如上图。同样一份代码在 Github 和 Gitcafe 做冗余部署，考虑到访问速度以及一些不可抗力，分流的工作交给了 DNS，海外线路 CNAME 到 github.io，默认线路 CNAME 到 gitcafe.io，这样子在正常的情况下，全球的访客都能获得比较理想的访问速度。

这种部署方式有点像磁盘阵列里头的 RAID 0，提高了访问速度，却没有冗余，一旦某个后端不可用，整个服务也将不可用，或者仅部分可用。现实中，绝大部分用静态博客的博主，只使用了这种部署结构，甚至是可用性更差的单点部署，只部署在 Github 或者 Gitcafe 上。

其实我这里说单点部署的可用性差是以偏概全了。如果不是因为一些不可抗力，单独部署一个 Github Pages 就已经很可靠了，Gitcafe 在可用性上距离 Github 还是有着一定的差距，昨天似乎还遭遇了一波 DDos，连主站都直接不可用了好长一段时间。

## 伪高可用の反向代理 ##

所谓高可用，说一千道一万，逃不过冗余二字。数据库作为最后的单点，要有主备；应用服务器要能水平扩容，部署到不同的机器、机架和机房……如此这般，即使一个物理机宕机，一个机架损坏，甚至一个机房整体沦陷，应用也还是可用的。资金更加雄厚的，就做同城冷备，异地冷备，所谓两地三中心；技术和资金同样雄厚的，就像蚂蚁金服一般搞异地多活，多地机房同时提供服务。比异地多活更加高明的高可用手段，也许是 Facebook、Google 等网站的标配吧。

高可用的基础——冗余，我的博客已经具备了，就是 Gitcafe 和 Github 的冗余部署。不过由于 Gitcafe 直到今天下午还没从 DDos 中回过神来，Pages 服务各种乱七八糟的，我只好和它说拜拜，转而使用 [CNPaas][1] 了。CNPaas 的试用版可以免费部署 2 个应用，虽然比起 Pages 服务少了好多，但是也能勉强用着。

万事俱备，只欠东风。现在我手上有两个可用性未知的博客，如何把他们组装成一个高可用的博客？反向代理就是这个从低向高进化中至关重要的一个基础设施。

Nginx 是目前业界最常用的反向代理服务器，我那台位于香港的 ECS 上一直部署着，代理着我部署的 wiki 和 wekan 两个应用。这一次，我将用它来为我两个博客服务做反向代理。

![博客部署结构 v2.0.0](http://ww3.sinaimg.cn/large/e724cbefgw1exdqgziee9j207306mq2z.jpg)

对 Nginx 还不是很熟，一开始的是想直接把 Github Pages 和 CNPaas 给的默认 URL 作为 Upstream，结果就妥妥的被配置检查拦掉了。于是我只好退而求其次，先在本地起一个服务器，分别代理 Github Pages 和 CNPaas，再把这两个代理作为博客的 Upstream。

```conf
server {
    listen 4000;
    port_in_redirect off;
    location / {
        proxy_pass http://jamespan.github.io/blog.jamespan.me/;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

server {
    listen 4002;
    port_in_redirect off;
    location / {
        proxy_pass http://blog-panjiabang.app.cnpaas.io/;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

upstream backend_blog_jamespan_me {
    server 127.0.0.1:4000;
    server 127.0.0.1:4002;
}

server {
    listen 80;
    server_name blog.jamespan.me;
    location / {
        proxy_next_upstream http_502 http_504 http_404 error timeout invalid_header;
        proxy_pass http://backend_blog_jamespan_me;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
    }
}
```

Nginx 的配置是摸着石头过河，在 Google 的帮助下搞出来的，个别配置真真是传说中的「My Code Works I Don't Know Why」，特别是 `proxy_set_header` 系列。

![](http://ww1.sinaimg.cn/large/e724cbefgw1exdswep9d9j20hd0d90tz.jpg)

配置中的那些 `proxy_set_header` 据说是用来传递访客的真实 IP 以及代理链路上各个代理服务器的 IP，具体是怎么回事还没验证，但愿没配错，配错了我暂时也不知道。

为了让 Nginx 在 301 之后给出的 Location 中不带有端口，我在每个 Upstream 的配置里面加了 `port_in_redirect off`。

实现高可用最关键的配置其实是 `proxy_next_upstream`，这行配置实现了故障转移。当某个 Upstream 出现 502、504、404、超时等等一系列不可用的状态时，Nginx 会去尝试请求另外一个 Upstream。这样一来，只要不是 Github Pages 和 CNPaas 同时不可用，博客整体都会处于可用的状态。

博客的高可用部署改造完成了吗？还没有！这样的部署结构还不是高可用，还存在单点。后端的单点已经通过 Nginx 做反向代理和故障转移解决了，现在是运行 Nginx 的这台作为 VIP（Virtual IP）的服务器成为了单点。

## 真高可用の买买买 ##

VIP 成了单点，那就只好再部署一台 VIP 了。昨天下午我买了一台位于新加坡的 ECS，时长一个月，还没来得及收拾，因此我的博客还暂时处于伪高可用的状态，能够解决后端不可用的问题，解决不了 VIP 不可用的问题。

收拾好 ECS 新加坡节点后，在上面部署 Nginx，并配置一样的反向代理。然后在 DNS 中为 blog.jamespan.me 配置两条 A 记录并负载均衡，就得到如下的部署结构。


![博客部署结构 v2.1.0](http://ww2.sinaimg.cn/large/e724cbefgw1exdum2eb98j207306mdfz.jpg)

啊哈，我的博客部署在不同的国家和地区，传说中的异地多活😂！

![我们的朋友遍天下](http://ww4.sinaimg.cn/large/e724cbefgw1exdufv8uxzj20up08sn0c.jpg)

目前还没部署新加坡节点，所以最后的双 VIP 部署是 YY 的。

[1]: http://www.cnpaas.io
