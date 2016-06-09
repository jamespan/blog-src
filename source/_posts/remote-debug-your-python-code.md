title: 远程调试你的 Python 代码
tags:
  - Python
  - Debug
categories:
  - Study
hljs: true
cc: true
comments: true
thumbnail: 'https://i.imgur.com/grMb9E1.png'
date: 2016-06-09 16:44:37
---


虽然我之前一直自称「Python 汪」，但是实际上我并没有在生产环境中大规模使用 Python 的经验，更多的是用 Python 来处理日常生活中的数据处理、自动化等需求。

几个月前我加入了一个除了 Java 之外还大量使用 Python、Erlang，少量使用 Golang 的团队，甚至 Python 在团队中的地位要高于 Java。于是我终于成了名副其实的 Python 汪。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

自从我主要使用 Python 进行开发之后，还是很怀念 Java 的，虽然这么说似乎有点像斯德哥尔摩症候群，但是仔细想想并不是那么一回事。之所以怀念，是因为我的生产力相对没有过去用 Java 时那么高了。

说怀念 Java，并不是怀念语言本身，而是怀念一套工具链，一个生态。虽然 Python 有 PyCharm 这个强力的 IDE，在写代码时给我带来的速度提升比起 IntelliJ IDEA 不遑多让，但是在其它方面就力有不逮了。

这次我要说的就是远程调试，Remote Debug。

在 Java 世界里，远程调试就像是水和空气，是一个由 JVM 默认提供，IDE 默认支持的功能。我们只需要在启动 Java 进程的时候带上调试参数，指定调试端口，就可以从自己的机器上调试运行在服务器上的进程了。

如果不考虑端口冲突的话，一般我喜欢开启 8000 端口来远程调试。更多的时候我们会把调试参数放在测试环境的启动脚本中，这样子整个测试集群就处于一个随时可以远程调试的状态。

```
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000
```

Python 可就没有这种福利了，亲儿子 CPython 并不支持远程调试，常见的调试手法是这样的：

1. 结束正在运行的 Python 进程
2. 在代码入口 `import pdb` 然后 `pdb.set_trace()`
3. 在字符界面调试

现在都已经 2016 年了，还让开发者用这么原始的手法去调试，为了调试还要改动代码，真是让人难以置信呢。号称优雅的 Python 在调试面前也是狼狈不堪啊，改代码去调试跟我在代码里打日志调试有什么区别！

当我在 Google 里搜索 python remote debug 的时候，还是有一些收获的。PyCharm 商业版集成了一个叫 PyDev 的库，这个库为 Python 提供了远程调试的功能。但是为了开启远程调试，我们还是需要改动代码，在代码入口处加上类似于 pdb 的引用：

```python
import pydevd
pydevd.settrace(
    '192.168.100.123', 
    port=8000, 
    stdoutToServer=True, 
    stderrToServer=True
)
```

先不说部署远程调试需要改动代码这个不人道的条件，我们就先关注 `settrace` 方法的四个参数。后两个说的是把标准输出和标准错误重定向到调试器，但是这个变量名有点深意啊。 `stdoutToServer`，这个 server 是谁？我远程调试的就是一个 Python Server，它要把 `stdout` 重定向到哪里去？

带着疑问阅读 PyCharm 提供的 Remote Debug 文档之后我发现，这完全和我想象中的 Remote Debug 不一样！

我想要的 Remote Debug 应该是这样的：在服务器上启动的目标进程，除了包含我部署的代码逻辑，还要做为 debug server 去监听一个端口；debugger 访问服务器上目标进程监听的 debug 端口，通过 socket 和 debug server 交互以获取必要的信息和下发调试指令，对用户提供一个友好的图形界面。

然而 PyDev 和 PyCharm 商业版的组合却是这样：PyCharm debugger 自身做为 debug server，监听一个端口；目标进程做为 debug client，访问 PyCharm 上的 debug server 等待指令。

![](https://i.imgur.com/dV6nzKI.png)

如果我们需要调试的只是一台机器上的一个进程，PyCharm 的这种远程调试方法还是能工作的，虽然有点麻烦，比如目标进程启动时会主动连接 PyCharm，如果这时候 PyCharm debug server 没启动，目标进程就会因为网络异常而失败。但是当我们面对的是一个需要调试的集群，这种方式就显得笨拙而难用了。为了调试整个集群，我需要让每台上的每个目标进程都同时连接到我的 PyCharm 上，然后同时开多个调试器。

![](https://i.imgur.com/9n8ZNxp.png)

如果和同事配合调试，还得提前规划好我调试这几个进程，你调试那几个进程，如果我想要调试同事正在调试的进程，就得修改服务器上的代码然后重启进程。

![](https://i.imgur.com/AyeG2FX.png)

这种糟糕的调试体验，光是想想就害怕了。

虽然关于 Python 远程调试的搜索结果里，几乎全是 PyCharm 提供的不合理的方案，但是我还是找到了我想要的东西。微软提供了一个叫做 ptvsd 的库，可以在 https://pypi.python.org/pypi/ptvsd 获取。

微软不知啥时候搞了个黑科技，为 Visual Studio 添加了 Python 支持，然后 Visual Studio 做为「世界上最好的 IDE」，支持科学的远程调试自然是义不容辞，于是就有了这个 pvstd，做为一个 debug server 嵌入到目标 Python 进程中，然后 Visual Studio 做为 debugger，主动连到 debug server 上。

虽然我并不可能使用 Visual Studio 去写 Python，但是这个发现为我打开了新世界的大门。原来除了 PyDev，还有其他的 Remote Debug Library！接下来就是惊喜不断了，除了 Visual Studio 这个重量级的 IDE，微软还搞了一个开源的文本编辑器 Visual Studio Code，它也支持 Python 的远程调试，用的也是 ptvsd。

![](https://i.imgur.com/9dEPTT2.png)

只要我们配置了正确的 site-package 路径，让本地的 Visual Studio Code 能把服务器上正在运行的代码和本地的代码配对，就可以开心的调试了，不仅可以调试自己的代码，还能调试标准库和第三方库。

这样子一来我们即使面对一个需要调试的集群，也可以轻松应对，和同事一起调试也不需要频繁重启目标进程修改代码了~

![](https://i.imgur.com/BONSeTk.png)

虽然我现在开发 Python 的时候还是离不开 PyCharm 的帮助，如果没有 PyCharm，我也许会迷失在一个几十万行代码的 Python 工程中。但是不得不承认，在远程调试这个杀手级特性上，PyCharm 输了。

不过 PyCharm 不是没有完全机会，它可以站在微软的肩膀上，增加一个调试模式，支持 ptvsd 做为 Debug Server，PyCharm 做为 Debug Client 就好 :)

到目前为止，无论用 PyCharm 也好，VS Code 也好，要想在目标 Python 进程上开启调试模式，都是需要修改代码，在入口处添加对调试类库的引用和初始化的。

下一次，我将分享如何在不改动一行系统代码的情况下，实现开启调试、关闭调试。当然，无论如何，重启进程还是需要的，毕竟就连 Java 的远程调试，也需要重启进程才能开启和关闭不是吗？



