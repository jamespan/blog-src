title: Guava 是个风火轮之基础工具(4)
tags:
  - Java
  - Guava
categories:
  - Study
cc: true
hljs: true
comments: true
date: 2015-03-10 00:20:32
---

# 前言

Guava 是 Java 开发者的好朋友。虽然我在开发中使用 Guava 很长时间了，Guava API 的身影遍及我写的生产代码的每个角落，但是我用到的功能只是 Guava 的功能集中一个少的可怜的真子集，更别说我一直没有时间认真的去挖掘 Guava 的功能，没有时间去学习 Guava 的实现。直到最近，我开始阅读 *[Getting Started with Google Guava][1]*，感觉有必要将我学习和使用 Guava 的一些东西记录下来。

# Preconditions

Precondition 是先决条件的意思，也叫前置条件，可以人为是使函数正常执行的参数需要满足的条件。在 Preconditions 这个静态工厂中，Guava 为我们提供了一系列的静态方法，用于帮助我们在函数执行的开始检查参数，函数执行的过程中检查状态等等。

<!-- more -->

```java
Preconditions.checkArgument(5 < 3);//IllegalArgumentException
Preconditions.checkState(5 < 3);//IllegalStateException
Preconditions.checkNotNull(null);//NullPointerException
Preconditions.checkElementIndex(4, 4);//IndexOutOfBoundsException
Preconditions.checkPositionIndex(5, 4);//IndexOutOfBoundsException
```

## 源码分析

源码来自 Guava 18.0。Preconditions 类代码约 440 行，大部分是 JavaDoc 和函数重载，那些真正干活的代码大部分也是先 if 然后 throw 的模式。

```java
public static void checkArgument(boolean expression) {
  if (!expression) {
    throw new IllegalArgumentException();
  }
}
```

大约在 255 行处有[一大段的注释][2]，讲了一个有趣的事情。

大概从 2009 年开始，由于 Hotspot 虚拟机优化器的一个 bug，对于抛异常的代码，直接在初始化异常时传入字符串常量反而导致效率低下，效率远远不如在初始化前调用一个类型是 String 的函数来获取字符串，而且这个性能差距不是 10% 或者 20%，而是可怕的 2 倍到 8 倍。于是我们看到的 JDK 类库的抛异常代码，就从

```java
if (guardExpression) {
   throw new BadException(messageExpression);
}
```

变成了下面这样。

```java
if (guardExpression) {
   throw new BadException(badMsg(...));
}
```

# Objects

我们在定义一个类的时候，免不了会去覆盖 toString 方法；如果要把这个类的对象放到 HashMap 中，还得去覆盖 hashCode 方法；如果对象之间需要比较大小，那么还得实现 Comparable 接口的 compareTo 方法。

Guava 为我们提供了方便的实现这些方法的工具。虽然优秀的 IDE 比如 IntelliJ IDEA 能够自动帮我们生成 toString 和 hashCode，但是依赖代码生成器始终不是一个科学的开发方式。

需要说明的一点是，Objects 类中用于帮助实现 toString 方法的内部类 ToStringHelper，已经被标记为过时，在 Guava 18.0 中迁移到 MoreObjects 中了，而用于帮助实现 compareTo 的则是 ComparisonChain 类，稍后会解读这个类的用法和代码。

现在的 Objects 中硕果仅存的两个函数，分别是 Objects#equal 和 Objects#hashCode，分别用于判断两个对象是否相等，和生成对象的 hashCode。

```java
Objects.equal(new Object(), new Object());//false
Objects.hashCode("", new Object());//340664367
```

## 源码分析

源码来自 Guava 18.0。Objects 类代码约 320 行，刨除过时代码之后，也没剩几行了。

硕果仅存的两个函数，实现比想象中还简单。

```java
public static boolean equal(@Nullable Object a, @Nullable Object b) {
  return a == b || (a != null && a.equals(b));
}

public static int hashCode(@Nullable Object... objects) {
  return Arrays.hashCode(objects);
}
```

我好奇的跟到 Arrays#hashCode 里面看了看，发现这段计算 hashCode 的代码，和 String 类里面的算法几乎一样，31 据说是一个经验值，反正无论如何必须是个质数。

```java
public static int hashCode(Object a[]) {
    if (a == null)
        return 0;
    int result = 1;
    for (Object element : a)
        result = 31 * result + (element == null ? 0 : element.hashCode());
    return result;
}
```

# MoreObjects

MoreObjects 是从 18.0 版本开始出现的一个新类，从 Objects 中分裂出来的，主要剥离了内部类 ToStringHelper 以及一系列的包装函数。

至于那个顺便一起迁移过来的 MoreObjects#firstNonNull 函数，功能和实现都过分简单，这里就不展开了，有兴趣的可以查看[源码][3]。

下面是 ToStringHelper 的简单用法，通过调用 ToStringHelper#omitNullValues 来配置 ToStringHelper 使得生成的字符串中不含 null 值。

```java
public class Player {
    private String name = "Underwood";
    private String sex;
    @Override
    public String toString() {
        return MoreObjects.toStringHelper(this).omitNullValues()
                .add("name", name)
                .add("sex", sex)
                .toString();//Player{name=Underwood}
    }
}
```

## 源码分析

源码来自 Guava 18.0。MoreObjects 类代码约 390 行，甚至比 Objects 还要多。其中 ToStringHelper 代码约 240 行，这里我们主要看看 ToStringHelper 的实现。

从 ToStringHelper 的属性可以看出，它内部维护着一个链表。

```java
public static final class ToStringHelper {
  private final String className;
  private ValueHolder holderHead = new ValueHolder();
  private ValueHolder holderTail = holderHead;
  private boolean omitNullValues = false;
  //some codes
  private static final class ValueHolder {
    String name;
    Object value;
    ValueHolder next;
  }
}
```

为了保持插入结点后链表结点顺序和代码调用的顺序一致，ToStringHelper 还额外维护了一个尾指针，在链表尾插入新结点。

```java
private ValueHolder addHolder() {
  ValueHolder valueHolder = new ValueHolder();
  holderTail = holderTail.next = valueHolder;
  return valueHolder;
}
private ToStringHelper addHolder(String name, @Nullable Object value) {
  ValueHolder valueHolder = addHolder();
  valueHolder.value = value;
  valueHolder.name = checkNotNull(name);
  return this;
}
```

最后的最后，ToStringHelper#toString 就是遍历对象内部维护的链表，拼接字符串了。说道字符串拼接，之前在[Guava 是个风火轮之基础工具(1)][4]中，我们看到 Joiner 使用 if 和 while 来实现了比较优雅的分隔符拼接，避免了在末尾插入分隔符的尴尬。在这里，Guava 的作者展示了另一个技巧，用更少的代码实现同样的效果。

```java
@Override public String toString() {
  // create a copy to keep it consistent in case value changes
  boolean omitNullValuesSnapshot = omitNullValues;
  String nextSeparator = "";
  StringBuilder builder = new StringBuilder(32).append(className)
      .append('{');
  for (ValueHolder valueHolder = holderHead.next; valueHolder != null;
      valueHolder = valueHolder.next) {
    if (!omitNullValuesSnapshot || valueHolder.value != null) {
      builder.append(nextSeparator);
      nextSeparator = ", ";
      if (valueHolder.name != null) {
        builder.append(valueHolder.name).append('=');
      }
      builder.append(valueHolder.value);
    }
  }
  return builder.append('}').toString();
}
```

一开始的时候，先把分隔符置为空字符串，完成分隔符拼接之后，将分隔符置为逗号，这样就实现了从第二个元素开始，每个元素前面拼接分隔符的效果。这样子就不用去判断当前元素是不是第一个元素，代价仅仅是每次循环多出一次冗余的赋值，完全可以忽略不计。

# ComparisonChain

ComparisonChain 可以帮助我们优雅地实现具有短回路功能链式比较，然后我们可以借助 ComparisonChain 来实现 compareTo 方法。先看看这个类的用法。

```java
public class Player implements Comparable<Player> {
    private String name = "Underwood";
    private String sex;
    public int compareTo(Player that) {
        return ComparisonChain.start()
                .compare(this.name, that.name)
                .compare(this.sex, that.sex)
                .result();
    }
}
```

美中不足的是，比较链的参数，基本不能有空指针，不然当场就 NPE 了。虽然我们可以通过自定义比较器去兼容空指针，但是这样一来代码就变得一点都不优雅了。

## 源码分析

带着对 ComparisonChain 空指针处理不力的不满，我们来看看它的实现，如果可能就动手实现我们需要的特性。

源码来自 Guava 18.0。ComparisonChain 类代码约 220 行，大部分是注释和 ComparisonChain#compare 函数的各种重载。看到 ComparisonChain 是一个抽象类，各种 ComparisonChain#compare 都是虚函数，返回结果的 ComparisonChain#result 也是虚函数，我以为有希望继承它然后做些改造。不过看到代码里那个私有的构造函数之后，我打消了继承它的念头。

ComparisonChain 内部维护着 3 个 ComparisonChain 类型的变量，ACTIVE、LESS、GREATER，容易知道这代表着链式比较的状态，ACTIVE 还需要继续比较，其他两个则是已经知道最终结果了。

LESS 和 GREATER 状态其实是 InactiveComparisonChain 类的对象，这个类内部有一个属性维护比较链的结果，然后各种 compare 函数都是直接返回 this 指针，着就是所谓的短回路了，能够避免调用被比较对象的 compareTo 函数。

```java
private static final class InactiveComparisonChain extends ComparisonChain {
  final int result;
  InactiveComparisonChain(int result) { this.result = result; }
  @Override public ComparisonChain compare(int left, int right) { return this; }
  //other compare functions
  @Override public int result() { return result; }
}
```

最后，我对 ComparisonChain 稍作改动，增强了它对空指针的容忍，可以通过 ComparisonChain#nullValueLess 来设置 null 字段在比较的时候小于非 null 字段，访问 [Gist][5] 查看代码片段。

<!-- <script src="https://gist.github.com/JamesPan/f2d5b6dfd5fc71bef644.js"></script> -->

[1]: http://book.douban.com/subject/25710862/
[2]: https://github.com/google/guava/blob/v18.0/guava/src/com/google/common/base/Preconditions.java#L255-L279
[3]: https://github.com/google/guava/blob/v18.0/guava/src/com/google/common/base/MoreObjects.java#L51-L53
[4]: /2015/02/08/guava-basic-utilities-1/#追加拼接结果
[5]: https://gist.github.com/JamesPan/f2d5b6dfd5fc71bef644