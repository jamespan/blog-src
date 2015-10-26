title: 借助 AOP 为 Java Web 应用记录性能数据
tags:
  - Java
  - Tool
categories:
  - Study
cc: true
hljs: true
comments: true
date: 2015-08-31 01:40:26
---

作为开发者，应用的性能始终是我们最感兴趣的话题之一。然而，不是所有的开发者都对自己维护的应用的性能有所了解，更别说快速定位性能瓶颈并实施解决方案了。

今年北京 Velocity 的赞助商大多从事 APM 领域，提供性能剖析、可视化甚至优化的解决方案。这些厂商的产品看起来能够很好地帮助中小企业的开发者解决应用性能上的缺陷，但是这些产品几乎都有着一个致命的缺陷：极强的侵入性。

<!-- more -->

开发者需要在业务生产代码中嵌入 APM 厂商提供的埋点代码，才能够使用 APM 厂商提供的 Saas 服务。在瞬息万变的技术大潮中，这种代码级别的侵入和绑定，总是让开发者忧心忡忡。如果我作为架构师，在自建 APM 还是使用 Saas APM 上，我也会谨慎考虑。

然而无论自建 APM 还是使用 Saas 服务，其底层模型无非就是海量日志的实时处理，数据来源就是应用产生的性能日志了。

{% blockquote Jim Barksdale %}
If we have data, let’s look at data. If all we have are opinions, let’s go with mine.
{% endblockquote %}

这是一个数据为王的时代，夸张一点说，数据可以指导一切！

言归正传，如果我们不希望使用 APM 尝试提供的强侵入的服务，我们就只能自建服务了，比如以 AOP 的方式采集线程内调用树以及调用开销并输出日志，然后使用 ELK(Elasticsearch, Logstash, and Kibana) 去采集日志并提供搜索、可视化等功能。如果采集的日志仅作为离线计算使用，可以直接用 Flume 把日志写入 HDFS。

随着系统流量越来越大，上述的方案渐渐就扛不住了，然后就需要自己实现高性能的日志采集 Agent，把采集到的日志一股脑写入 Kafka 之类的能扛大量堆积消息的 MQ 里面，然后使用 Storm/JStorm 做实时的流式计算。

前些日子我简单搞了一个基于 AOP 来抓取调用树和开销的尝试，感觉有点意思，分享一下。

# 抓取调用树和时间开销 #

在 Java 里面获取代码块的时间开销最常见的手段就是 `System.currentTimeMillis()`。Apache 和 Guava 等流行类库都有对获取时间开销这一功能的封装类 StopWatch。

捕获调用树就没有什么常见的封装了。一种推荐的做法，是在一次调用中，给每个要剖析的代码块一个唯一的标记，这个标记要能够体现代码块之间的嵌套、顺序等关系。

举个栗子，我们有如下调用关系。

```nohighlight
func1
+- func2
|  +- func3
|  \- func4
\- func5
```

为了体现调用之间的嵌套和顺序，我们给 func1 标记 0，给 func2 标记 0.1，给 func3 标记 0.1.1，给 func4 标记 0.1.2，给 func5 标记 0.2。如此一来，我们便能够轻易地根据标记重建出调用树。

我们可以把调用树的抓取和记录每个代码块的时间开销的功能以线程安全的手法封装起来，给这个封装起一个类似于 Profiler 的名字。Profiler 提供 2 个静态方法，enter 在进入代码块之前调用，exit 在代码块结束之后调用。

在实现 Profiler 的时候，需要给每个线程维护一个调用栈，以及剖析结果列表。基本上可以实现为 enter 压栈，exit 退栈并把结果放入结果列表，当调用栈退空后，输出完整的剖析结果。

# AOP 与方法拦截器 #

Profiler 有一个需要严格执行的约定，就是 enter 和 exit 必须成对调用，就像 C++ 里面 new 和 delete 必须成对出现一样，否则内存会被直接打爆，远不是内存泄露这么简单。

这种约定如果写到业务代码中，会死的很难看，各种 try finally 硬生生的把业务逻辑打断，本来业务代码就已经很恶心了，这么一搞简直没法维护。

所以我们需要一种比较科学的方式，以无入侵的方式实现对 Profiler 的正确调用。AOP 是一种合适的工具。

这里以 Spring AOP 为例，实现一个简单的例子。

首先引入 Spring AOP 的依赖，或者包含 org.aopalliance.intercept.MethodInterceptor 的包。

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-aop</artifactId>
    <version>2.5.6</version>
</dependency>
```

如果需要代码能够运行，还需要引入 cglib 的依赖。

```xml
<dependency>
    <groupId>cglib</groupId>
    <artifactId>cglib-nodep</artifactId>
    <version>2.2</version>
</dependency>
```

方法拦截器的参考实现如下，使用 try finally 这样的 code pattern 去保证 Profiler 被正确使用。

```java
public class Interceptor implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation invocation) throws Throwable {
        Class clazz = invocation.getMethod().getDeclaringClass();
        String method = invocation.getMethod().getName();
        String mark = clazz.getCanonicalName() + "#" + method;
        Profiler.enter(mark);
        try {
            return invocation.proceed();
        } finally {
            String log = Profiler.exit();
            if (log != null) {
                System.out.println(log);
            }
        }
    }
}
```


