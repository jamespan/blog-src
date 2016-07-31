title: 对我而言，什么是 Mac
tags:
  - Tool
  - OS X
  - Mac
categories: [Life, Investment]
date: 2015-01-07 02:30:52

cc: true
hljs: true
comments: true
---

# 忆江南

大概是从 10 年开始，Windows 操作系统开始不能满足我对于个人电脑、工作伙伴的要求。为了满足我日益增长的生产力，我开始接触 Linux，开始接触开源运动。一个有数十年历史的计算机科学的宝藏的大门，从那一刻，向我敞开了。

整个大学期间，我在 GNU/Linux 的陪伴下，技术方面获得了快速的成长。我和别人用不一样的工具，不是因为我特立独行，而是因为我的工具比他们的更有威力。

别人用 Visual Studio 写 C++，我用 Emacs 写 Python，别人在学习 Java，我在学习 Lisp。别人用 Office 写论文做幻灯，我用 LaTeX 写论文，用 HTML 5 做幻灯。

技术就是在每天每天的日常使用中，一次一次手贱把系统玩坏，又一次一次把系统修好中，一次一次调整参数、编译程序只为压榨那少得可怜的计算力中，以远超旁人的速度进步着。

或许，如果不是我从学生变成了工程师，如果我还有大把时间慢慢折腾电脑直到它完全符合我的系统洁癖，Linux 我会一直当作主力系统用下去的吧。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

# 相见欢

14 年 3 月，我来到阿里实习。公司发的电脑是一台 ThinkPad，安装的是万恶的 Windows。在经历了将近两个月的生产力严重缩水后，我决定对自己做一次投资。

就像侠客下山前重金打造一把趁手好剑，我为自己购置了一台 15 寸 [rMBP][4]，并期望它在今后的路上，成为我值得信赖的伙伴，帮助我走过艰难险阻，为我节省宝贵的时间。

当然，购置了顶配电脑的后果，就是好几个月都在存钱填补当初的资金亏空。当然，我对此毫无悔意。

公司发的 ThinkPad，被我把整个磁盘格式化之后，安装了 [Linux Mint][5]，毕竟懒得折腾了，这是后话。

# 恨来迟

由于 OS X 内核来自于拥有学院派血统的 FreeBSD，与 Linux 同出一门，江湖传闻 Linuxer 可以无痛切换至 Mac。我一开始对此深信不疑。实际上 OS X 拥有不输于 Linux 的 CLI 和远胜于 Windows 的 GUI，集千万宠爱于一身。我花了大约一个下午的时间，就把 OS X 用到了可以用于生产的熟练程度。如果说我在 Linux 下的生产力是 1 单位，那么我用 Windows 时候的生产力大约在 0.5 单位， 刚开始用 OS X 的时候生产力约 0.8 单位。

显然 OS X 上面有我熟悉的 shell，有我熟悉的命令，这些都帮助我摆脱了 Windows 带来的效率噩梦。美中不足的是，我低估了 BSD 版本工具和我熟悉的 GNU 版本工具之间的差异。有时候这些差异不仅仅是短参数和长参数的问题，而是有些参数根本就不一样的问题。后来当我会使用 [Homebrew][3] 自由自在地在 OS X 上安装各种程序之后，BSD 版本的工具就被我彻底抛弃了。

如今我的 rMBP 组合了来自 Apple 的 GUI，和来自 GNU 的 CLI，可谓博采众长。而如今我的生产力也因为这一强强联合而一再提升。

rMBP 带来的效率提升不仅仅来自最优秀的软件的组合，也来自它本身顶级的硬件配置。15寸的Retina屏幕，让我能够更长时间面对电脑工作不觉乏味，机身的金属质感更是让人感觉到 ThinkPad 的无趣，可能跟我连续 3 台 ThinkPad 笔记本都是塑料机身有关吧。

从本质来说，我信服的不是 RMS 那套自由软件的理论，可能是因为我依旧处于看重效率而看不到意识形态的东西。我使用自由软件不是因为它们自由，而是因为他们强大，能为我提供效率节省时间。

同时我也深深同意[能花钱的，就不要花时间][1]、[先有 Mac 还是先有银元][2]等文中的观点。必要的时候，我愿意付出合理的金钱换取时间换取效率，换取更好体验。

为优秀的正版软件付费，不是从我使用 iPhone 开始，而是从我使用 Mac 开始。我想这是一个好的开始，也许有一天，我的作品足够优秀，能够为用户节约时间，也有人愿意为它付费，虽然我很可能选择将它开源。

# 解语花

如今我的 Mac 已经成为了我在工作和生活上的好伙伴，我衷心希望有 Mac 的读者能善用手中的 Mac，没有 Mac 的读者可以考虑投资自己，给自己买一台 Mac，种下一个期望。接下来是我这几个月在工作中使用 Mac 的一些总结，有一部分来自我大学期间使用 Linux 的经验。

每个人的工作内容不尽相同，同样是 Linux，我作为研发工程师用的熟练的那部分，和运维工程师用的熟练的部分，肯定不一样，大家掌握的都只是一个和工作内容契合的子集罢了。但是如果我熟悉的内容能够在某个时刻帮到你，我就心满意足了。

# 献天寿

这里介绍那些关于 CLI 的有意思的东西。这些 CLI 程序很多都是 POSIX 兼容的，也就是在 Unix，Linux 和 OS X 上都可以运行。

## 双韵子

先介绍两个软件，链接给出了软件的官网或项目主页，有丰富的新手指引，几分钟即可上手使用，精通却需要很多时间。

1. [Homebrew][3]：OS X 上的包管理
1. [Zsh][7] & [oh-my-zsh][6]：终极 Shell

上面两个神一样的软件是愉快使用 OS X 的必要条件，也是接下来各种锦上添花的工具赖以生存的基础环境。

## 定风波

前面提到，我会用 Homebrew 之后，就把 OS X 里面的 BSD 版本实用工具替换成 GNU 版本了。其实不仅仅如此，我还把系统自带的许多实用工具，替换成了我手动安装的高版本。

首先是修改系统的 `PATH` 环境变量。我们安装的 CLI 软件都在 `/usr/local/bin` 目录下，需要在 `PATH` 中将该目录提到 `/usr/bin` 和 `/bin` 的前面，这样系统才会优先识别我们安装的程序。

然后是用 Homebrew 安装 `coreutils`、`gnu-sed` 和 `gnu-tar`，然后修改 ~/.zshrc 文件，在插件列表中加入 `gnu-utils`，这样就把自带的 BSD 软件替换为 GNU 版本了。

## 宝鼎现

习惯了 Linux 下自带的大量实用工具，刚开始使用 OS X 时还真有点不习惯，本来以为肯定有的软件，敲完命令得到的却是 command not found。

没关系，我们可以自己动手，丰衣足食。

想要下载，我们可以安装 wget；想要安装 GUI 应用，我们可以安装 [brew-cask][9]；想要输出目录树，我们可以安装 tree；

```plain
/usr/local/Cellar/maven2/2.2.1/libexec
├── bin
│   ├── m2.conf
│   ├── mvn
│   └── mvnDebug
├── boot
│   └── classworlds-1.1.jar
├── conf
│   └── settings.xml
└── lib
    └── maven-2.2.1-uber.jar

4 directories, 6 files

```

想要快速文本匹配，我们可以安装 ack；想要扫描端口，我们可以安装 nmap；想要酷炫地查看系统软硬件配置，我们可以安装 archey；

```plain

                 ###
               ####                   User: panjiabang
               ###                    Hostname: JamesPans-Mac
       #######    #######             Distro: OS X 10.10.1
     ######################           Kernel: Darwin
    #####################             Uptime: 2 days 10:19
    ####################              Shell: /bin/bash
    ####################              Terminal: linux
    #####################             Packages: 40
     ######################           CPU: Intel Core i7-4850HQ CPU @ 2.30GHz
      ####################            Memory: 16 GB
        ################              Disk: 44%
         ####     ##### 
```

想要方便的利用多核，我们可以安装 parallel；想要在各种标记语言中间游刃有余，我们可以安装 pandoc；想要在管道里使用 SQL，我们可以安装 [q][8]；想要增量同步，我们可以安装 rsync；还有很多很多有趣的程序等待你去发掘，OS X 继承了 Unix 几十年时间沉淀下来的宝藏。

# 柳初新

这里介绍那些关于 GUI 的有意思的东西，这些基本是都是 OS X 独占的程序，包括开源、免费、收费等各种应用。

## 蝶恋花

首先，我们安装 Homebrew 的好朋友，[Homebrew Cask][9]。有了它，我们就可以任性的从命令行安装和管理 GUI 应用了。

> Homebrew Cask extends Homebrew and brings its elegance, simplicity, and speed to OS X applications and large binaries alike.
It only takes 1 line in your shell to reach 2219 Casks maintained by 1171 contributors.

然后是确保你能使用 Mac App Store，上面有一些很不错的收费软件，还有一些虽然免费但是只能从 App Store 安装的软件。

## 浪淘沙

先说说那少数几个只能从 App Store 安装的应用。

[Notebooks][10] 是一个很棒的本地笔记应用，支持 Markdown 读写分离，即提供编辑界面和渲染好的只读界面。可以自定义渲染 Markdown 时候的 CSS 和 js，这就给用户提供有很大的想象空间了，想要什么样式，什么风格的代码高亮，随心所欲的 [MathJax][11] 渲染数学公式，都不在话下。虽然这个应用有单独下载版本，但是 App Store 版本便宜了好几十块钱我会说？

[Monosnap][12] 是一个中规中矩的截屏工具，我之所以选择它，一来是因为它在多屏环境下表现良好，二来是它支持截图的即时编辑。

[1Password][13] 是一个密码管理工具。如果你还在密码的安全性和便捷性中间苦苦挣扎，它绝对能把你从泥潭中解救出来。

接下来是那些能用 Homebrew Cask 安装管理的应用们。发挥你的想象力吧，不仅有常见的 Google Chrome、Evernote，还有好多好多 OS X 独有的应用。

[iTerm2][14] 是OS X 下最好的虚拟终端，没有之一。

[smcFanControl][15] 是 OS X 下最干净便捷的风扇管理，为了把 Mac 放在大腿上玩的时候不感觉到烫，最好安装一个。

[Mou][16] 是 OS X 下最好的 Markdown 编辑器之一，而 [Macdown][17] 则是它的复刻和增强。

[Sublime Text][18] 是强大程度仅次于 Vim 和 Emacs 的编辑器，而 [Brackets][19] 是来自 Adobe 的编辑器界的新秀，[TextWrangler][20] 是 OS X 上老牌文本编辑器 BBEdit 的简化免费版，对天朝国情（GBK）的支持的很好。

[MPlayerX][21] 是 OS X 下最好的视频播放器，后端是命令行播放器 mplayer，最神奇的是 mplayer 能用 ASCII 来播放视频。当你我用 Linux 的时候，专门进入文本模式用 mplayer 放了一段视频，画面太美不忍直视。

[GIMP][22] 是最好的开源图像编辑器，没有之一。虽然差了 PS 很多，但是它还是个可用的软件。

两个 Git 图形化前端，[Source Tree][23] 和 [GitHub for Mac][27]。SVN 前端都挺贵，对天朝国情的支持还不到位，还不如直接用命令行或者 IDE 插件。

开发者的好朋友，[JetBrains][24] 系列，如 [IntelliJ IDEA][25]、[PyCharm][26] 等等，可用都可以从 Homebrew Cask 安装管理。

# 醉花间

最后的最后，推荐[池建强][28]的著作，《[MacTalk·人生元编程][29]》。

[1]: http://daily.zhihu.com/story/3387025
[2]: http://zhuanlan.zhihu.com/mactalk/19693202
[3]: http://brew.sh/
[4]: http://store.apple.com/cn/buy-mac/macbook-pro?product=MGXC2CH/A#tab2-info
[5]: http://www.linuxmint.com
[6]: https://github.com/robbyrussell/oh-my-zsh
[7]: http://www.zsh.org/
[8]: http://harelba.github.io/q/
[9]: http://caskroom.io
[10]: http://www.notebooksapp.com
[11]: http://www.mathjax.org
[12]: https://www.monosnap.com
[13]: https://agilebits.com/onepassword
[14]: http://iterm2.com
[15]: https://github.com/hholtmann/smcFanControl
[16]: http://25.io/mou/
[17]: http://macdown.uranusjr.com
[18]: http://www.sublimetext.com
[19]: http://brackets.io
[20]: http://www.barebones.com/products/textwrangler/
[21]: http://mplayerx.org
[22]: http://www.gimp.org
[23]: http://www.sourcetreeapp.com
[24]: https://www.jetbrains.com
[25]: https://www.jetbrains.com/idea
[26]: https://www.jetbrains.com/pycharm
[27]: https://mac.github.com
[28]: http://weibo.com/idreamland
[29]: http://book.douban.com/review/6596765/
