title: 流量控制与令牌桶算法
tags:
  - Algorithm
  - Java
  - Guava
categories:
  - Study
cc: true
hljs: true
thumbnail: https://ws2.sinaimg.cn/small/e724cbefgw1ex5tfr4r5bj20n90k8wfz.jpg
comments: true
date: 2015-10-19 01:42:03
---

一年一度的「双 11」又要到了，阿里的码农们进入了一年中最辛苦的时光。各种容量评估、压测、扩容让我们忙得不可开交。洛阳亲友如相问，就说我搞双十一。

如何让系统在汹涌澎湃的流量面前谈笑风生？我们的策略是不要让系统超负荷工作。如果现有的系统扛不住业务目标怎么办？加机器！机器不够怎么办？业务降级，系统限流！

正所谓「他强任他强，清风拂山岗；他横任他横，明月照大江」，降级和限流是大促保障中必不可少的神兵利器，丢卒保车，以暂停边缘业务为代价保障核心业务的资源，以系统不被突发流量压挂为第一要务。

<!-- more --><!-- indicate-the-source -->

集团的中间件有一个不错的单机限流框架，支持两种限流模式：控制速率和控制并发。限流这种东西，应该是来源于网络里面的「流量整型」，通过控制数据包的传输速率和时机，来实现一些性能、服务质量方面的东西。[令牌桶][2]是一种常见的流控算法，属于控制速率类型的。控制并发则相对要常见的多，比如操作系统里的「信号量」就是一种控制并发的方式。

![](https://ws4.sinaimg.cn/large/e724cbefgw1ex4rw20h6bg20dy08mmwy.gif)

在 Wikipedia 上，令牌桶算法是这么描述的：

1. 每秒会有 r 个令牌放入桶中，或者说，每过 1/r 秒桶中增加一个令牌
2. 桶中最多存放 b 个令牌，如果桶满了，新放入的令牌会被丢弃
3. 当一个 n 字节的数据包到达时，消耗 n 个令牌，然后发送该数据包
4. 如果桶中可用令牌小于 n，则该数据包将被缓存或丢弃

令牌桶控制的是一个时间窗口内的通过的数据量，在 API 层面我们常说的 QPS、TPS，正好是一个时间窗口内的请求量或者事务量，只不过时间窗口限定在 1s 罢了。

现实世界的网络工程中使用的令牌桶，比概念图中的自然是复杂了许多，「令牌桶」的数量也不是一个而是两个，简单的算法描述可用参考中兴的期刊[^1]或者 RFC。

[^1]: [QoS技术中令牌桶算法实现方式比较][1]

假如项目使用 Java 语言，我们可以轻松地借助 Guava 的 [RateLimiter][3] 来实现基于令牌桶的流控。RateLimiter 令牌桶算法的单桶实现，也许是因为在 Web 应用层面单桶实现就够用了，双筒实现就属于过度设计。

RateLimiter 对简单的令牌桶算法做了一些工程上的优化，具体的实现是 SmoothBursty。需要注意的是，RateLimiter 的另一个实现 SmoothWarmingUp，就不是令牌桶了，而是漏桶算法。也许是出于简单起见，RateLimiter 中的时间窗口能且仅能为 1s，如果想搞其他时间单位的限流，只能另外造轮子。

[SmoothBursty][4] 积极响应李克强总理的号召，上个月的流量没用完，可以挪到下个月用。其实就是 SmoothBursty 有一个可以放 N 个时间窗口产生的令牌的桶，系统空闲的时候令牌就一直攒着，最好情况下可以扛 N 倍于限流值的高峰而不影响后续请求。如果不想像三峡大坝一样能扛千年一遇的洪水，可以把 N 设置为 1，这样就只屯一个时间窗口的令牌。

RateLimiter 有一个有趣的特性是「前人挖坑后人跳」，也就是说 RateLimiter 允许某次请求拿走超出剩余令牌数的令牌，但是下一次请求将为此付出代价，一直等到令牌亏空补上，并且桶中有足够本次请求使用的令牌为止[^2]。这里面就涉及到一个权衡，是让前一次请求干等到令牌够用才走掉呢，还是让它先走掉后面的请求等一等呢？Guava 的设计者选择的是后者，先把眼前的活干了，后面的事后面再说。

[^2]: [How is the RateLimiter designed, and why?][5]

当我们要实现一个基于速率的单机流控框架的时候，RateLimiter 是一个完善的核心组件，就仿佛 Linux 内核对 GNU 操作系统那样重要。但是我们还需要其他的一些东西才能把一个流控框架跑起来，比如一个通用的 API，一个拦截器，一个在线配置流控阈值的后台等等。

下面随便写了一个简单的流控框架 API，至于拦截器和后台就懒得写了，有时间再自己造一套中间件的轮子吧~

```java
public class TrafficShaper {

    public static class RateLimitException extends Exception {

        private static final long serialVersionUID = 1L;

        private String resource;

        public String getResource() {
            return resource;
        }

        public RateLimitException(String resource) {
            super(resource + " should not be visited so frequently");
            this.resource = resource;
        }

        @Override
        public synchronized Throwable fillInStackTrace() {
            return this;
        }
    }

    private static final ConcurrentMap<String, RateLimiter>
            resourceLimiterMap = Maps.newConcurrentMap();

    public static void updateResourceQps(String resource, double qps) {
        RateLimiter limiter = resourceLimiterMap.get(resource);
        if (limiter == null) {
            limiter = RateLimiter.create(qps);
            RateLimiter putByOtherThread
                    = resourceLimiterMap.putIfAbsent(resource, limiter);
            if (putByOtherThread != null) {
                limiter = putByOtherThread;
            }
        }
        limiter.setRate(qps);
    }

    public static void removeResource(String resource) {
        resourceLimiterMap.remove(resource);
    }

    public static void enter(String resource) throws RateLimitException {
        RateLimiter limiter = resourceLimiterMap.get(resource);
        if (limiter == null) {
            return;
        }
        if (!limiter.tryAcquire()) {
            throw new RateLimitException(resource);
        }
    }

    public static void exit(String resource) {
        //do nothing when use RateLimiter
    }
}
```

[1]: http://www.zte.com.cn/cndata/magazine/zte_communications/2007/3/magazine/200706/t20070628_150663.html
[2]: https://en.wikipedia.org/wiki/Token_bucket
[3]: https://github.com/google/guava/blob/v18.0/guava/src/com/google/common/util/concurrent/RateLimiter.java
[4]: https://github.com/google/guava/blob/v18.0/guava/src/com/google/common/util/concurrent/SmoothRateLimiter.java#L280:L307
[5]: https://github.com/google/guava/blob/v18.0/guava/src/com/google/common/util/concurrent/SmoothRateLimiter.java#L124:L130
