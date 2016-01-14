title: "Java 编译期代码生成遭遇 Maven 增量编译"
date: 2015-05-06 23:59:08
tags:
  - Java
  - Maven
  - Meta-programing
categories:
  - Work
hljs: true
cc: true
comments: true
---


春节期间我弄了一个东西，我把它叫做“黑科技”，用到了编译期代码生成技术。Demo 做出来之后我很是开心了一段时间，因为它在性能上能够把现有的参考实现甩几条街，毕竟原生代码的性能比反射不知道高到哪里去，而参考实现恰恰是用反射实现的。虽然我的实现在扩展性上比参考实现弱了一些，而且写代码的时候 IDEA 总是不识相的报告找不到类定义……IDEA 找不到类的话，我只要执行编译把代码生成出来就好了，扩展性后面我会搞定的。

这几天我在做项目的时候，花了几个小时把这个黑科技从我的 Demo 项目迁移到了生产代码中，然后做了大量的改进。

<!-- more --><!-- indicate-the-source -->

<!-- <img src="http://ww1.sinaimg.cn/small/e724cbefgw1eruyt2uc4fj20rs0rsdhi.jpg"/> -->

这几天写代码的姿势跟之前完全不同，之前是写一点提交一点，然后到服务器上部署起来调试。前段时间我在 Docker 弄了一套淘系应用的编译部署环境，然后这几天我的代码都是在容器里编译部署的，直到今天下午才申请了一个项目环境出来。

故事是从编译失败开始的。

# 困局 #

我把代码签入之后，在开始在项目环境部署代码。因为之前我已经在容器中多次编译部署，这次只不过是换了个环境，想必问题不大。过了一会再看，居然编译失败了！！！

在我的机器上明明是好的！Docker 真是个伟大的产品，要是能直接把我本地的容器扔服务器上该多好。现实很残酷，我必须解决问题。仔细看了看错误日志，是一个熟悉的错误：

```
[INFO] [compiler:compile {execution: default-compile}]
[INFO] Changes detected - recompiling the module!
[INFO] -------------------------------------------------------------
[ERROR] COMPILATION ERROR : 
[INFO] -------------------------------------------------------------
[ERROR] xxxxxx.java:[4,8] duplicate class: com.taobao.xxxx
[ERROR] xxxxxx.java:[4,8] duplicate class: com.taobao.xxxx
[INFO] 2 errors 
```

这个异常信息是我刚开始开发黑科技的时候经常遇到的，就是在编译的时候重复生成了相同的类，然后这个错误就出现了。

自从我把 Demo 开发出来之后，就再也没有出现这个错误了，这次出现是什么原因，或者在不知道原因的情况下我该怎么搞定它？

# 抓瞎 #

首先我试着编译代码，确认本地不会出现这种情况。

```
mvn clean install -DskipTests
```

一切正常。不信邪的我连续在页面上点了好几次编译部署，错误依旧。

一时间无计可施，只好瞎折腾，这里改改那里改改，把这个异常吞掉，把那段代码注释……图灵大人曾经说过，不动脑子乱改代码是解决不了问题的。果然，改了半天还是没有结果。

心情越来越沉重，如果搞不定这个问题，我的黑科技就只能是个玩具，然后我就不得不在生产代码里人肉编写大量枯燥无味的代码。

高德纳为你关上了一扇门，也会为你打开一扇窗。我开始从复现编译错误这条路上下工夫。仔细对比了我本地编译的日志和编译服务器输出的日志之后发现，我本地的编译任务总是 clean compile，而编译服务器的编译任务总是 compile。

会不会这个 clean 任务就成了问题的关键？

# 参数 #

先执行 clean 清理一下，然后连续执行两次 compile，错误粗线了，和编译服务器显示的一模一样！

居然是因为上次编译产生的代码，在这次编译之前没有清理，导致第二次编译的时候产生了一样的类，于是遭遇 duplicate class。

好吧，虽然我能重现问题了，而且我还知道是因为增量编译导致的问题，但是问题该怎么解决，我还是丝毫没有头绪。虽然明知道是编译脚本有缺陷，如果编译命令中带有 clean 就妥妥的不会有问题了。但是这是目前标准的编译脚本，人家才不会为了我一个小小的黑科技修改集团通用的脚本呢。

我又要开始面向 Google 和 StackOverflow 的程序设计了。一番搜索之后，我发现了 Maven 编译插件 maven-compiler-plugin 有一个参数，似乎能帮我解决问题[^1]。

[^1]: [Maven compiler recompile all files instead modified][1]

这个参数就是 useIncrementalCompilation[^2]。

[^2]: [Apache Maven Compiler Plugin – compiler:compile][2]

配置如下：

```xml
<plugin>
    <artifactId>maven-compiler-plugin</artifactId>
    <configuration>
        <source>1.7</source>
        <target>1.7</target>
        <encoding>UTF-8</encoding>
        <useIncrementalCompilation>false</useIncrementalCompilation>
    </configuration>
</plugin>
```

搞定！遗憾的是，每个要用我的黑科技的模块，都得在 pom 里面加上这个参数配置了。

用 Maven 的时候带上 clean 是个好习惯！

[1]: http://stackoverflow.com/questions/16963012/maven-compiler-recompile-all-files-instead-modified
[2]: http://maven.apache.org/plugins/maven-compiler-plugin/compile-mojo.html#useIncrementalCompilation
