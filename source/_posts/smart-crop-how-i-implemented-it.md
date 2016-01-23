title: Smart Crop，一种切除 PDF 扫描文档白边的新选择（工程篇）
tags:
  - Java
  - Python
  - Guice
  - Maven
  - Software
categories:
  - Study
thumbnail: //i.imgur.com/I9fgKqF.png
hljs: true
cc: true
comments: true
date: 2016-01-20 00:11:21
---

周日深夜，我把代码分享到了 Github，用的 MIT 协议，详见 [JamesPan/pdf-smart-crop][1]。原本还想着把注释文档和单元测试写了再分享代码的，后来实在是懒了。所以说啊，这些东西如果开发的时候不好好写，以后就更没有动力去写了。

前作「[Smart Crop，一种切除 PDF 扫描文档白边的新选择（算法篇）][2]」分享了 Smart Crop 的算法设计、基本用法和脑洞，这里分享一下实现过程中遇到的问题和妥协。

<!-- more --><!-- indicate-the-source -->

## Why not Python ##

之前说过我在算法设计和调试阶段用的是 Python，到了工程实现却选择了 Java。为什么没用 Python？

先看一下程序的输入和输出。其实不用看，输入和输出都是 PDF 文档，但是中间步骤是什么呢？

![](//i.imgur.com/3lNydyWl.png)

用 Python 处理 PDF 文档，我们有几个类库可供选择，比如 pyPDF、pdfrw 之类，但是我当时就没找到一个纯 Python 实现的能够把 PDF 文档给一页页渲染成图像的类库。要么就是依赖 ImageMagick，要么就是依赖 poppler，要么就是臣妾做不到啊。

ImageMagick 是一个包罗万有的图像处理工具包，好像是 C 语言写的，主流平台都能安装。但是从软件分发的角度想想，当时我还是想写一个面向大众的软件的，总不能让用户先把 ImageMagick 装上再运行我写的软件吧？

poppler 是一个 C 写的 PDF 类库，很有名，可惜是 C 写的。C/C++ 写的代码就意味着可执行文件不跨平台，我 release 一次就得整出三个平台的可执行程序，对于我这么懒的人来说简直要命。更要命的是我尝试安装 python-poppler-qt4 这个类库居然还失败了！

虽然我深爱着 Python，但最终也不得不放弃，考虑其他语言。

## Why Java ##

Node.js 如何？天生跨平台，写 GUI 有大名鼎鼎的 NW.js，曾经的 Node-Webkit，写 CLI 更是简单到爆。只可惜，NPM 上面找到的能处理 PDF 的类库，无一例外是对 ImageMagick 的包装。

把我引向 Java 的，是一篇来自 reddit 的讨论，[Best current tools for working with PDF files in python?][3]。

最佳答案说，当前用 Python 去完成把 PDF 转成图像这个工作不是一个好想法，Apache PDFBox 大法好。

> Apache keeps their shit updated and documented as well.

既然寻寻觅觅了这许久，最后发现大家都公认，把 PDF 转成图像非 PDFBox 莫属，我也就不用纠结了，直接用 Java 吧，反正 Java 是最好的语言，上能 GUI 下能 CLI 还能写 REST API（逃。

而且 Java 在软件分发的时候也是相对简单的，直接发布一个可执行的 jar 包即可，大不了用 [packr][4] 把 JRE 给一起打包了再分发。

## DI with Guice ##

把一段已经写的差不多的 Python 翻译成 Java，就会深刻体会到两种语言之间的差异是多么的巨大。总之一段百来两百行的 Python 代码，到了 Java 里面就成了错综复杂的接口和实现。

有了接口有了实现，就得面向接口编程，依赖注入顺势登场。有了依赖注入的需求，就需要一个 IoC 容器。之前在工作中写 Java Web 的时候，用的容器自然是 Spring。但是这次我想来点不一样的，之前听说 Google 出品的 Guice 是一个轻量级的 DI 框架，如果这次不试一下，可能就错过机会了。

Guice 的用法还蛮有趣的，从之前研究 Guava 开始我就发现 Google 出品的 Java 类库似乎喜欢用各种奇技淫巧搞 DSL，Guice 自然也不能免俗。

```java
public class CropModule extends AbstractModule {
  @Override
  protected void configure() {
    bind(ImageProcessor.class).to(DefaultImageProcessor.class);
  }
}
```

除去类定义之类的废话代码不看，上面这段代码中唯一有用的那行，不就是一个有趣的 DSL 么，把接口和实现给 bind 到了一起。

在 Spring 中，托管的 Bean 如果不做额外声明，默认都是单例。但是 Guice 不一样，如果需要单例，需要额外注解一下。

```java
@Singleton
public class DefaultImageProcessor implements ImageProcessor {
  ...
}
```

其实让我感觉最大的不同，是最佳实践上的。Guice 推荐在构造函数中注入，而且保证不会注入空指针，而 Spring 推荐在 Setter 中注入，如果没有注入自然就是空指针了。Guice 推荐构造函数仅包内可见，包外需通过 IoC 容器获取实例，无法直接构造对象，而 Spring 似乎没有这种说法。

也许是这种最佳实践和真正的工程实践相互作用，使得使用 Guice 作为 DI 的项目大多是拥有良好模块化设计的基础设施，比如 Elasticsearch；而使用 Spring 最为 DI 的项目大多是金玉其外的企业级项目。

发现 IDEA 的一个关于 Guice 的彩蛋。

![](//i.imgur.com/bstMIX1.png)

左侧的边栏上有三个插头，鼠标点一下就会直接跳转到这个实例被注入的位置！好形象好有趣的样子。

## CLI Framework ##

最开始的时候我是打算写一个能够给大众使用的软件的，最后由于时间关系，等不及写 GUI 了，我就只好写了个 CLI 作为交互界面。

那么问题来了，Java 写 Shell 程序，有什么好用的框架把解析命令行参数、生成 help 内容之类的琐事给包办了么？

当然是有的，而且还不止一个的样子。很早我就知道 Spring 有一个 Spring Shell，这次一番考察之后我还发现了 [Clamshell-Cli][5]。最后选择了 Spring Shell，因为 Clamshell-Cli 那种插件化的架构虽然扩展起来简单，但是用起来似乎有点麻烦，不容易以 fat jar 的形式分发。

Spring Shell 其实蛮好用的，自定义启动 Banner、Prompt 还有历史记录文件之类的都很简单，继承默认实现，覆盖几个关键函数就好了，需要注意的是把这些自定义的 Banner 类注册成 Spring Bean，启动优先级设置为最高。

实现具体的命令，就需要继承 CommandMarker，然后用注解给出指定命令的元数据，比如命令明，帮助信息，各个参数以及参数解释之类的。Spring Shell 会自动采集这些元数据，帮我们处理参数解析、生成 help 之类的杂事。

我在实现 Smart Crop 的命令行工具的时候发现两个有趣的点，在这里分享一下。

第一个是输出处理进度。

大四的时候学过人机交互，教材用的是「人本界面」，依稀记得有一个说法，计算机响应指令要尽可能快，如果是在快不了，要给个进度条让用户知道计算机没死机。

在 CLI 下如何输出进度条呢？我之前并没有这方面的经验，只好 Google 之，最后还是从 StackOverflow 找到了[答案][6]，问题的关键就在于之前一直被我忽视的回车符 `\r`。

还记得刚上大学那会，第一门课程是「计算机科学导论」，授课教师是王建荣教授。至今依然记得王老师当时解释不同平台上文本换行的区别时说，Windows 上的换行 `\r\n` 是回车换行，想象一下打字机，先把打印头推回行首，这叫回车，然后向下移动一行，这叫换行。

当时没有去想更没有去尝试，假如只输出换行不输出回车会是怎样一种结果，就只是记下了 Windows 和 Unix 之间在换行上的差异。当然更多的时候轮不到我们去关心这些细微的差异，底层类库早已处理妥当。

曾经让我自我感觉良好的，是我从一开始就学习最佳实践，然后实践最佳实践，最后得到一套合适的实践。如今想来，一开始就实践最佳实践，固然能够让我少走弯路走得比别人快一步两步，但是也错过了一些弯路上别致的风景。

第二个是版本号。

![](//i.imgur.com/tlogkD5l.png)

就是这个版本号，1.0.1。最开始的时候，我是覆盖了 Spring Shell 的方法，直接返回了一个字符串常量。但是后来我感觉这样不合适。

项目的版本号本来已经在 POM 文件里面定义了一次，为什么还需要在代码里面写一次？且不说一份数据维护在两个地方本身就是个大坑，光是每次升级版本都要记得去修改返回版本号的函数就让人受不了。

有没有方法直接让版本号和 POM 中的版本号一致，或者说在 Java 代码中获取 POM 中的版本号呢？我打算从 Spring Shell 的默认实现开始研究。

```java
public class VersionUtils {
  public static String versionInfo() {
    Package pkg = VersionUtils.class.getPackage();
    String version = null;
    if (pkg != null) {
      version = pkg.getImplementationVersion();
    }
    return (version != null ? version : "Unknown Version");
  }
}
```

上面这段代码就是默认实现中真正工作的代码，居然是通过反射获取包，然后获取包的版本。还有这等黑科技！于是我连忙把覆盖函数删掉，重新运行。

![](//i.imgur.com/jUu1On6l.png)

这个 Unknown Version 是什么鬼啊 (╯°□°）╯︵ ┻━┻ 看起来是反射拿到的版本信息为空了，但是为什么是空呢为什么呢为什么呢？

假如突然没有了 Google，没有了 StackOverflow，我就变成了个不会写代码的渣渣。不过这一次不是在栈溢出找到的[答案][7]。

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-jar-plugin</artifactId>
  <configuration>
    <archive>
      <manifest>
        <addDefaultImplementationEntries>
          true
        </addDefaultImplementationEntries>
      </manifest>
    </archive>
  </configuration>
</plugin>
```

在 build 阶段增加一个 [maven-jar-plugin][8] 插件，然后版本信息就会写入 jar 包的元数据中，然后就能够被 Java 代码反射读取了！

![](//i.imgur.com/Wh0hxBBl.png)

果然不放过任何一个偷懒的机会才能学到更多的新姿势！


[1]: https://github.com/JamesPan/pdf-smart-crop
[2]: https://blog.jamespan.me/2016/01/10/smart-crop-another-pdf-crop-tool/
[3]: https://www.reddit.com/r/Python/comments/2x7yxy/best_current_tools_for_working_with_pdf_files_in/coxwy6s
[4]: https://github.com/libgdx/packr
[5]: https://github.com/vladimirvivien/clamshell-cli
[6]: http://stackoverflow.com/questions/852665/command-line-progress-bar-in-java
[7]: http://blog.soebes.de/blog/2014/01/02/version-information-into-your-appas-with-maven/
[8]: https://maven.apache.org/shared/maven-archiver/examples/manifest.html



