title: Guava 是个风火轮之基础工具(2)
tags:
  - Java
  - Guava
categories:
  - Study
cc: true
hljs: true
comments: true
date: 2015-02-09 23:43:38
---



# 前言

Guava 是 Java 开发者的好朋友。虽然我在开发中使用 Guava 很长时间了，Guava API 的身影遍及我写的生产代码的每个角落，但是我用到的功能只是 Guava 的功能集中一个少的可怜的真子集，更别说我一直没有时间认真的去挖掘 Guava 的功能，没有时间去学习 Guava 的实现。直到最近，我开始阅读 *[Getting Started with Google Guava][1]*，感觉有必要将我学习和使用 Guava 的一些东西记录下来。

# Splitter

Guava 提供了 Joiner 类用于将多个对象拼接成字符串，如果我们需要一个反向的操作，就要用到 Splitter 类。Splitter 能够将一个字符串按照指定的分隔符拆分成可迭代遍历的字符串集合，`Iterable<String>`。

<!-- more --><!-- indicate-the-source -->

Splitter 的 API 和 Joiner 类似，使用 Splitter#on 指定分隔符，使用 Splitter#split 完成拆分。

```java
Splitter.on(' ').split("1 2 3");//["1", "2", "3"]
```

Splitter 还支持使用正则表达式来描述分隔符。

```java
Splitter.onPattern("\\s+").split("1 \t   2 3");//["1", "2", "3"]
```

Splitter 还支持根据长度来拆分字符串。

```java
Splitter.fixedLength(3).split("1 2 3");//["1 2", " 3"]
```

## Splitter.MapSplitter

与 Joiner.MapJoiner 相对，Splitter.MapSplitter 用来拆分被拼接了的 Map 对象，返回 `Map<String, String>`。

```java
Splitter.on("#").withKeyValueSeparator(":").split("1:2#3:4");//{"1":"2", "3":"4"}
```

需要注意的是，不是所有由 MapJoiner 拼接出来的字符串，都能够被 MapSplitter 拆分，MapSplitter 对键值对个格式有着严格的校验。比如下面的拆分会抛出异常。

```java
Splitter.on("#").withKeyValueSeparator(":").split("1:2#3:4:5");
//java.lang.IllegalArgumentException: Chunk [3:4:5] is not a valid entry
```

因此，如果希望使用 MapSplitter 来拆分 KV 结构的字符串，需要保证键-值分隔符和键值对之间的分隔符不会称为键或值的一部分。也许是出于类似方面的考虑，MapSplitter 被加上了 @Beta 注解，也许在不久的将来它会被移除，或者有大的变化。如果在应用中有可能用到 KV 结构的字符串，我一般推荐使用 JSON 而不是 MapJoiner + MapSplitter。


## 源码分析

源码来自 Guava 18.0。Splitter 类源码约 600 行，依旧大部分是注释和函数重载。Splitter 的实现中有十分明显的策略模式和模板模式，有各种神乎其技的方法覆盖，还有 Guava 久负盛名的迭代技巧和惰性计算。

不得不说，平时翻阅一些基础类库，总是感觉 “这种代码我也能写”，“这代码写的还没我好”，“在工具类中强依赖日志组件，人干事？”，如果 IDE 配上弹幕恐怕全是吐槽，难有让人精神为之一振的代码。阅读 Guava 的代码，每次都有新的惊喜，各种神技巧黑科技让我五体投地，写代码的脑洞半径屡次被 Guava 撑大。 

### 成员变量

Splitter 类有 4 个成员变量，strategy 用于帮助实现策略模式，omitEmptyStrings 用于控制是否删除拆分结果中的空字符串，通过 Splitter#omitEmptyStrings 设置，trimmer 用于描述删除拆分结果的前后空白符的策略，通过 Splitter#trimResults 设置，limit 用于控制拆分的结果个数，通过 Splitter#limit 设置。

### 策略模式

Splitter 支持根据字符、字符串、正则、长度还有 Guava 自己的字符匹配器 CharMatcher 来拆分字符串，基本上每种匹配模式的查找方法都不太一样，但是字符拆分的基本框架又是不变的，策略模式正好合用。

策略接口的定义很简单，就是传入一个 Splitter 和一个待拆分的字符串，返回一个迭代器。

```java
private interface Strategy {
  Iterator<String> iterator(Splitter splitter, CharSequence toSplit);
}
```

然后在重载入参为 CharMatcher 的 Splitter#on 的时候，传入一个覆盖了 Strategy#iterator 方法的策略实例，返回值是 SplittingIterator 这个专用的迭代器。然后 SplittingIterator 是个抽象类，需要覆盖实现 separatorStart 和 separatorEnd 两个方法才能实例化。这两个方法是 SplittingIterator 用到的模板模式的重要组成。

```java
public static Splitter on(final CharMatcher separatorMatcher) {
  checkNotNull(separatorMatcher);
  return new Splitter(new Strategy() {
    @Override public SplittingIterator iterator(Splitter splitter, final CharSequence toSplit) {
      return new SplittingIterator(splitter, toSplit) {
        @Override int separatorStart(int start) {
          return separatorMatcher.indexIn(toSplit, start);
        }
        @Override int separatorEnd(int separatorPosition) {
          return separatorPosition + 1;
        }
      };
    }
  });
}
```

阅读源码的过程在，一个神奇的 continue 的用法让我震惊了，赶紧 Google 一番之后发现这种用法一直都有，只是我不知道而已。这段代码出自 Splitter#on 的字符串重载。

```java
return new SplittingIterator(splitter, toSplit) {
  @Override public int separatorStart(int start) {
    int separatorLength = separator.length();
    positions:
    for (int p = start, last = toSplit.length() - separatorLength; p <= last; p++) {
      for (int i = 0; i < separatorLength; i++) {
        if (toSplit.charAt(i + p) != separator.charAt(i)) {
          continue positions;
        }
      }
      return p;
    }
    return -1;
  }
  @Override public int separatorEnd(int separatorPosition) {
    return separatorPosition + separator.length();
  }
};
```

这里的 continue 可以直接跳出内循环，然后继续执行与 positions 标签平级的循环。如果是 break，就会直接跳出 positions 标签平级的循环。以前用 C 的时候在跳出多重循环的时候都是用 goto 的，没想到 Java 也提供了类似的功能。

这段 for 循环如果我来实现，估计会写成这样，虽然功能差不多，大家的内循环都不紧凑，但是明显没有 Guava 的实现那么高贵冷艳，而且我的代码的计算量要大一些。

```java
for (int p = start, last = toSplit.length() - separatorLength; p <= last; p++) {
  boolean match = true;
  for (int i = 0; i < separatorLength; i++) {
    match &= (toSplit.charAt(i + p) == separator.charAt(i))
  }
  if (match) {
    return p;
  }
}
```

### 惰性迭代器与模板模式

惰性求值是函数式编程中的常见概念，它的目的是要最小化计算机要做的工作，即把计算推迟到不得不算的时候进行。Java 虽然没有原生支持惰性计算，但是我们依然可以通过一些手段享受惰性计算的好处。

Guava 中的迭代器使用了惰性计算的技巧，它不是一开始就算好结果放在列表或集合中，而是在调用 hasNext 方法判断迭代是否结束时才去计算下一个元素。为了看懂 Guava 的惰性迭代器实现，我们要从 AbstractIterator 开始。

AbstractIterator 使用一个私有的枚举变量 state 来记录当前的迭代进度，比如是否找到了下一个元素，迭代是否结束等等。

```java
private enum State {
  READY, NOT_READY, DONE, FAILED,
}
```

AbstractIterator 给出了一个抽象方法 computeNext，计算下一个元素。由于 state 是私有变量，而迭代是否结束只有在调用 computeNext 的过程中才知道，于是我们有了一个保护的 endOfData 方法，允许 AbstractIterator 的子类将 state 设置为 State#DONE。

AbstractIterator 实现了迭代器最重要的两个方法，hasNext 和 next。

```java
@Override
public final boolean hasNext() {
  checkState(state != State.FAILED);
  switch (state) {
    case DONE:
      return false;
    case READY:
      return true;
    default:
  }
  return tryToComputeNext();
}

@Override
public final T next() {
  if (!hasNext()) {
    throw new NoSuchElementException();
  }
  state = State.NOT_READY;
  T result = next;
  next = null;
  return result;
}
```

hasNext 很容易理解，一上来先判断迭代器当前状态，如果已经结束，就返回 false；如果已经找到下一个元素，就返回true，不然就试着找找下一个元素。

next 则是先判断是否还有下一个元素，属于防御式编程，先对自己做保护；然后把状态复原到还没找到下一个元素，然后返回结果。至于为什么先把 next 赋值给 result，然后把 next 置为 null，最后才返回 result，我想这可能是个面向 GC 的优化，减少无意义的对象引用。

```
private boolean tryToComputeNext() {
  state = State.FAILED; // temporary pessimism
  next = computeNext();
  if (state != State.DONE) {
    state = State.READY;
    return true;
  }
  return false;
}
```

tryToComputeNext 可以认为是对模板方法 computeNext 的包装调用，首先把状态置为失败，然后才调用 computeNext。这样一来，如果计算下一个元素的过程中发生 RTE，整个迭代器的状态就是 State#FAILED，一旦收到任何调用都会抛出异常。

AbstractIterator 的代码就这些，我们现在知道了它的子类需要覆盖实现 computeNext 方法，然后在迭代结束时调用 endOfData。接下来看看 SplittingIterator 的实现。

SplittingIterator 还是一个抽象类，虽然实现了 computeNext 方法，但是它又定义了两个虚函数 separatorStart 和 separatorEnd，分别返回分隔符在指定下标之后第一次出现的下标，和指定下标后面第一个不包含分隔符的下标。之前的策略模式中我们可以看到，这两个函数在不同的策略中有各自不同的覆盖实现，在 SplittingIterator 中，这两个函数就是模板函数。

接下来我们看看 SplittingIterator 的核心函数 computeNext，注意这个函数一直在维护的两个内部全局变量，offset 和 limit。

```java
@Override protected String computeNext() {
  /*
   * The returned string will be from the end of the last match to the
   * beginning of the next one. nextStart is the start position of the
   * returned substring, while offset is the place to start looking for a
   * separator.
   */
  int nextStart = offset;
  while (offset != -1) {
    int start = nextStart;
    int end;

    int separatorPosition = separatorStart(offset);
    if (separatorPosition == -1) {
      end = toSplit.length();
      offset = -1;
    } else {
      end = separatorPosition;
      offset = separatorEnd(separatorPosition);
    }
    if (offset == nextStart) {
      /*
       * This occurs when some pattern has an empty match, even if it
       * doesn't match the empty string -- for example, if it requires
       * lookahead or the like. The offset must be increased to look for
       * separators beyond this point, without changing the start position
       * of the next returned substring -- so nextStart stays the same.
       */
      offset++;
      if (offset >= toSplit.length()) {
        offset = -1;
      }
      continue;
    }
    while (start < end && trimmer.matches(toSplit.charAt(start))) {
      start++;
    }
    while (end > start && trimmer.matches(toSplit.charAt(end - 1))) {
      end--;
    }
    if (omitEmptyStrings && start == end) {
      // Don't include the (unused) separator in next split string.
      nextStart = offset;
      continue;
    }
    if (limit == 1) {
      // The limit has been reached, return the rest of the string as the
      // final item.  This is tested after empty string removal so that
      // empty strings do not count towards the limit.
      end = toSplit.length();
      offset = -1;
      // Since we may have changed the end, we need to trim it again.
      while (end > start && trimmer.matches(toSplit.charAt(end - 1))) {
        end--;
      }
    } else {
      limit--;
    }
    return toSplit.subSequence(start, end).toString();
  }
  return endOfData();
}
```

进入 while 循环之后，先找找 offset 之后第一个分隔符出现的位置，if 分支处理没找到的情况，else 分支处理找到了的情况。然后下一个 if 处理的是第一个字符就是分隔符的特殊情况。然后接下来的两个 while 就开始根据 trimmer 来对找到的元素做前后处理，比如去除空白符之类的。再然后就是根据需要去除那些是空字符串的元素，trim完之后变成空字符串的也会被去除。最后一步操作就是判断 limit，如果还没到 limit 的极限，就让 limit 自减，否则就要调整 end 指针的位置标记 offset 为 -1 然后重新 trim 一下。下一次再调用 computeNext 的时候就发现 offset 已经是 -1 了，然后就返回 endOfData 表示迭代结束。

整个 Splitter 最有意思的部分基本上就是这些了，至于 split 函数，其实就是用匿名类函数覆盖技巧调用了一下策略模式中被花样覆盖实现了的 Strategy#iterator 而已。

```java
public Iterable<String> split(final CharSequence sequence) {
  checkNotNull(sequence);
  return new Iterable<String>() {
    @Override public Iterator<String> iterator() {
      return splittingIterator(sequence);
    }
    @Override public String toString() {
      return Joiner.on(", ")
          .appendTo(new StringBuilder().append('['), this)
          .append(']')
          .toString();
    }
  };
}
```

按理说实例化 Iterable 接口只需要实现 iterator 函数即可，这里覆盖了 toString 想必是为了方便打印吧？

MapSplitter 的实现中规中矩，使用 outerSplitter 拆分键值对，使用 entrySplitter 拆分键和值，拆分键和值前中后各种校验，然后返回一个不可修改的 Map。

最后说一下 Splitter 中一个略显画蛇添足的 API，Splitter#splitToList。

```java
public List<String> splitToList(CharSequence sequence) {
  checkNotNull(sequence);
  Iterator<String> iterator = splittingIterator(sequence);
  List<String> result = new ArrayList<String>();
  while (iterator.hasNext()) {
    result.add(iterator.next());
  }
  return Collections.unmodifiableList(result);
}
```

这个函数其实就是吭哧吭哧把惰性迭代器跑了一遍生成完整数据存放到 ArrayList 中，然后又用 Collections 把这个列表变成不可修改列表返回出去，一点都不酷。


[1]: http://book.douban.com/subject/25710862/