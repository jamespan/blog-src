title: 博客以及反向代理的容器化
tags:
  - Docker
  - Vagrant
  - DaoCloud
  - Alpine Linux
  - Ansible
  - Blogging
categories:
  - Study
hljs:
  - dockerfile
thumbnail: //i.imgur.com/Y1zGn4k.png
cc: true
comments: true
date: 2015-11-15 01:23:20
---

双十一当天晚上，我成功地在 DaoCloud 使用 Docker 部署了一个博客镜像。于是我的「[分布式高可用博客][7]」有了第三个后端😂。

DaoCloud 根据代码目录中的 Dockerfile，在代码提交到 Github 之后，自动抓取最新的代码进行自动集成，通过集成后就构建 Docker image，然后自动部署最新的镜像。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

虽然之前也写过不少 Dockerfile 了，但是还没写过专门用在 DaoCloud 上面的，于是我就入乡随俗先看看文档，然后看看他们给出的 2048 游戏镜像的例子。

比较有意思的是，[示例镜像][2]是基于一个叫 [Alpine Linux][1] 的极小发行版构建的。之前我构建的镜像都是基于 Ubuntu，最后构建出来的镜像体积都挺大，随随便便就几百兆字节的。Alpine Linux 镜像的体积才 5MB，相比起 Ubuntu 默认镜像的体积，简直让人惊叹。

## 博客容器化 ##

经过一番调试，我弄出了这么一个 [Dockerfile][3]，基本上只要把它放到 Hexo 博客的源码目录并把源码托管到 Github，就能够在代码变更之后让 DaoCloud 自动构建出最新的镜像来。

这个构建过程和之前使用 Travis CI 进行自动部署的过程差不多，也是先把源码 clone 下来，然后执行由 [daocloud.yml][4] 定义的持续集成，集成通过之后就开始根据 Dockerfile 构建镜像，然后把镜像推到仓库，并部署到 DaoCloud 集群上的某个角落。

在 Travis CI 完整执行一次自动部署耗时在 2 分钟左右，也就是提交变更之后出去泡杯咖啡回来就能看到新文章出现在网上。然而，完整构建一次博客镜像至少需要五分钟甚至十几分钟！

![](//i.imgur.com/rhwPcXQ.png)

这个构建时间有点可怕。考虑一下 Travis CI 和 DaoCloud 同时开始下载源码去部署的场景，必然是 Github 和 CNPaaS 先部署好，之后再过个几分钟 DaoCloud 才部署好，这个数据不一致的时间窗口也太长了点。

压缩构建时间要从最耗时的步骤下手。构建过程中下载编译依赖的 Python、g++ 等软件包，以及博客使用到的各种插件，是一个及其耗时，但是又可以事先准备好的工作，那么我只要发布一个事先准备好环境的镜像到 Docker 仓库，以后的镜像构建都只要基于这个环境镜像就可以了，不但环境稳定而且还可以享受镜像缓存之后带来的速度提升。

于是我就写了如下 Dockerfile，直接从本地推了一个叫 [jamespan/hexo-env][5] 的镜像到 Docker Hub。


```dockerfile
FROM alpine:3.2
MAINTAINER Pan Jiabang <panjiabang@gmail.com> 
# Install Nginx and Node.js env
RUN apk update
RUN apk add nginx
RUN apk add nodejs python make g++ && rm -rf /var/cache/apk/*
COPY ./package.json /tmp/
WORKDIR /tmp/
# Install hexo and dependences
RUN npm install hexo -g 
RUN npm install && npm cache clean
CMD ["sh"]
```

然后修改博客的 Dockerfile 去基于 jamespan/hexo-env 来构建镜像。

```dockerfile
FROM jamespan/hexo-env:latest
MAINTAINER Pan Jiabang <panjiabang@gmail.com> 
# Copy blog source
COPY ./ /tmp/
WORKDIR /tmp/
# Generage site
RUN hexo generate
RUN rm -rf /usr/share/nginx/html \
    && mv /tmp/public /usr/share/nginx/html
EXPOSE 80
# Start Nginx and keep it from running background
CMD ["nginx", "-g", "daemon off;"]
```

这样一来构建博客镜像的时间基本上就消耗在基础镜像、生成静态文件、上传镜像三步上面了。为了让整个构建速度更快，我把「构建缓存」这个选项关闭了，因为生成静态文件这个步骤实在是没啥好缓存的，关闭之后能省去上传中间容器的时间。

![](//i.imgur.com/2GQqxA3.png)

于是整个镜像的构建上传时间减少了大约 70%，变成了两分钟左右的样子，加上持续集成和部署的时间，总算和 Travis CI 部署到 Github 差不多了！

![](//i.imgur.com/eYYQ187.png)

一个意外的惊喜是部署到 DaoCloud 的博客镜像可以通过 HTTPS 去访问，我可以直接访问它去调试 HTTPS 化的博客，替换资源、webfont 之类的。Let's Encrypt 就要正式发布了，为 HTTPS 时代的到来做好准备吧~幸好 BootCDN 已经支持 HTTPS，不然我还得为找一个前端资源的 CDN 大费脑筋。博客中大量使用图片，之前都把图片上传到了「微博图床」，可惜它不支持 HTTPS，我只好把新图片都上传到 imgur 上面去，老图片就既往不咎了。

## 反向代理容器化 ##

之前因为用 Docker 用了半截，只用 Docker 部署应用，外面却直接在系统里面跑一个 Nginx 做反代，而被某菊苣鄙视一番，教育我皈依了 Docker 就要用 Docker 解决问题。于是我决定把 Nginx 也容器化起来。于是呢，我就在原本维护 Nginx 配置文件的目录中加了一个 Dockerfile，基于 Alpine Linux 搞了一个容器，然后推送到 Docker Hub。

那么我应该如何在两台服务器上部署容器呢？目前还是得借助 Ansible。为了操作服务器上的 Docker，我们首先需要在服务器上安装一个 Python 模块，docker-py。需要注意的是，最新版本 1.5.0 和 1.7.1 的 Docker Client 不太兼容，需要安装 1.4.0 版本的[^1]。

[^1]: [Cannot pull image with docker-py 1.5.0][6]

写了一个部署 Docker 的 playbook，然后就可以用它在两台机器上批量执行更新镜像、杀死容器、启动新容器之类的工作了~

```json
- hosts: all
  tasks:
  - name: Install Docker PY
    pip: name=docker-py==1.4.0 
    become: yes
  - name: Start nginx proxy
    docker:
      name: ng-proxy
      image: jamespan/nginx-proxy
      state: reloaded
      pull: always
      ports: 
      - "80:80"
```

因为不想直接在 nginx 里面使用 link 来连接容器，因为 nginx 需要部署在多台机器上，有些镜像只是作为玩具部署在一台机器。于是就有两种方案来做反代了，一种是在启动 nginx 容器的命令中配置网络，直接使用主机的网络栈，另外一种是在 nginx 的配置中直接写死 ECS 的 ip。

我这里采用的是第二个方案，我不想直接让 nginx 使用主机网络栈，因为我在 nginx 里面搞了太多乱七八糟的端口监听，而且这些都可以被包进容器里。如果使用了主机网络栈，这些乱七八糟的端口监听就全都暴露在网络上面了，跟之前直接部署 nginx 的时候一样。

## 尝试 Vagrant ##

双十一当晚，我在公司调试构建静态博客的 Dockerfile，一开始用的 boot2docker，不知为何在向容器中复制文件的时候遭遇了奇怪的问题，只把文件复制进去了，目录没复制进去，于是走到生成静态文件那一步的时候就出错了。

可怜的我只好在本地瞎写然后提交代码，让 DaoCloud 直接构建镜像然后看效果，简直悲惨。

当时我也没有仔细追究，就以为是 boot2docker 有坑，于是我就想着换一个姿势，在虚拟机里面安装 Linux，然后从里面使用 Docker（当时并没有意识到这其实和 boot2docker 是一样的）。

直接操作虚拟机其实是比较麻烦的，Vagrant 为我们从命令行直接操作虚拟机提供了便利。一开始我使用的是 Ubuntu 的 box，跑在 VirtualBox 里面。一开始的时候一切顺利，直到我执行一些涉及磁盘 IO 的操作，VirtualBox 就开始出现 CPU 跑满的情况，直接把分配给虚拟机的那个核心跑满了。

这真是让我一筹莫展，看 VBox.log 并没有发现端倪，网上搜索得到的结果也是毫无帮助。于是我只好把 Vagrant 的后端换成了 Parallels。去年黑色星期五的时候我趁着降价买的授权，装了个 Win7 跑 Office，除此之外别无用处，这次终于有了点价值。

本来我是不想装虚拟机的，无奈工作中偶尔还是需要写 Office 文档`(╯°□°）╯︵ ┻━┻`，工作之后就不能像在学校那样随心所欲的装逼了，只能老老实实搞一个虚拟机备用。

但是我发现 Vagrant 并没有想象中的好用。于是我贼心不死的想去重现一下当初没有复制目录的问题，但是重现不出来了。于是我就这样又用回了 boot2docker，过几天找时间把 Vagrant 删了。

## 纪念 CNPaaS ##

最早的时候，我的博客部署在 Github Pages 上面。再往后，同时部署在 Github Pages 和 Gitcafe Pages。再往后，Gitcafe 被 DDos 了，我把 Gitcafe 的部署转移到了 CNPaaS。前几天，我把博客同时部署到了 Github Pages，CNPaaS 和 DaoCloud。

之后我无意中随手打开了 CNPaaS 的主页，就被 301 到了他们的博客，随之而来的居然是一封「停止运营」的公告。

![CNPaaS 停止服务](//i.imgur.com/JNIfGDt.png)

创业不易。

云计算三大模式，IaaS、PaaS 和 SaaS，底层卖硬件，顶层卖软件，都混得风生水起，唯独夹在中间 PaaS 日渐式微。或许 PaaS 本身就是个伪命题，因为它把服务端软件开发带回到上个世纪那种针对某个平台开发的时代，在 A 平台上开发出的应用需要伤筋动骨的改造才能在 B 平台运行，违背了云计算的初心。


[1]: http://alpinelinux.org/
[2]: https://github.com/DaoCloud/dao-2048/
[3]: https://github.com/JamesPan/blog-src/blob/caec690978af9aa96bd7837f86aa46c886bd436e/Dockerfile
[4]: https://github.com/JamesPan/blog-src/blob/master/daocloud.yml
[5]: https://hub.docker.com/r/jamespan/hexo-env/
[6]: https://github.com/docker/docker-py/issues/807
[7]: /2015/10/26/ha-deployment-for-blog/

