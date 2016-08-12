title: Babun，一个开箱即用的 Windows Shell
tags:
  - Tool
categories:
  - Study
cc: true
hljs: true
comments: true
date: 2015-04-09 00:13:35
---

# 背景 #

多年以来，无数工程师都试图在 Windows 上制造出不输 Linux 太多的命令行体验，然而绝大部分以失败告终。曾经努力的人，或者回到可爱的 Linux 上，或者进入高贵冷艳的 OS X 的世界。

前辈们为我们留下了一个叫做 [Cygwin][1] 的软件集，让我们在需要的时候可以从 Windows 上启动 bash，安装常见的自由软件。

我曾经也有过一段不得不使用 Windows 进行开发的日子，在那段黑暗的日子里，Cygwin 无疑是一缕春风，一道阳光，给我的笔记本带来了些许效率的色彩。然而，就使用体验来说，Cygwin 与 Linux 相去甚远。且不说软件数量、版本这个硬伤，单是安装软件这一操作，就让人感觉繁琐无比。

虽然 Cygwin 号称 *Get that Linux feeling on Windows*，给人的感觉却一点都不 Linux。

幸运的是，我们现在有了 [Babun][3]，一个 Windows 上的开箱即用的壳程序，基于 Cygwin，胜于 Cygwin。

<!-- more --><!-- indicate-the-source -->

# 简介 #

先从官网[下载][4]最新的 Babun 发行包。如果官网的下载速度较慢，我在百度云分享了一个拷贝，[babun-1.1.0-dist.zip][2]，可以尝试下载。

作者用于传教的视频，从视频的格调上上看就远远比不上之前的 Hypothes.is 了。

<div class="video-container">
    <iframe src="https://player.vimeo.com/video/95045348" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href="https://vimeo.com/95045348">Introduction to the Babun Project</a> from <a href="https://vimeo.com/user27987527">Tom Bujok</a> on <a href="https://vimeo.com">Vimeo</a>.</p>
</div>

# 体验 #

官网列举了 Babun 的 9 大特性，包括但不仅限于：

+ 预先配置好的 Cygwin 以及一系列插件
+ pact：一个类似于 apt-get 或 yum 的包管理器
+ 预先配置好的 git 和 shell
+ 集成 oh-my-zsh

上面这四个特性我觉得最能激动人心，集成 zsh 和 oh-my-zsh 简直不能更赞。作者确实让人感受到了它的用心，用心在做一个产品，而不是工具。

安装 Babun 十分简单，解压发行包之后，执行里面的 install.bat 批处理脚本，然后静静等待执行结束即可，安装结束后 Babun 会自动运行。Babun 默认安装在 `%USER_HOME%\.babun` 目录，似乎可以通过执行 install.bat 脚本时传递 `/target` 参数来指定安装目录，但我没有尝试。

默认的终端模拟器是 Mintty，稍微调节了一下设置之后，看起来还是很不错的，能够把终端半透明化，光标设置成一闪一闪的方块。

![](https://ws4.sinaimg.cn/large/e724cbefgw1exdxigvwxuj20bo06x3ys.jpg)

Babun 默认集成了 Vim，那么我来尝试安装 Emacs。执行 `pact install emacs` 之后开始安装。

![](https://ws2.sinaimg.cn/large/e724cbefgw1exdxj2y6zfj20bn06x403.jpg)

下载各种依赖之后，Emacs 安装成功，不过这是一个纯命令行版本的 Emacs，emacs-nox。

我是一个 OS X 用户，我常常用 open 调用默认程序去打开一个文件，或者在终端中使用 `open .` 在 Finder 打开当前目录。更常用的是把命令的输出重定向到 pbcopy，实现复制到剪贴板，或者用 pbpaste 把剪贴板中的文本输出。

这三个命令，至少在我的认知范围内，Linux 上默认是没有的，当年我曾经使用 xclip 模拟了 pbcopy的功能。Babun 默认提供了这三个可以让人效率大增的命令，让我对作者的细致入微更加钦佩。

# 脚本 #

Babun 内置了 Python、Perl 等解释器。我比较擅长 Python，当我发现 Babun 没有给 Python 带上 pip 之后，表示不能忍，我需要在 Babun 中为 Python 加上包管理。

直接执行下面这个命令就好了。

```bash
wget https://bootstrap.pypa.io/get-pip.py -O - | python
```

有了 pip，我就可以自由的安装诸如 ipython 之类的东西，还有包罗万象的类库。

# 总结 #

Babun 虽然没有多少技术创新，但是它博采众长，追求极致的体验，把其他同类软件狠狠的甩在了后面。

Babun 是近年来最好的在 Windows 下使用 Linux Shell 的一站式解决方案。本文篇幅较短，无法一一描绘 Babun 的动人之处，挂一漏万。

无论是被迫使用 Windows 的 Linuxer，还是离不开 Windows 却又羡慕 Linux 下强大的命令行工具的 PC 用户，Babun 都是一个不容错过的好东西，相信你们会爱上它的。


[1]: https://www.cygwin.com
[2]: http://pan.baidu.com/s/1eQ7yal0
[3]: http://babun.github.io
[4]: http://projects.reficio.org/babun/download


