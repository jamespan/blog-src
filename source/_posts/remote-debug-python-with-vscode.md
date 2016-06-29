title: 使用 VS Code 远程调试 Python 程序
tags:
  - Python
  - Debug
  - VS Code
categories:
  - Study
hljs: true
thumbnail: 'https://i.imgur.com/kUawwcXm.png'
cc: true
comments: true
date: 2016-06-30 01:58:58
---

在上一篇文章 [远程调试你的 Python 代码][1] 中，我简单介绍了 Python 世界中的两种远程调试模型：PyCharm 选择的 debugger as debug server 模式和 VS Code 提供的 debugger as debug client 模式，并分享了 PyCharm 的远程调试适用于单体应用，VS Code 的远程调试适用于大规模的分布式应用的观点。

随后有同行来信咨询我具体如何使用 VS Code 来远程调试。由于 [VS Code Python Plugin][2] 的文档并不完善，我只好再写一篇博文来介绍如何使用 VS Code 去远程调试 Python 程序。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

在阅读本文之前，我希望读者不仅要知道如何使用 VS Code 进行简单的文本编辑、目录管理，还要知道如何使用 VS Code 调试本地代码。如果不满足我的期望，阅读一些 VS Code 的文档比如 [Debugging in Visual Studio Code][3] 会很有帮助。

进入正题。

首先为了远程调试，我们需要有一段能长时间执行的 Python 代码，以及必不可少的 Python 虚拟环境。

我在开发机器上创建一套虚拟环境作为演示。

![](https://i.imgur.com/vbiyT5R.png)

```bash
which python
python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"
```

为了获得在 VS Code 配置 Python 开发环境需要的信息，我执行了上述两个命令，分别获取当前虚拟环境下的 Python 解释器路径和 Python 包安装路径。

用 VS Code 打开当前目录。然后在首选项中设置当前 Workspace 的配置，添加上述两个命令的输出，让 VS Code 知道用哪个 Python 解释器，去哪里寻找模块做代码索引和补全提示。

![](https://i.imgur.com/PZKx0YZ.png)
![](https://i.imgur.com/IqZyroV.png)

不必担心记不住配置的 Key，只要正确安装了 Python 插件（ext install python），这些配置 Key 都是有自动补全的。由于我这里没有安装 `Pylint`，只能把 linting 功能关闭了，不然 VS Code 会不胜其烦地提醒我安装 linter。

我们这里说的是远程调试，那么我就需要在别的机器上把我要调试的 Python 进程启动起来。正好我手上有一台闲置的 ThinkPad，前些日子被我装了 Neon 这个发行版来体验最新的 KDE，正好可以给我拿来当做 Remote Server。如果你手上没那么多闲置机器，那么用 Docker 或者虚拟机来启动个进程也是可以的，注意做好端口映射也就问题不大。

![](https://i.imgur.com/zjr3Poo.png)

暴露写作时间系列。从上图可以看到许多关键信息，比如代码部署的位置，虚拟环境部署的位置，服务器的 IP 等等……注意到我在代码最开始的地方就设置了 ptvsd 的调试模式。

代码在远程部署好了，但是还没启动，现在让我们回到 VS Code。嗯，进入调试视图（Debug View），初始化或者打开调试配置（Launch Configurations）。如果之前没为当前的 Workspace 创建过调试配置，那么 VS Code 的 Python 插件会从模板帮我们初始化出四种不同的调试配置。但是那些都没什么用，都是为本地调试准备的（本地调试的话有必要用 VS Code 么，PyCharm 多好），都可以删掉，换成下面这段：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Remote",
            "type": "python",
            "request": "attach",
            "host": "192.168.2.113",
            "port": 8000,
            "localRoot": "${workspaceRoot}",
            "remoteRoot": "/tmp/py-remote-debug-example"
        }
    ]
}
```

这里面有几个需要根据实际情况修改的参数，比如 `host` 要写目标进程所在的主机，`port` 要写目标进程里面初始化 `ptvsd` 时监听的调试端口，`remoteRoot` 要写远程主机上代码部署的位置的绝对路径，这样 VS Code 才能把本地代码文件和远程代码文件匹配起来。

由于 VS Code Python Plugin 的[文档][4]中没有明确给出远程调试的配置方式，我也是翻了它的[代码][5]才最终确定的，虽然在翻代码之前就在自动补全的帮助下瞎蒙出来了。

VS Code 的配置到这里就基本上告一段落了。接下来就是在服务器上启动进程，然后在 VS Code 里启动调试，然后装模作样地下断点，在断点附近对表达式求值……

![](https://i.imgur.com/jhOMOfd.png)

So far so good. 那么问题来了，如果我不仅仅要调试项目中的代码，我还要调试安装到虚拟环境中的第三方库，能做到吗？比如我要单步进入 `requests.get` 方法。于是我进入 get 方法，下了断点，然后点下绿色的三角按钮，等待奇迹发生。

然而奇迹并没有发生。

![](https://i.imgur.com/m97dsi7.png)

VS Code 说它找不到代码。Source /private/home/panjiabang/.virtualenvs/remote-debug/lib/python2.7/site-packages/requests/api.py is not available.

虽然不知道为啥 VS Code 会去 `/private` 这个 OS X 不知道跟谁学来的目录里找东西，但是我的直觉告诉我，这一定是远程机器上的第三方库的绝对路径和本地机器路径不一致造成的。ptvsd 作为调试服务器，肯定不知道客户端的三方库在哪也不需要知道，老老实实把服务器上三方库的路径给到 debugger，结果 VS Code Python 插件里的 debugger 也傻傻的不知道做个转换，直接就拿远程的路径到本地去找代码，找得到才怪了。

这明显是 VS Code Python 插件的设计缺陷啊，好歹提供一个配置，做个 `site-package` 目录的映射什么的，而且不能是 1:1 的映射，得是 m:n 的映射，因为 Python 找模块时用的 `sys.path` 还是有不少的。不过考虑到我们在部署的时候，实际上会把所有的依赖都打包在虚拟环境的 `site-package` 目录下，所以大多数场景下，只要映射远程的 `site-package` 和本地的 `site-package` 就妥妥的够用了。在没有官方的解决方案之前，我只好将就一下，在本地做个软链，让 VS Code 能用远程的路径在本地找到代码。

![](https://i.imgur.com/hyffLty.png)

可算是断点到 requests 里头了，真不容易😂

不得不说，作为一个图形化调试器，VS Code 做得还是很不错，基本上现代调试器该有的功能都有了，比如鼠标悬停在变量上方就显示变量的值，选中变量后右键功能支持求值、观察等等，比起 PyCharm 之流不遑多让。但是作为一个 IDE 还是太弱了，虽然支持 linting，但是检查出来的 warning 不支持自动修复，局部变量重命名居然会漏掉几处，无法分析类间关系、函数覆盖……

因为 VS Code 支持 Python 远程调试的缘故，我近期越来越多地使用它，也渐渐发现一些痛点，这些痛点让我一直无法完全信赖 VS Code。最大的痛点就是文本替换的时候不支持多行正则（<https://github.com/Microsoft/vscode/issues/313>，今天很高兴发现这个 issue 已经有相关的 commit 了，估计会在 7 月的新版本中支持，到时候我就能完全抛弃 Sublime Text 了吧）。

如果我还有闲暇时间，或许会尝试给 VS Code Python Plugin 加上 `site-package` 目录映射什么的。不过我更想要做的，是给 PyCharm 写一个 Remote Debug 的插件，配合 ptvsd 实现远程调试，毕竟 PyCharm 是更加靠谱的 Python IDE。文本编辑器嘛，用来写写博客，敲点简单的代码片段就挺好，复杂的项目还是交给更专业的程序去帮我节约时间。

[1]: https://blog.jamespan.me/2016/06/09/remote-debug-your-python-code/
[2]: https://marketplace.visualstudio.com/items?itemName=donjayamanne.python
[3]: https://code.visualstudio.com/Docs/editor/debugging
[4]: https://github.com/DonJayamanne/pythonVSCode/wiki/Debugging
[5]: https://github.com/DonJayamanne/pythonVSCode/blob/351a6e52f14345c18cfd3be39e842b86b32a3bd4/src/client/debugger/Common/Contracts.ts#L58-L65


