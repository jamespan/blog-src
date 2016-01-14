title: Guava 是个风火轮之基础工具(3)
tags:
  - Java
  - Guava
categories:
  - Study
cc: true
math: true
hljs: true
comments: true
date: 2015-03-01 00:23:14
---

# 前言

Guava 是 Java 开发者的好朋友。虽然我在开发中使用 Guava 很长时间了，Guava API 的身影遍及我写的生产代码的每个角落，但是我用到的功能只是 Guava 的功能集中一个少的可怜的真子集，更别说我一直没有时间认真的去挖掘 Guava 的功能，没有时间去学习 Guava 的实现。直到最近，我开始阅读 *[Getting Started with Google Guava][1]*，感觉有必要将我学习和使用 Guava 的一些东西记录下来。

# Charsets

Charsets 是一个常量工厂，给出了 6 个Java 承诺了全平台支持的字符集，类似的静态工厂在 Apache 的类库中也有提供。如果没有静态变量，我们要么使用 Charset#forName 方法，传入一个字符串来获取指定的字符集，要么自己定义一个类似的工厂类。

<!-- more --><!-- indicate-the-source -->

使用 Charset#forName 的问题就在于用户需要关注入参字符串的拼写，一旦拼写错误就会出现意料之外的事情。

到了 Java 7 中，JDK 提供了一个官方的静态工厂类 java.nio.charset.StandardCharsets，Guava 也推荐使用 Java 7 及以上的用户使用 StandardCharsets。

# Strings

在 Guava 中，以名词的复数形式命名的类，基本上都是静态工厂。Strings 就是这么一个用来操作字符串的方法工厂。

Strings 提供了空指针、空字符串的判断和互换方法。

```java
Strings.isNullOrEmpty("");//true
Strings.nullToEmpty(null);//""
Strings.nullToEmpty("a");//"a"
Strings.emptyToNull("");//null
Strings.emptyToNull("a");//"a"
```

对于防御式编程，可以在拿到字符串入参之后，调用一下 Strings#nullToEmpty 将可能的空指针变成空字符串，然后也就不用担心字符串引发的 NPE，或者字符串拼接时候出现的 "null" 了。

Strings 还提供了常见的字符串前后拼接同一个字符直到达到某个长度，或者重复拼接自身 n 次。

```java
Strings.padStart("7", 3, '0');//"007"
Strings.padStart("2010", 3, '0');//"2010"
Strings.padEnd("4.", 5, '0');//"4.000"
Strings.padEnd("2010", 3, '!');//"2010"
Strings.repeat("hey", 3);//"heyheyhey"
```

Strings 的最后一组功能是查找两个字符串的公共前缀、后缀。

```java
Strings.commonPrefix("aaab", "aac");//"aa"
Strings.commonSuffix("aaac", "aac");//"aac"
```

## 源码分析

源码来自 Guava 18.0。Strings 类的源码大约 240 行，大部分的函数实现中规中矩，值得关注的是 Strings#repeat。代码注释赫然写着，如果你修改了这里的代码，必须同步更新 Benchmark！看来这段代码是经过极致优化了的，让我不禁想起当年楼教主比赛时“我去上个厕所，不要动键盘”的霸气。

```java
public static String repeat(String string, int count) {
  checkNotNull(string);  // eager for GWT.
  if (count <= 1) {
    checkArgument(count >= 0, "invalid count: %s", count);
    return (count == 0) ? "" : string;
  }
  // IF YOU MODIFY THE CODE HERE, you must update StringsRepeatBenchmark
  final int len = string.length();
  final long longSize = (long) len * (long) count;
  final int size = (int) longSize;
  if (size != longSize) {
    throw new ArrayIndexOutOfBoundsException("Required array size too large: " + longSize);
  }
  final char[] array = new char[size];
  string.getChars(0, len, array, 0);
  int n;
  for (n = len; n < size - n; n <<= 1) {
    System.arraycopy(array, 0, array, n, n);
  }
  System.arraycopy(array, 0, array, n, size - n);
  return new String(array);
}
```

真正的代码从霸气注释开始。开头的 3 行代码，int 升级 long 然后降级 int，是为了确保字符串 repeat 之后没有超过 String 的长度限制，而先强制提升然后截断的方法，能够高效的判断溢出，这种手法在 C 语言中也是常见的。由于这里是判断 int 溢出，可以升级到 long，如果判断 long 溢出，就只能用除法了。

然后这里没有用 StringBuilder，而是出于性能考虑用了 char[]，直接申请目标大小的数组。循环复制字符串的时候，复制源的长度指数增长，以最快的速度结束循环。System#arraycopy 是个 native 方法，也就是用 C 来实现的，性能上似乎更值得信赖一点。

另外一段让我涨姿势的代码是查找相同前缀的。

```java
public static String commonPrefix(CharSequence a, CharSequence b) {
  checkNotNull(a);
  checkNotNull(b);
  int maxPrefixLength = Math.min(a.length(), b.length());
  int p = 0;
  while (p < maxPrefixLength && a.charAt(p) == b.charAt(p)) {
    p++;
  }
  if (validSurrogatePairAt(a, p - 1) || validSurrogatePairAt(b, p - 1)) {
    p--;
  }
  return a.subSequence(0, p).toString();
}

static boolean validSurrogatePairAt(CharSequence string, int index) {
  return index >= 0 && index <= (string.length() - 2)
      && Character.isHighSurrogate(string.charAt(index))
      && Character.isLowSurrogate(string.charAt(index + 1));
}
```

整个函数本来很简单的，但是 while 后面还跟着一个莫名其妙的 if，这是什么东西！函数名里面居然出现了我不认识的单词，英语水平暴露了！

一番 Google 之后发现，这里其实是判断最后两个字符是不是合法的“[Java 平台增补字符][2]”。看起来这些增补字符占了 2 个字节，然后要用判断高位低位之类的。。仔细看了函数的头注释，里面也提到 taking care not to split surrogate pairs，然后就明了了。

# CharMacher

一提起字符串操作，我们都会想起一个神奇的符号，StringUtil。不仅仅 Apache Common 有一个 StringUtil，Spring 也有一个类似的 StringUtils，然后各个公司、各个项目也会造个轮子，或者重写，或者继承来实现自己的一些特殊的字符串操作。

> 随着 StringUtil 无节制的发展，StringUtil 里面充斥着 allAscii, collapse, collapseControlChars, collapseWhitespace, indexOfChars, lastIndexNotOf, numSharedChars, removeChars, removeCrLf, replaceChars, retainAllChars, strip, stripAndCollapse, stripNonDigits 等等函数。这些函数本质上是两个概念的点积：

> 1. 如何界定匹配的字符？
> 2. 要对匹配的字符做什么？

为了解决这种野蛮增长，Guava 带来了 CharMacher。一个 CharMacher 实例本身，界定了一个匹配字符的集合，而 CharMacher 实例的方法，解决了要对匹配字符做什么的问题。然后我们就可以用最小化的 API 来处理字符匹配和字符操作，把 $M \times N$ 的复杂度下降到了 $M + N$。

CharMacher 自带常量工厂，域定义了一系列常用的字符集合，比如 CharMatcher#ASCII 匹配 ASCII 码，CharMatcher#DIGIT 匹配 Unicode 的数字 0~9，还有其他常量如 JAVA_DIGIT、JAVA_LETTER 等。

CharMacher 提供了一系列的静态方法用于构造自定义的字符集合。

CharMatcher#is 得到界定单个匹配字符的实例，CharMatcher#isNot 正好与前者逻辑反。CharMatcher#anyOf 生成存在量词，CharMatcher#noneOf 生成否定全称量词。CharMatcher#inRange 范围量词，闭区间。

本质上 CharMacher 继承自 Predicate，是专门字符对象的断言，因此 Predicate 享有的与或非等等操作，CharMacher 也有。我们可以用 CharMatcher#and、CharMatcher#or、CharMatcher#negate 来完成 CharMacher 的与或非，对于匹配字符集合来说就是交并补。

如果上述两种构造 CharMacher 的手段还是太弱没法描述我们想要的匹配器，没关系，我们还有大招：初始化一个重载了 CharMatcher#matches 方法的匿名类实例，或者显式继承 CharMacher 然后实现 matches 方法。

接下来我们看看 CharMacher 有哪些实例方法可用。根据函数的返回值和名称我们能够轻易将这些方法分为 3 类。

第一类是判定型函数，判断 CharMacher 和入参字符串的匹配关系。

```java
CharMatcher.is('a').matchesAllOf("aaa");//true
CharMatcher.is('a').matchesAnyOf("aba");//true
CharMatcher.is('a').matchesNoneOf("aba");//true
```

第二类是计数型函数，查找入参字符串中第一次、最后一次出现目标字符的位置，或者目标字符出现的次数，比如 CharMatcher#indexIn，CharMatcher#lastIndexIn 和 CharMatcher#countIn。

第三类就是对匹配字符的操作。我们能对字符串中的匹配字符做什么操作呢？基本上就是移除、仅保留、替换、前后修剪、collapse（不知道怎么翻译比较恰当） 等等，我们可以轻易地使用 CharMatcher#removeFrom、CharMatcher#retainFrom、CharMatcher#replaceFrom、CharMatcher#trimFrom、CharMatcher#collapseFrom 等等一系列正交的方法来实现。

## 源码分析

源码来自 Guava 18.0。CharMatcher 类源码约 1400 行，大致上分为常量、内部类、静态工厂、非静态工厂以及文本处理例程。

CharMatcher 整个类都被打上了 @Beta 注解，还有一句注释，Possibly change from chars to code points; decide constants vs. methods，看得我云里雾里的。不管怎么说，CharMatcher 自从 Guava 1.0 就一直存在了，虽然有着 Beta 注解，个人感觉被移除或者过时的可能性很小。

### 继承与组合

前不久我在一篇博文中看到这样一种说法（具体出处找不到了），那些可以直接实例化的类，应该被声明为 final，这样可以强制其他开发者使用组合而不是继承来复用代码。那些可以被继承的类，应该是抽象类，要么在实例化的时候补全虚函数的实现，要么通过继承实现虚函数。

对照 Guava 的代码，还真有点类似的意思。那些工厂类，基本上都被声明为了 final，而 CharMatcher 则是一个抽象类，在实例化的时候覆盖实现各种虚函数，也被各种内部类、外部类继承。

CharMatcher 中有 3 个私有静态类，CharMatcher\$And、CharMatcher\$Or、CharMatcher\$NegatedMatcher，用于描述 CharMatcher 的与或非关系。这 3 个类与 CharMatcher 之间既是继承，又是聚合。突然感觉 UML 好难画。

其他 4 个静态类，则是为了实现某种匹配模式，而对 CharMatcher 作出了特化处理，比如 RangesMatcher 专门匹配一段连续的字符范围，FastMatcher 专门匹配那些无法通过预处理获得性能提升的字符（们）。

### 代码即文档

我在写代码的时候总是把“自注释”、“代码即文档”等等挂在嘴边，但是真正能做到的代码却不多。有的时候把自己的代码拿出来，一眼看去尽是 IDE 自动生成的毫无意义的变量名，真是惭愧。

下面这段代码的参数命名比较有趣，值得借鉴。

```java
public static CharMatcher inRange(final char startInclusive, final char endInclusive) {
  checkArgument(endInclusive >= startInclusive);
  String description = "CharMatcher.inRange('" +
      showCharacter(startInclusive) + "', '" +
      showCharacter(endInclusive) + "')";
  return inRange(startInclusive, endInclusive, description);
}
```

不需要任何文档，我们从函数名和参数名就能够看出，这段代码返回的 CharMatcher 匹配的是一个闭区间内的字符。如果换了别人来实现，能用 start 和 end 做参数名的已经算是很不错了，大部分估计用 c1、c2 敷衍了事，更不用说加上起到关键作用的 Inclusive 了。

总体而言，CharMatcher 的代码虽然长，却没有特别深奥或者精彩的片段，less is more。

[1]: http://book.douban.com/subject/25710862/
[2]: http://www.oracle.com/technetwork/articles/javase/index-142761.html