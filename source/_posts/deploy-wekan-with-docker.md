title: 使用 Docker Compose 部署 Wekan
tags:
  - Docker
  - Dashboard
  - NGINX
categories:
  - Study
hljs: true
cc: true
comments: true
thumbnail: 'http://ww4.sinaimg.cn/large/e724cbefgw1ewh0jn35xrj20d603tdgf.jpg'
date: 2015-09-29 21:44:23
---


最近工作中的各种事情杂乱繁多，之前用 Gitlab issue 来记录待办事项和处理过程的方式显得比较繁重了，我开始尝试简单地使用『看板』来跟踪我手头上的事情。集团内部有一个和内部系统高度集成的项目管理平台，看板只是其中的一个小功能。

试用一段时间之后感觉不错，碰巧我看到一篇文章，《[Trello 的 5 个开源替代品][1]》，于是决定自己部署一套看板。

至于为什么要自己部署一套看板，而不直接使用 Trello，也许是因为我是「不折腾会死星人」，然后又恰好买了 3 年的阿里云 ECS，不想让它闲置吧~

<!-- more --><!-- indicate-the-source -->

一开始的时候我被 [Taiga][3] 那极高的颜值吸引，然而当我看到 Taiga 那拆分得很细的项目结构之后，不禁打起了退堂鼓，毕竟我只是想要部署一个还不错的看板应用，不想要那么麻烦。最终目标锁定 [Wekan][4]，前身是 LibreBoard。


Wekan 是 Trello 的开源克隆，使用 mongodb 作为持久化存储，提供 Docker 镜像 [mquandalle/wekan][2]。

Wekan 的 [Dockerfile][5] 中给出了用 Docker 部署 Wekan 的方法。

```bash
docker run -d --name wekan-db mongo
docker run -d --link "wekan-db:db" -e "MONGO_URL=mongodb://db" \
  -e "ROOT_URL=http://example.com" -p 8080:80 mquandalle/wekan
```

先部署 mongodb，再部署 Wekan，然后设置一些环境变量、端口映射之类的东西。但是如果我们简单的按照这两条命令部署，只能作为一个 demo 来使用，一旦容器被结束了，Wekan 持久化到 mongodb 中的数据也就跟着丢失了。要想把数据真正的持久化下来，需要给运行 mongodb 的容器挂载一个数据卷，把数据写到容器外面。

```bash
docker run -d -v /path-to-save-mongo-data:/data/db \
  --name wekan-db mongo
docker run -d --link "wekan-db:db" -e "MONGO_URL=mongodb://db" \
  -e "ROOT_URL=http://example.com" -p 8080:80 mquandalle/wekan
```

其实我更喜欢的方式是使用 [docker compose][8] 来把容器以及各种依赖编排成服务，比如我实际部署的时候写了这么一个编排文件[^2]，

[^2]: [docker-compose.yml reference][7]

```json
wekandb:
  image: mongo
  volumes:
    - /path-to-save-mongo-data:/data/db

wekan:
  image: mquandalle/wekan
  links:
    - wekandb:db
  ports:
    - 8080:80
  environment:
    - MONGO_URL=mongodb://db
    - ROOT_URL=http://example.com
```

然后就可以简单地使用 `docker-compose up` 在前台启动应用，测试可用之后使用 `docker-compose start` 在后台部署容器。

总体来说 Wekan 是一个不错的看板应用，部署之后我立刻召唤小伙伴一起使用。但是短短一会的时间，我就发现了一些问题，不知道会不会在新版本中修复或者添加新特性。

第一个问题是 Wekan 中的一些内容无法删除，比如卡片和附件。我部署的时候只给 mongodb 挂载了数据卷，我并不确定 Wekan 是否会把附件一并存储在 mongodb 中，于是我就做了个实验，上传一篇论文作为某卡片的附件，然后终止容器进程并删除容器，再重新部署。结果让我很满意，附件还在。然后我惊奇地发现，当我尝试删除附件的时候，附件删不掉了。当我尝试删除卡片的时候，发现卡片也删不掉了，只能归档。

第二个问题是 Wekan 不支持关闭注册功能。在我和小伙伴完成注册之后，我本想关闭注册功能，然而各种搜索和翻看代码之后，悲伤地发现，现在的 Wekan 似乎不支持关闭注册，在不改动源码的情况下。

在讨论组中咨询确认这个问题，作者表示 Wekan 目前确实缺少系统功能配置方面的支持。

![](http://ww4.sinaimg.cn/large/e724cbefgw1ewhfir4mt5j20k4057dgo.jpg)

最后一个问题是无意中发现的，应该算是我的部署失误。Wekan 用到了 WebSocket，我部署的时候仅仅是做了普通的 HTTP 反向代理，直到无意中在 Chrome Console 发现这个错误信息。

![](http://ww4.sinaimg.cn/large/e724cbefgw1ewh0bjnof8j20ff01ljrw.jpg)

于是我就参考 NGINX 的博客[^1]把 HTTP 反代升级成为支持 WebSocket 的反代。

[^1]: [NGINX as a WebSocket Proxy][6]

```NGINX
location / {
    # HTTP reverse proxy
    proxy_pass http://127.0.0.1:8080/;
    proxy_redirect off;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # WebSocket
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

当然 WebSocket 并不是必须的，在 WebSocket 不可用的情况下，Wekan 会自动使用降级方案，比如长轮询之类的。


[1]: http://www.oschina.net/translate/5-open-source-alternatives-trello
[2]: https://hub.docker.com/r/mquandalle/wekan/
[3]: https://taiga.io
[4]: http://wekan.io
[5]: https://hub.docker.com/r/mquandalle/wekan/~/dockerfile/
[6]: https://www.NGINX.com/blog/websocket-NGINX/
[7]: https://docs.docker.com/compose/yml/
[8]: https://docs.docker.com/compose/

