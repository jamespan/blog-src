title: 七周七并发模型之线程与锁
tags:
  - Concurrency
  - Java
categories:
  - Study
cc: true
comments: true
date: 2015-04-06 23:52:07
---

# 前言 #

最近我在读 *[Seven Concurrency Models in Seven Weeks][1]*，这本书使用不同的语言介绍不同的并发模型，深入浅出，让我获益匪浅。

这本书让人有一种 Talk is cheap, show me the code 的感觉。作者不会巴拉巴拉讲一大堆理论，而是先放出一段代码，然后引导读者去分析代码里面的问题，然后作出改进，然后再分析还有什么问题。这种风格适合那些真正要写代码的读者。

这本书的中文译本《[七周七并发模型][2]》于 2015 年的愚人节上架，[亚马逊][3]等多家在线商城有售。感谢黄炎先生的翻译工作，让更多国内同行能够接触到这本书。

<!-- more --><!-- indicate-the-source -->

# 线程与锁 #

线程与锁是本书在第一周介绍的内容。作者将线程-锁编程模型比作福特T型轿车，虽然它能把你带到目的地，但这是一种上古时期的技术，难以驾驭，和其他新技术相比，显得更加危险和不可靠。

然而，线程-锁编程模型在大多数时候依然是开发并发程序的首选，也是其他许许多多并发模型的基础。即使我们不打算直接使用它，也得知晓其中原理。

作者以 Java 语言为载体，为我们介绍了线程与锁的工作方式，原理性的知识适用于其他所有支持线程和锁的语言。

# 脑图 #

![线程与锁](http://ww1.sinaimg.cn/large/e724cbefgw1exdxm6pb8uj21b60kgwk5.jpg)


[1]: http://book.douban.com/subject/25736606/
[2]: http://book.douban.com/subject/26337939/
[3]: http://www.amazon.cn/dp/B00V4B2KEI/
