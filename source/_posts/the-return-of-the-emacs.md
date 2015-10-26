title: Emacs 归来记
tags:
  - Emacs
categories:
  - Study
cc: true
comments: true
date: 2015-04-05 18:08:47
thumbnail: http://ww4.sinaimg.cn/small/e724cbefgw1et29jaibmlj213l0o2aj2.jpg
---

> 归去来兮，田园将芜胡不归？

# 背景 #

从一开始我就知道，有一个编辑器，被称为神的编辑器，另一个编辑器，被称为编辑器之神。那是大一的时候，我刚开始系统的学习计算机科学，需要一个趁手的编辑器。

最开始的尝试，是从 Vim 开始的。图书馆里我借到一本叫《学习vi和Vim编辑器》的书，开始了蹒跚学步。后来，我发现我始终无法领会 Vim 的精髓，编辑速度没能得到很大的提升。

大三的时候，我看了大名鼎鼎的《计算机程序的构造和解释》，从此加入了括号神教。于是，我的编辑器也从 Vim 变成了 Emacs。

<!-- more -->

那是第一次，我发现我可以用我熟悉的语言，去自定义我的编辑器。如此多的插件，都用 lisp 实现，整个编辑器，简直就是括号神教教众的游乐场。

毕业的时候，我的论文，以及论文中实验用的程序，都是在 Emacs 下编辑的。那时候，Emacs 24 刚发布不久，我还停留在 23 版本上。

# 疏远 #

后来，我工作了。不再有大把的时间让我用我喜欢的语言，做我喜欢的研究。

每天每天都在 IDE 的帮助下和大把大把的 Java 代码死磕，从 eclipse 到 IDEA。日常使用的文本编辑器也从 Emacs 变成了 Sublime Text为主，其他 OS X 上的编辑器为辅，再也没有 Emacs 什么事情。

再后来，Emacs 被我卸载了。

# 思念 #

那是一段与时间赛跑的日子，为了成长努力工作，为了更快的成长拼命的加班。

我渐渐感觉自己迷失在了日复一日的工作里，晚上回家越来越晚，早上起床越来越晚。虽然技术进步很快，比我之前在学校里自己钻研快得多，但是我总觉得，似乎在什么地方，我的生活少了些东西。

为了把工作中、业余时学习的东西记录下来，我开始记笔记。为了在网络空间中留下自己的痕迹，我重新开始写博客，认真写博客。

于是我的业余生活中，出现了大量的文本编辑的需求。为了找到一个同时具备文档管理、样式编辑、LaTeX 公式支持、只读模式等等功能的编辑器，我可谓煞费苦心，购买各种 App 的钱就花了不少，前后尝试了 Ulysses、TextNut 等等多款文档管理工具，最后停留在了 Notebooks 这个应用上。

即便我对 Notebooks 做了不少自定义，实现了我想要的所有功能，但是我还是不太满意。

这些工具，没法刺激我的创造欲望。就是这样，这些工具虽然堆砌了各种功能，但是它的核心功能——文本编辑，无法让我满意。

曾经沧海难为水，除却巫山不是云。我十分的怀念当年用 Emacs 写文章写代码的惬意，对这些不成器的应用内编辑器，我想说一句，开源的 Emacs，比你们不知道高到哪里去，我和他谈笑风生！

# 契机 #

虽然我对其他编辑器有着诸多不满，但是我还在欺骗自己，让自己将就用着。毕竟我好歹也是大半年没有用 Emacs 了，不知道还有没有时间重新捡起来。

就在不久前，一篇叫《[一年成为Emacs高手][1]》的文章彻底激起了我重新用起 Emacs 的欲望和信心。

我不能再欺骗自己了，我就是喜欢用 Emacs 写东西的感觉！看完文章当晚，我就把 Emacs 装上了。

# 调教 #

意料之中的是，我当年的配置文件，依旧完整的躺在家目录里。出乎意料的是，这份犹如工程代码一般的配置，无法正确加载。

仔细一想，当年我用的 Emacs 是 23，如今我安装的是 24，配置有些许不兼容也是正常的罢。

也许是受那篇文章的影响，我决定抛弃之前亲自维护的配置工程，然后选择一个干净的配置作为起点，重新来过。事实将会证明，这是一个正确无比的决定。

从 [eschulte/emacs24-starter-kit][2] fork 出一份配置之后，我开始阅读这份配置的[文档][3]。

让我感到惊奇的是，在这份配置中，我们可以像写文档一样去写配置。我们把配置写在 Org 文档中，可以用 Org-mode 提供的标记符去标记文档格式，然后把 elisp 代码写在代码块中。emacs 启动时会解析这些 Org 文档，把其中的 elisp 代码析出为 lisp 代码文件并加载。

这份配置还提供了一种将用户配置和默认配置隔离的方法。文档中有一段文字和代码隐晦地给出了相应方法。

![Emacs Starter Kit](http://ww4.sinaimg.cn/large/e724cbefgw1et29k8bw67j20k30fo41z.jpg)

看出来了吗？我们可以根据系统名称做出针对不同操作系统的配置，也可以根据用户登录名做出针对不同用户的配置，这样我们在自定义编辑器行为的时候就不用去修改默认配置，同时我们需要关心和备份的配置文件就只有用户配置和系统配置了。

这种自定义配置的方式，比起我之前那个维护得像代码工程一样的配置，以及被我这一行那一行修改了的各种插件，简直领先一个时代。

大约花了 2 个小时，我就把 Emacs 调教的十分顺手了。当然需求是不断增加的，我在日常使用的过程中也会根据需要安装新的插件，增加新的配置，让 Emacs 配置和我一起成长。

# 配置 #

我们喜欢把 Emacs 配置成那种带有“启动自检”的模式，在启动过程中，如果发现有插件没有安装，就会自己联网安装。这样假如我们换了一台电脑，只需要把用户配置文件复制一份，Emacs 就会在第一次启动的时候把自己配置好，不需要我们操心太多。

Emacs Starter Kit 提供了一个函数 starter-kit-install-if-needed，用来帮助我们检查一个或多个指定插件是否正确安装。

```lisp
(defun starter-kit-install-if-needed (&rest packages)
  "Install PACKAGES using ELPA if they are not loadable or installed locally."
  (when packages
    (unless package-archive-contents
      (package-refresh-contents))
    (dolist (package packages)
      (unless (or (starter-kit-loadable-p package)
                  (package-installed-p package))
        (package-install package)))))
```

我没有像许多 Emacser 一样使用 Evil 来模拟 Vim，也许是因为我始终没真正学会 Vim 的缘故。

# 插件 #

照例在最后推荐几个有趣的小插件，正是这些插件给我带来了绝妙的编辑体验，让我对 Emacs 念念不忘。

1. highlight-tail 

   这个插件可以用渐变的颜色去高亮最近修改的文本，很酷的感觉。就是这个插件极大的刺激了我的创作欲望，让我不停的写啊写啊。
   
   我把高亮的颜色配置成了红色，适合黑底白字的主题。关于这插件的更多内容可以参考《[用性感的尾巴highlight-tail标记最近的修改][4]》。

2. smartparens

   这个插件能够自动补全成对的符号，比如括号、引号之类的。

3. markdown-mode

   对于重度的 markdown 控，这个主模式必不可少，除了能够提供语法高亮，还有各种快捷键。大学的时候有一段时间我是使用 Org-mode 来写文档的，如今已经很少用了。

4. darkroom

   传说中的沉浸模式，绝妙的文档编辑体验！就像 OS X 上许多主打沉浸模式的 Markdown 编辑器一样，它把文本区域收敛到窗口的中间，让你专注于文字创作。

   ![Darkroom](http://ww4.sinaimg.cn/large/e724cbefgw1et29jaibmlj213l0o2aj2.jpg)
   
   对于我这种有多个显示器的家伙，自然是把 Emacs 全屏之后放在正中央的屏幕上，旁边两个屏幕用来放置浏览器和代码之类的窗口。


[1]: http://blog.binchen.org/posts/yi-nian-cheng-wei-emacs-gao-shou-xiang-shen-yi-yang-shi-yong-bian-ji-qi.html
[2]: https://github.com/eschulte/emacs24-starter-kit
[3]: http://eschulte.github.io/emacs24-starter-kit/
[4]: http://emacser.com/highlight-tail.htm
