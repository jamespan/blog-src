title: Guava 是个风火轮之函数式编程(3)——表处理
tags:
  - Guava
  - Functional
categories:
  - Study
hljs: true
cc: true
comments: true
date: 2015-06-13 21:14:46
---

早先学习 Scheme 的时候，就已经对 Lisp 那行云流水般的表处理手段一见倾心。后来使用 Python 做数据处理时，语言内置的高阶函数更是得心应手。工作之后开始使用 Java，一开始的时候仿佛回到了石器时代。

直到后来我找到了 Guava，才终于又可以使用熟悉的方式去操纵集合。

函数式风格的表处理让开发者从底层的迭代处理中解放出来，从更加抽象的层面来思考问题。然而，Guava 仅仅实现了 map、filter 者两个高阶函数，并没有实现 reduce。

<!-- more -->

# 映射 #

表处理中有这样一个操作，将某个函数分别应用到集合的每个元素上，将返回值集合以列表返回，这个操作一般命名为 map，实现为一个高阶函数。

在 Guava 中，提供同样操作的方法是一个静态函数，Collections2#transform。按照 map 函数的约定俗成，第一个参数是被操作集合，第二个参数是操作函数，返回值是结果集合。也许是出于避免函数名和变量名冲突的考虑，Guava 没有像其他语言那样使用 map 作为函数名，而是使用了 transform。（想想我们写的生产代码里面有多少个哈希表以 map 命名，回去面壁……）

```java
Function<Integer, Integer> square = new Function<Integer, Integer>() {
    public Integer apply(Integer input) {
        return input * input;
    }
};
Collections2.transform(Lists.newArrayList(1, 2, 3), square);//[1, 4, 9]
```

# 过滤 #

高阶函数 filter 的作用和它的名字一样，就是个过滤器，将一个布尔型函数应用到集合的每个元素上，然后根据函数的返回值决定元素是否留在返回值集合中。

在 Guava 中，Collections2#filter 提供了 filter 的功能。这一次 Guava 使用了约定俗成的名字。

```java
Predicate<Integer> isOdd = new Predicate<Integer>() {
    public boolean apply(Integer input) {
        return (input & 1) != 0;
    }
};
Collections2.filter(Lists.newArrayList(1, 2, 3), isOdd);//[1, 3]
```

# 折叠 #

折叠这个操作是把一个列表归并成一个元素，在一些语言中这个操作被称作 fold，另一些称之为 reduce。

在 Python 中，我们假如我们想要实现列表元素的累加，可以写成下面这个样子：

```python
reduce(lambda x, y: x + y, [1,2,3])
```

在 Clojure 中，我们可以写的更加简单：

```clj
(reduce + [1 2 3])
```

可惜的是，Guava 并没有实现折叠操作。早在 2009 年的时候就有人在 Guava 的 issue[^1] 中提出，为 可迭代的集合增加一个 fold 方法，issue 讨论中大家也是贴出了各自的实现。然而，最后在 15 年 4 月 11 日这个 issue 被关闭了，Guava 的维护者决定不再向 Guava 添加函数式编程的特性，因为 Java 8 出来了。

[^1]: [Add a fold method for Iterables][1]

虽然 Guava 的很多特性都在 Java 8 中得到了实现，但是并不是所有的开发者都能用上 Java 8。对于我们这些不得不使用 Java 7 甚至 Java 6 的开发者来说，Guava 就是帮助我们提升开发效率的神器。


# 源码分析 #

## Collections2.transform ##

使用代理模式来实现延迟求值是 Guava 的惯用技法，transform 函数也不例外。

```java
public static <F, T> Collection<T> transform(Collection<F> fromCollection,
    Function<? super F, T> function) {
  return new TransformedCollection<F, T>(fromCollection, function);
}
```

TransformedCollection 就是代理类，把传入的被操作集合和操作函数代理了起来，直到必要的时候才调用操作函数获取结果元素。

```java
static class TransformedCollection<F, T> extends AbstractCollection<T> {
  final Collection<F> fromCollection;
  final Function<? super F, ? extends T> function;
  TransformedCollection(Collection<F> fromCollection,
      Function<? super F, ? extends T> function) {
    this.fromCollection = checkNotNull(fromCollection);
    this.function = checkNotNull(function);
  }
  @Override public void clear() {
    fromCollection.clear();
  }
  @Override public boolean isEmpty() {
    return fromCollection.isEmpty();
  }
  @Override public Iterator<T> iterator() {
    return Iterators.transform(fromCollection.iterator(), function);
  }
  @Override public int size() {
    return fromCollection.size();
  }
}
```

因为 Collection 的元素只能通过迭代器去遍历访问，所有我们只需要跟着 iterator 方法走下去，就能搞清楚 transform 的实现。

```java
public static <F, T> Iterator<T> transform(final Iterator<F> fromIterator,
    final Function<? super F, ? extends T> function) {
  checkNotNull(function);
  return new TransformedIterator<F, T>(fromIterator) {
    @Override
    T transform(F from) {
      return function.apply(from);
    }
  };
}
```

Iterators.transform 函数返回了一个闭包，继承自抽象类 TransformedIterator。闭包中定义了操作函数的调用时机，那么我们接下来要找的就是 TransformedIterator#transform 的调用者了。

```java
abstract class TransformedIterator<F, T> implements Iterator<T> {
  final Iterator<? extends F> backingIterator;
  TransformedIterator(Iterator<? extends F> backingIterator) {
    this.backingIterator = checkNotNull(backingIterator);
  }
  abstract T transform(F from);
  @Override
  public final boolean hasNext() {
    return backingIterator.hasNext();
  }
  @Override
  public final T next() {
    return transform(backingIterator.next());
  }
  @Override
  public final void remove() {
    backingIterator.remove();
  }
}
```

TransformedIterator 这个抽象迭代器在 next 方法中完成了对 transform 的调用。也就是说，操作集合元素的时机被推迟到了遍历时，没有买卖就没有杀害！（什么鬼……）

终于集齐全部碎片，把拼图完成了！Guava 为了实现这个代理模式和延迟求值可谓煞费苦心，嵌套了一层又一层的。可见把代码写到及格也许只要几分钟，写到接近满分可就没那么容易了。


[1]: https://github.com/google/guava/issues/218

