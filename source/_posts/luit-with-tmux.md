title: Tmux、Luit 杂谈
tags:
  - Linux
  - Encoding
categories:
  - Study
hljs: true
cc: true
comments: true
thumbnail: https://ws1.sinaimg.cn/small/e724cbefgw1et0lz06e18j212p0nywk0.jpg
date: 2015-06-12 00:13:02
---

最近有一天在半睡半醒间折腾应用的部署脚本，折腾好了天也亮了。期间顺便折腾了一下 Tmux 和 Luit，弄了一套勉强可用的 Tmux 配置出来。

sdfsdTmux 一般都是安装在服务器使用才能发挥最大效用，本地使用的话，似乎只能当作一个终端复用的工具，对效率没有太明显的提升。

<!-- more --><!-- indicate-the-source -->

其实我大学期间就有用过 Tmux，而且那时候我还给实验室的服务器装了个 Tmux 来用着。但是那时候我没有怎么折腾配置，就着原生的配置，切切窗口，还觉得要想复制一个东西太麻烦了。

后来工作之后，公司的服务器上面没有 Tmux，我就渐渐的越来越少接触 Tmux 了，iTerm2 太好用也是其中一个原因。

最近我看到几篇关于 Tmux 的博文[^1][^2]，把 Zsh + Vim + Tmux 吹的天花乱坠，我的心里又开始长草。

[^1]: [文本三巨头：zsh、tmux 和 vim][2]
[^2]: [10 Killer Tmux Tips][5]

最后参考了 fooCoder 的博文《[终端环境之tmux][3]》和 Treri Liu 的 Tmux [配置][4]，以 fooCoder 的配置为基础，加入了其他我觉得有意思的配置。

![Tmux 终端复用](https://ws1.sinaimg.cn/large/e724cbefgw1et0lz06e18j212p0nywk0.jpg)

由于某种不可抗力，我登录到服务器之后，总是没法避免的需要修改一下终端的文本编码，不然日志什么的都会乱码。之前我一直是手动修改，最近我终于感到厌烦，希望结束这一切重复的动作。

那么该如何做呢？我找到两种方案，各有所长。

第一种是基于 iTerm2 的编码切换方案，来自《[Mac OSX iTerm2 终端UTF-8和GBK编码自由切换][6]》。

```bash
#!/bin/bash
# 使用GBK Profile
echo -ne "\033]50;SetProfile=GBK\a"
# 环境编码切换为GBK
export LANG=zh_CN.GBK
export LC_ALL=zh_CN.GBK
# 更改当前 iTerm2 tab title
echo -ne "\033]0;"$@"\007"
$@
echo -ne "\033]0;"${PWD/#$HOME/~}"\007"
# GBK任务完成后，自动切换回默认编码（UTF-8）
echo -ne "\033]50;SetProfile=Default\a"
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
```

第二种是使用 Luit 做编码转换。

Luit 似乎没有被收录到 brew 仓库，需要手动下载编译，不过也是很简单的。

```bash
wget -c ftp://invisible-island.net/luit/luit.tar.gz
tar -xzvf luit.tar.gz
cd luit-20141204/
./configure
make
make install
```

搞定之后直接执行下面的命令就可以用指定编码登录服务器了。

```
TERM="xterm" luit -encoding <encoding> ssh <ip>
```

不知什么缘故，我的 Hexo 环境出了点问题，启动的 hexo server 没法像以前一样监听文件的变更了，真是要命。出问题的可怜虫还不止我一个，我在 Hexo 的 issue 列表里面找到了类似的[问题][1]。希望这个问题能早点解决，不然写博客的体验那是大大的糟糕。

[1]: https://github.com/hexojs/hexo/issues/1175
[2]: http://blog.jobbole.com/86571/
[3]: http://foocoder.com/blog/zhong-duan-huan-jing-zhi-tmux.html
[4]: https://github.com/Treri/dotfile/blob/master/tmux/tmux.conf
[5]: http://www.sitepoint.com/10-killer-tmux-tips/
[6]: http://blog.chenxiaosheng.com/posts/2013-10-29/mac_osx_iterm2_utf8_gbk_switch.html

