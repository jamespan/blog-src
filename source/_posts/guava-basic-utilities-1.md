title: Guava 是个风火轮之基础工具(1)
tags:
  - Java
  - Guava
categories:
  - Study
cc: true
hljs: true
comments: true
date: 2015-02-08 17:01:53
---

# 前言

Guava 是 Java 开发者的好朋友。虽然我在开发中使用 Guava 很长时间了，Guava API 的身影遍及我写的生产代码的每个角落，但是我用到的功能只是 Guava 的功能集中一个少的可怜的真子集，更别说我一直没有时间认真的去挖掘 Guava 的功能，没有时间去学习 Guava 的实现。直到最近，我开始阅读 *[Getting Started with Google Guava][1]*，感觉有必要将我学习和使用 Guava 的一些东西记录下来。

# Joiner

我们经常需要将几个字符串，或者字符串数组、列表之类的东西，拼接成一个以指定符号分隔各个元素的字符串，比如把 [1, 2, 3] 拼接成 "1 2 3"。

<!-- more --><!-- indicate-the-source -->

在 Python 中我只需要简单的调用 str.join 函数，就可以了，就像这样。

```python
' '.join(map(str, [1, 2, 3]))
```

到了 Java 中，如果你不知道 Guava 的存在，基本上就得手写循环去实现这个功能，代码瞬间变得丑陋起来。

Guava 为我们提供了一套优雅的 API，让我们能够轻而易举的完成字符串拼接这一简单任务。还是上面的例子，借助 Guava 的 Joiner 类，代码瞬间变得优雅起来。

```java
Joiner.on(' ').join(1, 2, 3);
```

被拼接的对象集，可以是硬编码的少数几个对象，可以是实现了 Iterable 接口的集合，也可以是迭代器对象。

除了返回一个拼接过的字符串，Joiner 还可以在实现了 Appendable 接口的对象所维护的内容的末尾，追加字符串拼接的结果。

```java
StringBuilder sb = new StringBuilder("result:");
Joiner.on(" ").appendTo(sb, 1, 2, 3);
System.out.println(sb);//result:1 2 3
```

Guava 对空指针有着严格的限制，如果传入的对象中包含空指针，Joiner 会直接抛出 NPE。与此同时，Joiner 提供了两个方法，让我们能够优雅的处理待拼接集合中的空指针。

如果我们希望忽略空指针，那么可以调用 skipNulls 方法，得到一个会跳过空指针的 Joiner 实例。如果希望将空指针变为某个指定的值，那么可以调用 useForNull 方法，指定用来替换空指针的字符串。

```java
Joiner.on(' ').skipNulls().join(1, null, 3);//1 3
Joiner.on(' ').useForNull("None").join(1, null, 3);//1 None 3
```

需要注意的是，Joiner 实例是不可变的，skipNulls 和 useForNull 都不是在原实例上修改某个成员变量，而是生成一个新的 Joiner 实例。

## Joiner.MapJoiner

MapJoiner 是 Joiner 的内部静态类，用于帮助将 Map 对象拼接成字符串。

```java
Joiner.on("#").withKeyValueSeparator("=").join(ImmutableMap.of(1, 2, 3, 4));//1=2#3=4
```

withKeyValueSeparator 方法指定了键与值的分隔符，同时返回一个 MapJoiner 实例。有些家伙会往 Map 里插入键或值为空指针的键值对，如果我们要拼接这种 Map，千万记得要用 useForNull 对 MapJoiner 做保护，不然 NPE 妥妥的。

## 源码分析

源码来自 Guava 18.0。Joiner 类的源码约 450 行，其中大部分是注释、函数重载，常用手法是先实现一个包含完整功能的函数，然后通过各种封装，把不常用的功能隐藏起来，提供优雅简介的接口。这样子的好处显而易见，用户可以使用简单接口解决 80% 的问题，那些罕见而复杂的需求，交给全功能函数去支持。

### 初始化方法

由于构造函数被设置成了私有，Joiner 只能通过 Joiner#on 函数来初始化。最基础的 Joiner#on 接受一个字符串入参作为分隔符，而接受字符入参的 Joiner#on 方法是前者的重载，内部使用 String#valueOf 函数将字符变成字符串后调用前者完成初始化。或许这是一个利于字符串内存回收的优化。

### 追加拼接结果

整个 Joiner 类最核心的函数莫过于 `<A extends Appendable> Joiner#appendTo(A, Iterator<?>)`，一切的字符串拼接操作，最后都会调用到这个函数。这就是所谓的全功能函数，其他的一切 appendTo 只不过是它的重载，一切的 join 不过是它和它的重载的封装。

```java
public <A extends Appendable> A appendTo(A appendable, Iterator<?> parts) throws IOException {
  checkNotNull(appendable);
  if (parts.hasNext()) {
    appendable.append(toString(parts.next()));
    while (parts.hasNext()) {
      appendable.append(separator);
      appendable.append(toString(parts.next()));
    }
  }
  return appendable;
}
```

这段代码的第一个技巧是使用 if 和 while 来实现了比较优雅的分隔符拼接，避免了在末尾插入分隔符的尴尬；第二个技巧是使用了自定义的 toString 方法而不是 Object#toString 来将对象序列化成字符串，为后续的各种空指针保护开了方便之门。

注意到一个比较有意思的 appendTo 重载。

```java
public final StringBuilder appendTo(StringBuilder builder, Iterator<?> parts) {
  try {
    appendTo((Appendable) builder, parts);
  } catch (IOException impossible) {
    throw new AssertionError(impossible);
  }
  return builder;
}
```

在 Appendable 接口中，append 方法是会抛出 IOException 的。然而 StringBuilder 虽然实现了 Appendable，但是它覆盖实现的 append 方法却是不抛出 IOException 的。于是就出现了明知不可能抛异常，却又不得不去捕获异常的尴尬。

这里的异常处理手法十分机智，异常变量命名为 impossible，我们一看就明白这里是不会抛出 IOException 的。但是如果 catch 块里面什么都不做又好像不合适，于是抛出一个 AssertionError，表示对于这里不抛异常的断言失败了。

另一个比较有意思的 appendTo 重载是关于可变长参数。

```java
public final <A extends Appendable> A appendTo(
    A appendable, @Nullable Object first, @Nullable Object second, Object... rest)
        throws IOException {
  return appendTo(appendable, iterable(first, second, rest));
}
```

注意到这里的 iterable 方法，它把两个变量和一个数组变成了一个实现了 Iterable 接口的集合，手法精妙！

```java
private static Iterable<Object> iterable(
    final Object first, final Object second, final Object[] rest) {
  checkNotNull(rest);
  return new AbstractList<Object>() {
    @Override public int size() {
      return rest.length + 2;
    }

    @Override public Object get(int index) {
      switch (index) {
        case 0:
          return first;
        case 1:
          return second;
        default:
          return rest[index - 2];
      }
    }
  };
}
```

如果是我来实现，可能是简单粗暴的创建一个 ArrayList 的实例，然后把这两个变量一个数组的全部元素放到 ArrayList 里面然后返回。这样子代码虽然短了，但是代价却不小：为了一个小小的重载调用而产生了 O(n) 的时空复杂度。

看看人家 G 社的做法。要想写出这样的代码，需要熟悉顺序表迭代器的实现。迭代器内部维护着一个游标，cursor。迭代器的两大关键操作，hasNext 判断是否还有没遍历的元素，next 获取下一个元素，它们的实现是这样的。

```java
public boolean hasNext() {
    return cursor != size();
}

public E next() {
    checkForComodification();
    try {
        int i = cursor;
        E next = get(i);
        lastRet = i;
        cursor = i + 1;
        return next;
    } catch (IndexOutOfBoundsException e) {
        checkForComodification();
        throw new NoSuchElementException();
    }
}
```

hasNext 中关键的函数调用是 size，获取集合的大小。next 方法中关键的函数调用是 get，获取第 i 个元素。Guava 的实现返回了一个被覆盖了 size 和 get 方法的 AbstractList，巧妙的复用了由编译器生成的数组，避免了新建列表和增加元素的开销。

### 空指针处理

当待拼接列表中可能包含空指针时，我们用 useForNull 将空指针替换为我们指定的字符串。它是通过返回一个覆盖了方法的 Joiner 实例来实现的。

```java
  public Joiner useForNull(final String nullText) {
    checkNotNull(nullText);
    return new Joiner(this) {
      @Override CharSequence toString(@Nullable Object part) {
        return (part == null) ? nullText : Joiner.this.toString(part);
      }

      @Override public Joiner useForNull(String nullText) {
        throw new UnsupportedOperationException("already specified useForNull");
      }

      @Override public Joiner skipNulls() {
        throw new UnsupportedOperationException("already specified useForNull");
      }
    };
  }
```

首先是使用复制构造函数保留先前初始化时候设置的分隔符，然后覆盖了之前提到的 toString 方法。为了防止重复调用 useForNull 和 skipNulls，还特意覆盖了这两个方法，一旦调用就抛出运行时异常。为什么不能重复调用 useForNull ？因为覆盖了 toString 方法，而覆盖实现中需要调用覆盖前的 toString。

在不支持的操作中抛出 UnsupportedOperationException 是 Guava 的常见做法，可以在第一时间纠正不科学的调用方式。

skipNulls 的实现就相对要复杂一些，覆盖了原先全功能 appendTo 中使用 if 和 while 的优雅实现，变成了 2 个 while 先后执行。第一个 while 找到 第一个不为空指针的元素，起到之前的 if 的功能，第二个 while 功能和之前的一致。

```java
public Joiner skipNulls() {
  return new Joiner(this) {
    @Override public <A extends Appendable> A appendTo(A appendable, Iterator<?> parts)
        throws IOException {
      checkNotNull(appendable, "appendable");
      checkNotNull(parts, "parts");
      while (parts.hasNext()) {
        Object part = parts.next();
        if (part != null) {
          appendable.append(Joiner.this.toString(part));
          break;
        }
      }
      while (parts.hasNext()) {
        Object part = parts.next();
        if (part != null) {
          appendable.append(separator);
          appendable.append(Joiner.this.toString(part));
        }
      }
      return appendable;
    }

    @Override public Joiner useForNull(String nullText) {
      throw new UnsupportedOperationException("already specified skipNulls");
    }

    @Override public MapJoiner withKeyValueSeparator(String kvs) {
      throw new UnsupportedOperationException("can't use .skipNulls() with maps");
    }
  };
}
```

### 拼接键值对

MapJoiner 实现为 Joiner 的一个静态内部类，它的构造函数和 Joiner 一样也是私有，只能通过 Joiner#withKeyValueSeparator 来生成实例。类似地，MapJoiner 也实现了 appendTo 方法和一系列的重载，还用 join 方法对 appendTo 做了封装。MapJoiner 整个实现和 Joiner 大同小异，在实现中大量使用 Joiner 的 toString 方法来保证空指针保护行为和初始化时的语义一致。

MapJoiner 也实现了一个 useForNull 方法，这样的好处是，在获取 MapJoiner 之后再去设置空指针保护，和获取 MapJoiner 之前就设置空指针保护，是等价的，用户无需去关心顺序问题。


[1]: http://book.douban.com/subject/25710862/