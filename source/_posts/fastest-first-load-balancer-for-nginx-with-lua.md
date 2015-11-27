title: NGINX 负载均衡策略之「快者优先」的 Lua 实现
tags:
  - NGINX
  - Lua
  - Openresty
categories:
  - Study
hljs: [dockerfile]
thumbnail: //i.imgur.com/sLLhSQf.png
cc: true
comments: true
date: 2015-11-27 17:54:30
---


最近我在 NGINX 上实现了一个负载均衡策略，优先使用「响应时间最短」的后端服务。说是 Nginx 其实并不太准确，因为我实际上是使用了 Openresty 中打包进 NGINX 的许多模块才能实现的，所以说是基于 Openresty 实现更为准确。

「快者优先」的 Lua 实现作为我的 Nginx 配置的一部分，可以从 [dynamic-upstream-weight.lua][4] 获得。在 Lua 之外，我们还需要两个全局的 Key-Value 缓存作为调整负载策略的数据基础，配置方式详见我的 NGINX 站点配置 [blog.jamespan.me][5]。

<!-- more -->

为了实现这个负载均衡特性，我对 [lua-upstream-nginx-module][1] 做了修改，增加了修改 upstream server 的权重的 Lua API，详见 [JamesPan/lua-upstream-nginx-module][2] 的 commit [6b40d40a4][3]。

「快者优先」负载均衡策略其实是一种「负载不均衡」策略，投射到现实中，就仿佛一个人表现得越能干，最后他需要干的活就越多，直到某一天不堪重负，这就是传说中的「能者多劳」。我正在尝试用 C 写一个 NGINX 模块来实现这个「快者优先」策略，出于上述的脑洞，我决定把这种策略命名为 labor。当我完成这个模块之后，我们就可以像下面这样轻松地使用它，而不必对站点配置造成侵入性的修改了~

```nginx
upstream backend {
    labor;
    server back1.example.com;
    server back2.example.com;
}
```

## 需求背景 ##

是的，我又在折腾博客了。

我手动把博客的 Docker 镜像部署到了我的两台 ECS 上，然后把这两个新部署的容器纳入博客的后端列表，于是我就发现一个由于网络延迟带来的有趣问题。

![博客部署结构](//i.imgur.com/HwFCpHd.jpg)

不用想都知道，Nginx 把流量反代到跟自己在同一台 ECS 的后端，能实现最短的响应时间，DOMContentLoaded 耗时在 500ms 以下。如果把流量反代到 Github 或者 DaoCloud，也能勉强实现秒开，DOMContentLoaded 在 800ms 到 1200ms 之间。如果反代到了另一台 ECS，那就悲剧了，DOMContentLoaded 差不多 3000ms。

比较朴素的解决方案其实蛮简单的，给位于不同主机的 Nginx 写不同的配置，把其他主机的后端设置为 backup，把当前主机的后端权重加大即可。但是，我的 Nginx 是用 Docker 部署的，而且把配置打包进了镜像，如果想要不同的主机使用不同的配置，要么把配置单独挂载，要么搞两个镜像。

如果把配置单独挂载，使用 Docker 去部署 Nginx 就失去了意义，和直接部署基本没啥两样，还把重新加载配置弄得麻烦了。如果搞两个镜像，那是更不可接受的，基本一样的配置维护两份，想想都醉了。有没有高端解决方案，让我能用一份配置解决问题？

解决方案应该就在负载均衡策略上。之前我用的是默认的轮询策略 round-robin，更早的时候还用过 ip_hash。从官方文档「[NGINX Load Balancing - HTTP and TCP Load Balancer][6]」中，我发现了一个叫 least_time 的策略，基本上就是我想要的。然而它作为一个「高级负载均衡算法」，是商业版本的 NGINX Plus 专供，并不包含在开源版本的 NGINX 中[^1]。噢，万恶的资本主义。

[^1]: [TCP Load Balancing with NGINX 1.9.0 and NGINX Plus R6][7]

那么问题来了，既然这个「快者优先」的策略我这么想要，既然我不愿意花钱买 NGINX Plus，我能否自己实现一个？

当然能啦，我这么厉害的（捂脸逃

之前在北京的 Velocity 上听过王院生关于 Openresty 的分享，当时我就觉得这是一个了不起的项目。正好这次我就拿来用了。

## 设计 ##

做为产品狗的我，对作为程序猿的我说，「实现一个负载均衡策略，优先使用最快的后端」。

作为程序猿的我，对作为产品狗的我说，「滚」。


### 第一定律 ###

怎么设计一个「快者优先」的负载均衡策略呢？首先定义什么叫「快」。NGINX 自带一个全局变量 [`upstream_response_time`][8]，记录了 NGINX 完整接收某个或者某几个后端的响应的耗时。虽然没那么严谨，我认为 `upstream_response_time` 相对较小的那个后端相对较快。

其次定义什么叫「优先」。NGINX 默认的 round-robin 策略中，我们是可以给 server 指定 [weight][9] 的。这次比较严谨，我认为 server 的 weight 值越大则越优先。

我可以在 round-robin 的基础上，实现「快者优先」。

于是我们就得到了「快者优先第一定律」：对于 upstream 中的 server，响应时间越大则权重越小。

### 第二定律 ###

当我们把大部分的流量引导到曾经响应最快的那个后端之后，这个后端的负载势必要比其他的后端更高，甚至可能失败请求。还好 NGINX 能够感知后端失败并故障转移。假如 NGINX 已经为某个后端标记为失败，「快者优先」却还因为它曾经牛逼过，而把流量优先引导过去，似乎不太合适。

但是一旦某个后端不可用，就直接标记为下线也不合适，如果过一会它自动恢复了，还得重新把它标记上线，挺麻烦的。把不可用的后端的权重降到一个比较低的水平，看起来应该是个不错的选择，毕竟偶尔还可以去尝试请求一下，万一恢复了呢？

于是我们就得到了「快者优先第二定律」：对于不可用的后端，自动降低权重至比较小的数值，比如 1。

### 第三定律 ###

当我们为后端服务器算出了一套权重规则之后，是否需要更新它？需要。

我们应该在什么时机去更新这套权重规则？应该更新哪些内容？考虑到更新权重是一个比较重的操作（我瞎说的），每次请求都去更新权重似乎不太合适。我们需要一个或多个更新触发条件，比如当某个后端的响应时间的波动超出某个阈值，比如当前响应时间超出当前权重规则被设定时候的最大耗时，或者小于最小耗时之类的。

通过这样一套触发条件，我们就能使得在后端响应时间不出现剧烈变化的时候，权重规则保持稳定，出现剧烈变化的时候，能够第一时间调节权重，一定程度上保护后端服务器。

于是我们就得到了「快者优先第三定律」：在合适的时机更新权重规则，在保护后端服务器的同时尽量保持权重规则稳定。

### 第四定律 ###

之前学习机器学习的时候，有一个概念叫做「局部最优解」，其实就是求解的时候陷入了极值点无法自拔，找不到就在不远处的最值点。

在寻找最快的后端时，也需要注意不要陷入「局部最优解」，至少要有一种策略，能够找到后端服务器中响应最快的那个。找到最快的服务器需要的平均请求次数，就成了衡量负载均衡策略优劣的指标之一。

于是我们就得到了「快者优先第四定律」：确保最终能够发现响应最快的服务器。

## 实现 ##

> Talk is cheap, show me the code.

反正一开始我就已经 show code 了，这里就光说不练。

一开始的时候，「快者优先」策略还只是一个盘旋在我脑海的想法。为了在最短的时间内把想法实现，做出原型，用 C 直接写 NGINX 模块是不靠谱的，至少对我来说难度太大。感谢 agentzh 大大和 Openresty 社区的出色工作，我们可以用 Lua 对 NGINX 编程。

虽然知道可以用 Lua 之后难度降低了许多，但是我还是没用过 Lua。

> 「用一个完全没用过的语言写一个能用的软件是怎样的体验？」
>
> 「仿佛回到了大学一年级那刚开始学编程的年月。我想起那天夕阳下的奔跑，那是我逝去的青春。」

一番探索之后发现了 Openresty 中的 lua-upstream-nginx-module 提供了一些操作 upstream 配置的 API，以读为主，唯一的写操作是把某个后端下线。这可完全不够用。于是我只好自己动手去修改代码了，依葫芦画瓢增加了几个 API 去支持修改 server 的 `weight`，`effective_weight`，和 `current_weight` 这三个属性。

之后的开发和调试就是摸索着用 Lua 在 NGINX 里面实现上面的那「快者优先四大定律」，以及在 `log_by_lua` 和 `log_by_lua_block` 的各种小问题中挣扎，最后发现还是直接写 Lua 文件，再用 `log_by_lua_file` 来调用最靠谱。

## 一些有趣的东西 ##

最后，分享一下我用来打包 Openresty 的 [Dockerfile][10]，这里面有一些有趣的东西。

一上来我就先安装好几个软件。前面三个都是 Openresty 的运行依赖，唯独 perl 是编译依赖。不要问我为什么，也许是 agentzh 大大太擅长用 perl 的缘故吧~

```bash
apk add openssl pcre libgcc perl
```

之后就是下载 Openresty 的源码并解压，然后下载被我修改过的模块去替换原有的模块。紧接着就是一大串编译前的 configure。

其实当我们不知道如何编译一个软件包的时候，可以先去发行版的软件仓库里面看看这个软件包的构建脚本，比网上分享的各种「编译安装 XXX」要靠谱的多。比如 Alpine Linux 的 [NGINX APKBUILD][11]。

另外一个有趣的点，是关于 Docker 的日志收集机制。我们平时写的应用什么之类的，基本上都是直接把日志打到指定文件中，NGINX 也不例外，有相对固定的日志目录和日志文件。但是 Docker 只采集输出到标准输出和标准错误的信息，这就比较蛋疼了，也因此出现了一些适配方案。

第一种比较挫的是修改启动命令为一个自定义的脚本，用 tail 在后台去跟踪日志并输出到标准输出，最后再启动应用。第二种换汤不换药但是稍微不那么挫，有人用 Golang 写了个叫 [dockerize][12] 的程序，效果类似于自定义脚本，但是总算可以直接写在 Dockerfile 的 CMD 里面而不用引入额外的脚本了。

后来我不知道从哪个 Dockerfile 里面看到一种让人惊艳的写法，直接把标准输出软链指向日志文件，这样 NGINX 的日志就直接输出到标准输出了，还不用担心运行久了之后大量日志堆积在容器里面之类的问题。

```
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
```

一开始需要编译 Openresty 的时候，我先尝试在本地构建，结果卡在下载编译器以及编译依赖了，死活下载不下来，真是捉急。于是我灵机一动，直接把准备编译环境那部分的 Dockerfile 提交到 Github，然后灵雀云就开始自动构建。构建整个镜像花了十几分钟，构建完成之后我直接下载镜像，就有了一个可用的编译环境了，我 TM 太机智了！

[1]: https://github.com/openresty/lua-upstream-nginx-module
[2]: https://github.com/JamesPan/lua-upstream-nginx-module
[3]: https://github.com/JamesPan/lua-upstream-nginx-module/commit/6b40d40a42aa6a8e4214a8c247b7d32ce9d37895
[4]: https://github.com/JamesPan/orz-ops/blob/master/nginx/lua/dynamic-upstream-weight.lua
[5]: https://github.com/JamesPan/orz-ops/blob/3f8f1e15fa40b33dea596554eb26f41147fe5f53/nginx/sites/blog.jamespan.me#L31:L44
[6]: https://www.nginx.com/resources/admin-guide/load-balancer/
[7]: https://www.nginx.com/blog/tcp-load-balancing-with-nginx-1-9-0-and-nginx-plus-r6/
[8]: http://nginx.org/en/docs/http/ngx_http_upstream_module.html#var_upstream_response_time
[9]: https://www.nginx.com/resources/admin-guide/load-balancer/#weight
[10]: https://github.com/JamesPan/orz-ops/blob/edf1cdb7bd2805c6333c492d05cb233b16a71bf9/nginx/Dockerfile.resty
[11]: http://git.alpinelinux.org/cgit/aports/tree/main/nginx/APKBUILD?id=a06bd137ccd148f57e09f5ec9afcff356bac3b7c
[12]: https://github.com/jwilder/dockerize
