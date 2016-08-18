title: Hexo Server 的一个迷の bug
tags:
  - Blogging
categories:
  - Study
cc: true
comments: true
thumbnail: 'https://ws2.sinaimg.cn/small/e724cbefgw1et26nuhrnhj20c60b4mxl.jpg'
date: 2015-06-13 10:21:25
---


前几天我突然发现，Hexo 启动 server 之后，没法感知文章的修改然后自动刷新页面。这个问题让我很困扰啊。虽然我写 markdown 的时候不需要实时预览，但是修改主题的时候如果没有实时预览，根本就没法开心地玩耍了。

然后我又重新踏上了折腾之路。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

# 入局 #

服务器没法感知文件更新，这种事情用脚趾头想都知道是监听文件系统的模块出了问题。Hexo 有一个核心模块叫 hexo-fs，专门负责和文件系统打交道。然后 hexo-fs 依赖了 [chokidar][1]，这是一个监视文件系统各种事件的类库，它又依赖了 [fsevents][2] 去实现 OS X 上对文件系统事件的监听。

虽然我最近一段时间都没有去更新 hexo 的各个模块，但是我还是觉得问题出在 node 模块上面。于是我开始各种调整 fsevents 的版本，然后各种 npm install。{% heimu 然而并没有什么卵用。 %}

# 困局 #

后来我尝试着把 Hexo 整个干掉，在博客目录旁边新建一个目录，然后用 Hexo init 出来一个全新的只有 Hello World 的博客。没想到这个全新的博客也遭遇了同样的问题。

想到我之前还搞了一个 Docker 镜像，里面有一个好用的 Hexo 环境。在那个版本的 Hexo 环境中，一切都是正常的，修改了文件是能够得到实时更新的。于是我又尝试着把 Docker 中 Hexo 环境的 package.json 文件弄出来，把范围版本修改成固定版本，然后把 Hexo 环境的 node\_modules 目录砍掉重练。{% heimu 然而并没有什么卵用。 %}

# 难友 #

一筹莫展，无计可施。没想到我也有被一个 bug 折腾的死去活来的时候。

只好求助于 Google 了。

然而并没有几个人遇到了和我一样的问题。最后我还是在 Hexo 的 issue 列表[^1]中找到了难友。

[^1]: [\`hexo server\` fails to update content after a while (3.0.0)][3]

但是，整个 issue 里面就只有 3 个人啊！这个问题太小众了啊！其他两个家伙也没办法解决啊！解决问题还是只能靠自己啊！

不过我还是从 issue 交流中获得了一些线索。另外一个遇到同样问题的家伙用的是 Debian，也就是说这个 bug 不是 OS X 独占的了，可以把 fsevents 的问题排除。

# 破局 #

昨天，我突然想起前段时间我弄了一个虚拟机安装的 OS X 10.10，虽然卡的不行但是勉强能用。于是我在虚拟机里面打了快照之后，开始安装 Node.js 环境，Hexo 环境。这样子安装出来的博客居然是好的！

怀着激动的心情，我把本机里面的 Node.js 连同 Hexo 全部砍掉重练，然后满怀期待的在之前的博客目录启动 server。我似乎听到了心碎的声音。

为什么会这样。我心有不甘，然后随手在家目录新建了一个 Hexo 环境。然后，奇迹！粗！线！了！这个博客环境居然是好的。

然后我尝试着把之前的博客目录复制一份到家目录，然后这个博客也就这样莫名其妙的好了。

于是，我的博客目录就从 ~/Sites/blog.jamespan.me 迁移到了 ~/blog.jamespan.me，可怜的家目录又多出一个目录来。

后来又尝试了一下，似乎博客目录放到其他地方比如 ~/Downloads 或者 ~/Documents 都是可以的，唯独 ~/Sites 不行，至于原因，还不清楚。

在把各种尝试时候创建出来的博客目录删掉时，不小心用 rm -rf 把家目录里面的博客目录干掉了。顿时心都凉了。自从我把 Hexo 升级到 3.x，之前用的一个把博客文章备份到 github 的插件就不能用了，于是我除了偶尔记得用 Time Machine 做全盘备份之外，对博客的单独备份一直没怎么做。

还好我在 ~/Sites 目录还有一个博客环境，家目录那个是从那里复制出来的，如果是移动出来的，我就只能老老实实去时光机找备份了。

于是我又可以愉快的写博客改主题了~

另外，[Browsersync][4] 真是神器，我可以同时在 iPhone、iPad、Chrome 上调试页面，推荐安装 Hexo 插件 [hexo-browsersync][5]。

[1]: https://github.com/paulmillr/chokidar
[2]: https://github.com/strongloop/fsevents
[3]: https://github.com/hexojs/hexo/issues/1175
[4]: http://www.browsersync.io
[5]: https://github.com/hexojs/hexo-browsersync
