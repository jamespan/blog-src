title: 若为自由故——重返 Linux 世界
tags:
  - Linux Mint
  - Linux
  - KDE
categories:
  - Work
cc: true
hljs: true
comments: true
thumbnail: 'https://ws1.sinaimg.cn/thumbnail/e724cbefgw1ewhvh0cy7yj21jk1jkds2.jpg'
date: 2015-10-03 02:13:25
---

入职以来一直用自己的 MacBook Pro 来为公司工作，最近却整出了个强制安装杀毒软件的事情，我觉得是时候对自己的电脑好一点了。上帝的归上帝，凯撒的归凯撒，自己的净土必须自己来守护，以后就用 Linux 来为公司工作。

You can you use Linux, no can no bb。从某种意义上来说，公司还蛮宽容的，给不愿意安装杀毒软件的开发狗们留了一条生路，虽然这条路对于大多数开发狗并不好走。毕竟不是所有的开发狗都像我一样在大学期间把 Linux 当做日常系统来使用的（捂脸逃

<!-- more --><!-- indicate-the-source -->

于是我在周末花了几个小时在公司发的 ThinkPad 上面安装了 Linux 系统。接下来是关于我组装一个还算顺手的 Linux 系统的分享，当然其中不可避免的会用到一些非自由软件。毕竟对于一个资深 Mac 用户来说，Linux 在日常使用的体验上还是稍显稚嫩，常用的快捷键也不太一样，需要一番悉心调教。

## 安装一个 GNU/Linux 发行版 ##

安装 Linux，如今我的首选发行版是 Linux Mint。如今 Mint 的最新版本已经是 17.2 了，之前我最后一次安装的时候似乎还是 15 呢，真是让人感慨。

桌面环境选择 KDE，为的是不折腾，也为的是能够好好折腾。下载光盘镜像，用 dd 命令刻盘，启动 LiveCD，安装系统，习惯性地选择了全盘加密。

安装完成后启动，依旧是熟悉的 KDE 桌面，但是登陆界面比以前更漂亮了，背景图片还会自动轮换的~

![MDM 登陆界面](https://ws1.sinaimg.cn/mw1024/e724cbefgw1ewnb8odazkj211y0lcdz0.jpg)

## 那些自由的和非自由的软件 ##

KDE 不仅仅是一个桌面，更是一个软件集。只要磁盘空间足够，我会毫不犹豫地安装一个叫做 kde-full 的软件包，里面包含了几乎全部的 KDE 软件。

先做一下需求分析，这次装系统，主要是用来作开发机，顺便支持一下开发过程中的音乐和上网开小差。于是几个刚需就出来了，Java 开发环境，中文输入，阿里旺旺，截图编辑，Python 运行环境，Office 文档支持，多媒体播放，多浏览器，多显示器……

看起来要安装的东西很多，其实全部搞好也就是几个小时的事情。慢慢来，会很快。

1.  Java 开发环境

    我的工作主要集中在 Java 服务端，所谓 Java 开发环境，无非就是 JDK、Maven 和 IDE，前面两个直接从仓库安装就好了。

    ```bash
    sudo apt-get install openjdk-7-jdk maven2
    ```
    
    我常用的 Java IDE 是 IDEA，似乎不在仓库中，需要去官网下载软件的压缩包，解压之后做个快捷方式放到桌面即可。

    其他 Java 工具如 jvisualvm 等等，因为使用频率没那么高，需要的时候再安装也不迟，反正都在仓库中。

    文本编辑器什么的也强行算到开发环境里面好了~

    ```
    sudo add-apt-repository ppa:webupd8team/sublime-text-2
    sudo apt-get update
    sudo apt-get install sublime-text emacs24
    ```

2.  中文输入

    中文输入一直是 Linux 用户心中的痛，也许这就是传说中的「逼格税」。输入法框架 ibus 和 fcitx 平分天下，却时不时陷入界面库的陈年老坑，有时候是候选词不跟随，有时间是没法在 Emacs 等神器中使用。输入法引擎虽 Rime 如日中天，却需要用户长期的调教，缺乏强有力的默认词库和云联想。

    虽然道路坎坷崎岖，我们却不轻易放弃。上次安装系统的时候用的 fcitx，这次用的是 ibus-rime。

    ```bash
    sudo apt-get install ibus-rime ibus-gtk* ibus-qt4
    ```

不知道是不是因为 Emacs 升级到 24 的缘故，ibus-el 这个插件失效了。塞翁失马，我发现了一个神奇的 Emacs 插件，chinese-pyim，一个用 elisp 实现的中文输入法！

3.  阿里旺旺

    随便在网上搜索一下就能找到一个阿里旺旺 Linux 版。噢，这是一个 buggy 的软件。

4.  截图编辑

    Shutter 是 Linux 上最好的截图编辑工具，没有之一！单独安装 shutter 只能实现截图，需要安装一个额外的软件包才能实现编辑。

    ```bash
    sudo apt-get install shutter libgoo-canvas-perl
    ```

5.  Python 运行环境

    Python 是我最擅长的语言之一，少了它可不成。我需要一个好用的终端，一个包管理器。

    ```bash
    sudo apt-get install ipython python-pip
    ```

6.  Office 文档支持

    Mint 自带了 LibreOffice，但是这远远不够，我们还需要 WPS。直接去官网下载最新的 Alpha 测试版来安装。

7.  多媒体播放

    KDE 已经自带了音乐播放和管理软件 Amarok 和视频播放器，Mint 还默认安装了 VLC。Amarok 已经够用了，虽然我不会用它的，听歌自然是用网易云音乐~视频播放器我还需要 Smplayer。

    ```bash
    sudo apt-get install smplayer
    ```
8.  多浏览器

    Mint 自带的 Firefox 是极好的，但是我更需要 Chrome，因为我工作相关的网页书签都在里面。KDE 自带的浏览器并没有什么卵用。Chrome 用来工作，Firefox 用来听歌+开小差，看到好文章直接扔到 pocket 里面。


## 让它用起来有一点点像 OS X ##

首先是修改键盘上几个重要控制键的位置。我的使用习惯是 Ctrl 在字母 A 的左边，空格往左依次是 command、option、caps lock（Ctrl）。我的 Mac 键盘实际上是没有 capslock 的，因为我觉得这个按钮并没有什么用处。

![常用键位](https://ws2.sinaimg.cn/bmiddle/e724cbefgw1ewlhcm7601j21kw16otp1.jpg)

显然，Linux 的世界既没有 command，也没有 option，我只能想方设法用 Ctrl 和 Alt 作一个残缺的替代。

KDE 默认提供了一些可视化的工具以及默认选项来帮我完成这些按键映射的工作。

首先我们把 caps lock 和 Ctrl 交换位置，这样 A 的左边就是 Ctrl，可以用小指轻易地控制。然后把左 Ctrl 映射到左 Alt，左 Alt 映射到左 Win，这样就可以保持 Mac 下面 command + c 是复制，command + v 是粘贴等等习惯。映射到 Win 键上的 Alt 正好和 Mac 键盘上的 option 在同一个位置，这样一来，左手对于键盘左下角的几个控制键的肌肉记忆就几乎不用改变了。

![KDE 控制键调整](https://ws4.sinaimg.cn/large/e724cbefgw1ewnbxncqkzj20dg0pggoa.jpg)

虽然说是几乎不用改变，但是由于 Linux 没有 command 键，没法很好地区分从命令行继承过来的快捷键和图形界面的快捷键，所以我深爱着的 ctrl 光标移动大法就不能用了，这让我蛋疼了好久。不过好在按错键顶多就是全选而已，并没有什么破坏性的后果。

我曾经尝试把左 Alt 映射成 Meta，然后修改系统快捷键设置，强行弄出一个 command 键，比如复制是 Meta-c，撤销是 Meta-z 等等。一开始的时候在，这套按键映射和快捷键方案在 KDE 系列软件中运行良好，然而当我打开 Chrome 的时候，蛋都碎了。果然这套快捷键只能在 KDE 系列软件中生效，Chrome 里面依旧是我行我素的 Ctrl 系快捷键。面对这么一个残酷的现实，我只好把快捷键方案回滚到默认设置去了。

键盘调教了七七八八，接下来要调教的是鼠标。什么，你说触摸板？ThinkPad 有触控板这个东西么？

其实鼠标上值得调教的也就滚轮了，习惯了 OS X 那高冷的「自然滚动」，自然而然就会觉得其他系统鼠标滚轮的方向就是异端。把鼠标滚轮搞成自然滚动也很简单，确保下面这段命令，或者有同样功效的配置，启动的时候执行或生效即可。

```
xmodmap -e "pointer = 1 2 3 5 4 7 6 8 9 10 11 12"
```

搞了这个修改之后，无论是鼠标还是小红点，滚动模式都变成了『自然滚动』。

还有其他许多细节上的调教，比如把窗口的关闭、最小化、最大化移动到窗口的左上角去模仿 OS X 的红绿灯之类的。总之就是尽可能保持之前在 OS X 上的操作习惯，尽可能的不要引入新的操作方式，防止脑裂。

## 用 Linux 工作一周的感觉 ##

首先是工作使用的电脑和个人使用的电脑完全分开了，就像我一开始说的，上帝的归上帝，凯撒的归凯撒。第二天下班回家之后，我把 Macbook Pro 上跟公司相关的各种{% ruby 内部软件|木马后门 %}、证书删了个精光，感觉爽爽哒！

然后因为我把工作电脑扔在公司，这样子我就不用每天上下班背着电脑到处跑了，感觉轻松不少！回家之后打开电脑就可以开始做自己的事情，不用像之前一样上班为公司写代码，回家也为公司写代码，随便搞点开源项目也不用担心被公司霸王硬上弓。

因为旺旺 Linux 版到处是 bug 的缘故，它动不动就会崩溃，收不到系统消息，收不到文件，点对点沟通收不到图片，不胜枚举。或许是因祸得福，系统动不动出现的接口 RT 过高之类的告警我就收不到了，旺旺崩溃收不到消息也让我可以清静地写代码。

最重要的是，我不用安装那个逗逼一样的杀毒软件了！




