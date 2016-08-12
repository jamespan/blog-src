title: 捕获 Linux 图形化登陆界面的截图
tags:
  - Linux
categories:
  - Study
thumbnail: 'https://ws1.sinaimg.cn/large/e724cbefgw1ewng5svd8sj20b604rgm2.jpg'
hljs: true
cc: true
comments: true
date: 2015-10-03 04:28:06
---


在上一篇博客「[重返 Linux 世界][1]」中，我说 Linux Mint 17.2 的登陆界面比之前的要好看不少。作为佐证，我贴了一张 Linux Mint 登陆界面的截图。

在日常使用中，我们的截图操作都是在登陆系统之后进行的，比如捕获一个窗口，捕获指定区域，或者捕获整个网页。要给登陆界面截图，那是在登陆之前就要做的操作，这可难倒我了。

<!-- more --><!-- indicate-the-source -->

之前没有这样的截图需求，这次不妨各种手段都拿来尝试一下。

首先想到的是延时截图，比如在 kscreenshot 设置 10s 之后截图，然后在截图之前完成切换用户并进入登陆界面的操作。结果是残酷的，截出来的图是黑屏。

GUI 的截图解决方案不可用，我只好求助于 CLI。scrot 是一个大名鼎鼎的命令行截图工具，支持延时截图。我将延时截图故伎重演，结果依然黑屏。

常规武器已然用尽，敌人却依旧活蹦乱跳，这让我情何以堪。

一番 Google 之后，发现一些线索，这个问题老早就有人提问了[^1]。

[^1]: [How can I take a screenshot of the login screen?][2]

我参考的是 Parto 的[回答][3]，然后他的回答又是参考的别人家的博客[^2]。

[^2]: [How To Take Screenshot Of Login Screen In Ubuntu 14.04][4]

本来应该轻而易举就搞定的，结果却因为手残，脚本中少写了一些东西而折腾了半天。最终在 root 权限下面用这些命令捕获了登录界面的截图。

```bash
chvt 8
sleep 5
DISPLAY=:0.0 XAUTHORITY=/var/lib/mdm/:0.Xauth xwd -root > /tmp/shot.xwd
convert /tmp/shot.xwd /tmp/ss.png
```

这些命令最关键的地方，是第三行的 `XAUTHORITY=/var/lib/mdm/`。不同的发行版，默认会使用不同的登录管理器，比如 Ubuntu 用的是 lightdm，Kubuntu 用的是 kdm，Linux Mint 用的是 mdm，以 Gnome 为桌面环境的发行版用的是 gdm。

不同的登录管理器，对应的 XAUTHORITY 也就不一样。所以网上找到的资料中，有的是 `XAUTHORITY=/var/run/lightdm/root/`，有的是 `XAUTHORITY=/var/lib/gdm/`。那么问题来了，我们该如何确定当前的系统用的到底是哪个登录管理器？

当然不能拍脑袋，要有理有据。一开始的时候我习惯性的以为我在用的 dm 是 kdm，结果就掉到坑里了。

![](https://ws2.sinaimg.cn/large/e724cbefgw1ewng2bql7tj20ro0dk76x.jpg)

其实很简单，只需要把名字中包含 dm 的进程捞出来看一眼，就能确定命令该怎么写了。

最后，美图共赏~

![](https://ws1.sinaimg.cn/mw1024/e724cbefgw1ewnb8odazkj211y0lcdz0.jpg)

[1]: http://blog.jamespan.me/2015/10/03/free-as-in-freedom/
[2]: http://askubuntu.com/questions/43458/how-can-i-take-a-screenshot-of-the-login-screen
[3]: http://askubuntu.com/a/607095
[4]: http://itsfoss.com/screenshot-login-screen-ubuntu-linux/



