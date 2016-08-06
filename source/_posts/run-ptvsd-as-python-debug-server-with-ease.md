title: 如何为 Python 添加远程调试能力而不修改系统代码
tags:
  - Python
  - Debug
categories:
  - Study
thumbnail: https://i.imgur.com/UkdCgeL.gif
cc: true
comments: true
date: 2016-08-07 01:20:13
---


最近写了一些关于 Python 远程调试的扯淡向博文，第一篇是「[远程调试你的 Python 代码][1]」，第二篇是「[使用 VS Code 远程调试 Python 程序][2]」。前些日子开了一个叫做「第八个手艺人」的微信公众号，本想混个原创，骗点零花钱，于是把这些文章首发在公众号上了。可惜微信始终不给我原创标记，微信文章的阅读量也上不去，我也就渐渐失去了玩公众号兴致。

后来看到耗子叔的新博文「[为什么我不在微信公众号上写文章][3]」，想想自己写博客的初心，果然还是不要整公众号这些幺蛾子了，回到我的博客，回到我这个可以被 Google 爬取、索引，被同行轻易搜索到的博客。

<!-- more --><!-- indicate-the-source -->
{% recruit %}

我所热爱的互联网，是一个开放、共享的互联网，而不是现在这样一个个围墙越来越高的花园。

晚上看到有同行在我的博文「[远程调试你的 Python 代码][1]」下面留言，希望得知我在文末挖下的坑该如何去填。

当时我没有立刻回复，于是就有了这篇博文。下面进入正题，如何在不改动一行系统代码的情况下，实现 Python 应用的开启调试和关闭调试。这篇博文里我不会给出实现代码，因为读者知道了实现原理之后，自己动手实现一下，也许就是几十分钟的事情。需要强调的是，这里的「系统代码」，其实是「业务系统代码」的意思，也就是我们维护的应用的代码。

我们知道，要想使用 ptvsd 为 Python 服务器开启远程调试功能，需要在代码的入口处 `import ptvsd`，并调用 `ptvsd.settrace` 方法启动 debug server。具体用法见「[使用 VS Code 远程调试 Python 程序][2]」，当时我是在代码中硬编码了对 ptvsd 的调用。我们这里需要做的，就是将这种硬编码的调用，从业务代码中剥离。

先理一下需求：

1. 在业务代码启动之前，完成对 ptvsd 的调用
2. 对 ptvsd 的调用，不出现在业务系统的代码中

在 Python 中，是否能做到在执行一个 py 文件之前，先执行一点别的代码呢？如果可以，那么我们就能把对 ptvsd 的调用，作为这「一点别的代码」了。

答案是肯定的。与此相关的知识点是 [sitecustomize.py][4]。

> After these path manipulations, an attempt is made to import a module named sitecustomize, which can perform arbitrary site-specific customizations. It is typically created by a system administrator in the site-packages directory. If this import fails with an ImportError exception, it is silently ignored. If Python is started without output streams available, as with pythonw.exe on Windows (which is used by default to start IDLE), attempted output from sitecustomize is ignored. Any exception other than ImportError causes a silent and perhaps mysterious failure of the process.

上面这段文档来自 Python 标准库的 [site][5] 模块，勉强算是解释了 sitecustomize 的用途，以及加载时机。反正基本上只要知道当我们执行 `python a.py` 时，`sitecustomize.py` 的代码会在 Python 解释器启动之后，py 文件执行之前执行就好了。也正因为这样子，我们把 ptvsd 放到 sitecustomize.py 中调用之后，千万千万要注意以下几点：

1. 不要抛异常，以免影响 py 文件的正常执行
2. 不要输出任何内容到 stdout，以免影响程序之间的交互
3. 在同一个环境中启动多个 Python 进程的时候，要注意 debug 端口的分配，以及端口重复时的容错和提示
4. 其它我没想到但是会影响预期行为的点

关于 1，我们可以通过一个巨大的 `try catch`，把所有异常吞掉，然后输出异常信息到日志文件或者 stderr，这样子就避免了我们在 sitecustomize.py 里不小心写出的 bug 影响到目标 py 文件的执行。毕竟 debug 开启不了事小，文件执行不了事大。

关于 2，我是曾经掉到坑里的。VS Code 的 Python 插件，是调用 Python 解释器去实现智能提示功能的，早些时候我修改了 sitecustomize.py，将一些信息输出到了 stdout，导致 VS Code 的 Python 智能提示全废了，排查这个问题费了一番功夫。

关于 3，我们可能需要引入一些稍复杂的方法，需要写几十行代码。打个比方，我们要从同一个虚拟环境中启动两个服务器进程，那么我们需要为这两个进程分配不同的调试端口。一种可行的方式是使用配置，比如用 ConfigParser 解析一个 ini 文件，从 ini 中读取到为指定进程名称配置的调试端口， 以及是否开启调试等信息，然后用 psutil 或者类似的类库，获取当前进程信息，和配置信息做个比对之后，决定当前进程是否需要开启调试，调试端口号是多少。

然后我们在开发或者集成环境中部署远程调试的时候，只需要把这个万年不变的 sitecustomize.py、根据不同环境稍作修改的 ini 文件推到目标机器的虚拟环境中就好，Python 应用的代码无需为了远程调试做任何修改。

基本上就是这样子了，摊开来说也没啥稀奇的，无非就是 sitecustomize.py 这个钩子而已，希望对读者有所启发。

Happy hacking!

[1]: https://blog.jamespan.me/2016/06/09/remote-debug-your-python-code/
[2]: https://blog.jamespan.me/2016/06/30/remote-debug-python-with-vscode/
[3]: http://coolshell.cn/articles/17391.html
[4]: https://www.google.com.hk/#q=python+sitecustomize.py
[5]: https://docs.python.org/2/library/site.html
