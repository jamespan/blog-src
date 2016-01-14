title: 静态编译 Tmux
tags:
  - Linux
categories:
  - Work
hljs: true
cc: true
comments: true
date: 2015-06-12 23:36:07
---

最近开始使用 Tmux 之后，感觉还是在服务器上才能发挥出 Tmux 的价值。可惜的是公司的服务器上没有安装 Tmux，跳板机上我也只有普通用户权限，没法安装软件，于是我琢磨着从源码编译一个。

Tmux 唯一的依赖是 libevent，所以我需要先把它编译出来。之前我编译软件之后都是直接使用 root 权限，如今没有了 root 权限，安装软件都成了让我拙计的事情。

<!-- more --><!-- indicate-the-source -->

先从最近声名狼藉的 sourceforge 把 libevent 的源码包抓下来，然后从 Github 把 tmux 的源码包也抓下来。

```bash
wget -c https://sourceforge.net/projects/levent/files/libevent/libevent-2.0/libevent-2.0.22-stable.tar.gz
wget -c https://github.com/tmux/tmux/releases/download/2.0/tmux-2.0.tar.gz
```

解压之后开始配置编译过程。当我们没有 root 权限的时候，编译之前就要设置软件的安装目录了。

```bash
./configure --prefix=~/libevent
make
make install
```

不同的软件编译配置不尽相同，但是作为一个约定，`configire -h` 总是能给出当前命令的帮助文档。

安装 libevent 到指定目录之后，可以开始编译 tmux。因为要让 tmux 的 configure 脚本找到 libevent，tmux 的安装命令稍显复杂。

```bash
./configure --prefix=~/tmux --enable-static CFLAGS=-I~/libevent/include LDFLAGS=-L~/libevent/lib
make
make install
```

CFLAGS 是 C 编译器参数，-I 后面带着需要引用的头文件的路径。LDFLAGS 是链接器的参数，-L后面带着库文件的路径。

与 libevent 的默认开启静态链接不同，配置 tmux 编译过程时需要显示开启静态链接，否则以后运行 tmux 的时候都需要在动态库目录中包含 libevent 的动态库。当然，静态链接之后的二进制文件会相应的大一些。


