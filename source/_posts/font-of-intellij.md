title: 修复 IntelliJ IDEA 14 的字体渲染
tags:
  - Tool
  - OS X
categories:
  - Work
cc: true
comments: true
date: 2015-01-16 12:39:24
thumbnail: https://ws2.sinaimg.cn/small/e724cbefgw1et29qkfz7lj20b408cjsn.jpg
---

# 背景

我现在使用 [IntelliJ IDEA][1] 在 Mac 下进行 Java 开发。之前一直都是从官网下载的 IDEA，用的 14.0，今天突然想换成使用 [Homebrew Cask][2] 来管理。于是我就用 `brew cask` 安装了一个 14.0.2。

# 疑团

安装完成之后运行，感觉界面怪怪的，和之前从官网下载的不一样。

仔细一看，是字体渲染的问题。联想起之前在 Stack Overflow 看到过[讨论][3]说 Mac 下只有 Apple 维护的 [JDK 6][4] 才能比较好的在 Retina 分辨率下渲染程序界面。其实我之前从官网下载的 IDEA 用的就是 Apple 的 JDK 6，界面渲染的好好的，为什么从 Cask 下载的 IDEA 出了渲染问题？

<!-- more --><!-- indicate-the-source -->

{% recruit %}

# 尝试

一定是我打开的方式不对。先看看 Cask 版 IDEA 运行时用的哪个 JDK 。打开 About IntelliJ IDEA 瞅瞅，果然都是 JDK 7 惹的祸。

![IDEA with JDK 7](https://ws2.sinaimg.cn/large/e724cbefgw1et29qkfz7lj20b408cjsn.jpg)

那么问题来了，为什么官网的 IDEA 用的是 JDK 6，从 Cask 下载的用的却是 JDK 7 ？明明 Cask 也是从官网下载的。

于是我打算对比两个版本的 IDEA 的 plist 文件。plist 文件可以认为是 OS X 下 GUI 程序的参数配置，相当于 CLI 程序的配置文件，比如 bash 的 .bashrc，zsh 的 .zshrc。

# 解决

这两个版本之间的 plist 文件差异好大，但是我发现了一个值得注意的地方。

14.0 版本中，`JVMVersion` 这个键，对应的值为 `1.6*`，到了14.0.2 版本中，却变成了 `1.6+`。

莫非这就是问题的关键？修改试试。

修改之后启动 IDEA，看起来问题解决了！

![IDEA with JDK 6](https://ws1.sinaimg.cn/large/e724cbefgw1et29ry1qd2j20b408c75w.jpg)

打开代码一看，字体渲染又和之前的一样，萌！萌！哒！


[1]: https://www.jetbrains.com/idea/
[2]: http://caskroom.io/
[3]: http://stackoverflow.com/questions/15181079/apple-retina-display-support-in-java-jdk-1-7-for-awt-swing
[4]: http://support.apple.com/kb/DL1572
