title: "Hexo 升级与 Docker 初体验"
date: 2015-04-17 18:50:43
tags:
  - Blogging
  - Docker
categories:
  - Study
cc: true
hljs: true
comments: true
---

# 背景 #

之前我一直使用 Hexo 2.8 来编译我的博客。几个星期前的一天，我突发奇想要给 Hexo 来个升级，于是接下来的折腾就开始了。

执行了 `npm install hexo-cli -g` 之后，一切都还好，当我试着执行 `hexo server` 启动服务器的时候，悲剧发生了，没法启动。一番 Google 之后发现从 2.8 升级到 3.0 似乎没那么平滑，于是我决定降回 2.8，然后另选时间升级。

降级之路也不平坦，即使我显式给出了降级之后各个组件的版本，整个依赖树也回不到从前了。可能这个也是 npm 包管理体系的特 (quē) 性 (xiàn) 吧，大家都不太会在依赖中显式的写出某个指定的版本，反而比较喜欢使用版本范围，据说这样子能够自动获取依赖包升级之后的 bug fix 和性能提升[^1]。

[^1]: [如何使用NPM来管理你的Node.js依赖][2]

不管怎么说，这样折腾一番之后，我的 Hexo 博客环境没有之前好用了。看来 2.8 已经没法待下去了，只有升级到 3.0 这条路。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

# Docker #

虽然博客环境没有之前好用，但是它至少还是能够磕磕绊绊把我的博客编译部署的。我希望至少在我升级的时候，我还能使用现在的博客环境。

之前用 Python 的时候，有一个叫 [Virtualenv][1] 的神器，可以在系统中部署多套隔离的 Python 环境，我的电脑里就用它弄了两套完全隔离的环境，一套是 Py27，一套是 Pypy。似乎 Node.js 生态圈中还没有类似的工具。问题在于 hexo 必须安装到全局目录才能作为命令使用，一旦全局安装 Hexo 3.0，势必覆盖 2.8 版本。

如果在过去，我可能会弄一个 Linux 的虚拟机来安装 Hexo 3.0。在容器技术如火如荼的今天，开个虚拟机就为了用 Linux 显得不合时宜而又可笑，仿佛从几年之前穿越过来的。半年前我就在电脑上安装了 Docker，用的是 [boot2docker][3]，文档也看了好几篇，但是一直没有认真用过，只是凑个热闹，假装自己紧跟技术潮流。

这次，我要正正经经的用一次 Docker，至少构建一个包含完整 Hexo 3.0 环境的镜像。

其实 OS X 上有一个看起来还算不错的 Docker GUI 前端，叫 [Kitematic][4]，对命令行无爱的话可以试试（对命令行无爱的人得有多大的勇气才能使用 Docker）。

一番折腾之后，我对 Docker 也算有了一些感觉，总体来说体验不错。Docker 的概念中，容器、镜像等等还挺有意思的。

简单用程序来打个比方，也许不是那么贴切。我们用 Dockerfile 来描述镜像的构建过程，就好像我们用高级语言来描述程序的执行过程；当我们根据 Dockerfile 来构建镜像，就仿佛用编译器把代码编译成可执行文件；当我们把镜像跑起来，容器就产生了，就仿佛可执行文件一旦执行，进程就出现了。

个把小时之后，我成功使用 Docker 基于 ubuntu:14.04 构建出了一个 Hexo 镜像，第二天晚上我成功在镜像中完成了 Hexo 的升级尝试，并把我的博客环境也升级到了 Hexo 3.0。

# 镜像 #

折腾的过程当然不会像我写的这么顺利，这里把一些重要的过程做个记录。

Docker 和 boot2docker 的安装过程这里就不说了，直接参考 [Docker Documentation][5]。

写 Dockerfile 的要点可以参考 [Best practices for writing Dockerfiles][6]，但是写好的 Dockerfile 该怎怎么用，我翻来覆去看了好多遍文档才找到比较科学的方法。

一般来说使用 docker build 的时候，需要传一个保存有名为 “Dockerfile” 的文件的路径作为参数。这种方式的优点是有一个构建的环境，即 Dockerfile 所在的目录，docker 可以在构建的时候使用这个环境中的文件[^2]。

[^2]: [Docker command line - build][7]

对于我构建 Hexo 镜像来说，我不需要这样的构建环境，直接使用重定向把 Dockerfile 传递给 docker 是一个相对更好的选择。

于是我可以随意给 Dockerfile 命名，然后用下面的命令来构建镜像。

```bash
docker build -t jamespan/hexo - < path-to-hexo-docker-file
```

镜像构建完成之后，我可以用下面的命令把镜像跑起来，使用 --rm 参数能够在我退出容器之后自动删除容器，使用 -v 参数能够挂载数据卷，把本地的目录或文件 mount 到容器中，使用 -p 参数能够绑定端口，-t 和 -i 参数经常一起使用，可以给 docker 分配一个虚拟终端，然后一直等待标准输入，像一个 shell 一样工作[^3]。

[^3]: [Docker run reference - Foreground][8]

```bash
docker run -it --rm -p 4000:4000 \
   -v path-to-source:/root/blog/source \
   -v path-to-theme:/root/blog/themes \
   -v path-to-config.yml:/root/blog/_config.yml \
   jamespan/hexo /bin/bash
```

Hexo 的用户应该知道，我们实际上需要关心的，就是两个目录一个文件：source 目录存放我们的博文、页面等，是博客内容；themes 目录存放主题，是博客的样式；\_config.yml 是整个博客的配置，记录一些重要的变量，定义各种插件的行为。

理论上我们能够做到使用容器运行一个安装了必要插件的 Hexo 环境，然后挂载这些目录和文件到正确的目录，就能使用容器为我们提供标准的 Hexo 服务。

# Hexo #

我以 ubuntu:14.04 为基础构建我的镜像，Dockerfile 保存在了 Gist，[点此访问][9]。


```bash
FROM ubuntu:14.04
 
MAINTAINER Pan Jiabang, panjiabang@gmail.com
 
RUN \
  # use aliyun's mirror for faster download speed
  sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y nodejs curl git-core && \
  # use nodejs as node 
  update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10 && \
  # install npm
  curl -L https://npmjs.org/install.sh | sh && \
  # clean up install cache
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /root
 
RUN \
  mkdir blog && cd blog && \
  # install hexo
  npm install hexo-cli -g && \
  hexo init && npm install && \
  # install plugins for hexo
  npm install hexo-generator-sitemap --save && \
  npm install hexo-generator-feed --save && \
  npm install hexo-deployer-git --save && \
  npm un hexo-renderer-marked --save && \
  npm i hexo-renderer-markdown-it --save
 
WORKDIR /root/blog/
 
VOLUME ["/root/blog/source"]
VOLUME ["/root/blog/themes"]
 
EXPOSE 4000
 
CMD ["/bin/bash"]
```

从 ubuntu 开始，先是更换软件源，使用阿里云的镜像，这样子安装软件的速度会快很多。然后就是安装 nodejs、curl 和 git。curl 后面安装 npm 的时候会用到。我之所以没有选择从软件源安装 npm，是因为那样子会顺带安装上很多 *-dev 的包，而我仅仅是搭建 Hexo 环境而已，不需要那些东西的。

接下来一大段脚本是安装 Hexo 及其插件，还有初始化博客目录。最后是声明目录挂载点。

基本上整个镜像的构建脚本都在这里了。

# 升级 #

在 Docker 中尝试安装 Hexo 3.0 是一边调试、部署一边记录，最后把执行过的命令整理成 Dockerfile 的。

调试过程中发现一个有趣的问题，之前使用 Hexo 2.8 的时候，我在编辑器中修改了文件，hexo server 会感知文件变化，然后自动更新静态博客。我在 Docker 中挂载 source 目录然后启动 hexo server，从浏览器访问页面一切都正常，唯独我在编辑器中修改了内容，服务器没有自动更新博客内容，必须让我手动停止然后再重新启动 hexo server。

如果我真正安装 Hexo 3.0 之后也是这种情况，那是没法接受的，我开始查找原因。中间绕了不少弯路，最后查看 npm 安装日志发现是一个叫 fsevents 的可选依赖没有安装。

我想，如果我能够把 fsevents 成功安装，应该就没问题了。谁知道我各种姿势尝试安装之后，还是失败了。查看 fsevents 之后发现这是一个专门用来监听 OS X 系统文件变化的类库。在 Linux 上没法安装一个 OS X 专用类库也是合理的。

好像除了监听文件变化在 Docker 中没法测试之外，其他一切都还好。于是我花了几分钟，把本机博客目录的 node_modules 目录和 package.json 备份之后，升级了 Hexo。

要说这次升级一点后遗症都没有，那是不可能的。不过总体来说，升级到 3.0 之后整体上感觉还是不错的，至少修复了之前困扰我多时的文章发布日期偏移的 bug，代价是我把评论系统从漏洞百出的多说换成了 DISQUS，感觉整个博客瞬间和国际接轨了，萌萌哒~

要不我试着用英文写博客？

[1]: https://virtualenv.pypa.io/en/latest/
[2]: http://www.infoq.com/cn/articles/msh-using-npm-manage-node.js-dependence/
[3]: http://boot2docker.io
[4]: https://kitematic.com
[5]: https://docs.docker.com/installation/
[6]: https://docs.docker.com/articles/dockerfile_best-practices/
[7]: https://docs.docker.com/reference/commandline/cli/#build
[8]: https://docs.docker.com/reference/run/#foreground
[9]: https://gist.github.com/JamesPan/23528eeaaaa4120ef637
