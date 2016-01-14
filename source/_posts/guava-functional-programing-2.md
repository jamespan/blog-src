title: Guava 是个风火轮之函数式编程(2)
tags:
  - Java
  - Guava
categories:
  - Study
cc: true
hljs: true
math: true
comments: true
date: 2015-03-30 20:25:06
---

# 前言

[函数式编程](http://en.wikipedia.org/wiki/Functional_programming)是一种历久弥新的编程范式，比起[命令式编程](http://en.wikipedia.org/wiki/Imperative_programming)，它更加关注程序的执行结果而不是执行过程。Guava 做了一些很棒的工作，搭建了在 Java 中模拟函数式编程的基础设施，让我们不用多费手脚就能享受部分函数式编程带来的便利。

Java 始终是一个面向对象（命令式）的语言，在我们使用函数式编程这种黑魔法之前，需要确认：同样的功能，使用函数式编程来实现，能否在**健壮性**和**可维护性**上，超过使用面向对象（命令式）编程的实现？

## Predicate ##

Predicate 接口是我们第二个介绍的 Guava 函数式编程基础设施。

<!-- more --><!-- indicate-the-source -->

下面这段代码是去掉注释之后的 Predicate 接口。

```java
@GwtCompatible
public interface Predicate<T> {
  boolean apply(@Nullable T input);
  @Override
  boolean equals(@Nullable Object object);
}
```

它看起来就是一个简化版本的 Function，除了指定返回值的类型为 boolean 之外，没有其他的差别了。

下面我们定义一个简单的谓词函数，判断一个字符串的长度是否小于10。

```java
Predicate<String> lengthLessThen10 = new Predicate<String>() {
    public boolean apply(String input) {
        return input.length() < 10;
    }
};
lengthLessThen10.apply("lessThen10");//false
```

这里我们实例化了一个谓词仿函数，能且只能判断一个字符串的长度是否小于 10。假如我们希望得到更加通用的代码，能够根据不同的参数得到判断字符串长度小于不同长度的谓词，我们就需要用到函数式编程中一种称为“柯里化”的技术。

```java
Function<Integer, Predicate<String>> lengthLessThen = new Function<Integer, Predicate<String>>() {
    public Predicate<String> apply(final Integer input) {
        return new Predicate<String>() {
            public boolean apply(String str) {
                return str.length() < input;
            }
        };
    }
};
lengthLessThen.apply(10).apply("lessThen10");//false
```

首先，我们定义了一个 Function，接受 Integer 类型的参数，返回 Predicate 实例；在实例化 Predicate 的时候，我们访问了匿名类外部的变量，也即 Function 实例的 apply 方法的参数，由于 Java 语言的限制，匿名类内部用到的外部变量必须声明为 final。

## Predicates ##

Predicates 是 Guava 中与 Predicate 接口配套使用的工具类，提供了一些非常有用的工具类，比如使用 and 和 or 组合多个谓词，还有 not 将谓词的条件取反。和 Functions 比较类似的是，Predicates 提供了一个 compose 方法，用于组合 Function 和 Predicate。

Predicates 是一个方法工厂，返回各种各样的 Predicate 实例。

![](http://ww1.sinaimg.cn/large/e724cbefgw1exdxoxkpk7j20de0c8ad1.jpg)

Predicates#alwaysTrue 返回一个永真谓词，Predicates#alwaysFalse 返回一个永假谓词。

Predicates#isNull 返回的谓词在参数为 null 时为真，Predicates#notNull 则返回与之相反的谓词。

Predicates#equalTo 返回一个谓词，当谓词参数与 Predicates#equalTo 的参数在逻辑上等价时为真。

Predicates#instanceOf 返回一个谓词，当谓词参数是 Predicates#instanceOf 的参数的实例时为真。

Predicates#assignableFrom 返回一个谓词，当谓词参数表示的类和 Predicates#assignableFrom 的参数表示的类，有着相同或者超类、接口关系的时候为真。

Predicates#in 返回一个谓词，当谓词参数在 Predicates#in 的参数表示的集合中时为真。

Predicates#contains 返回一个谓词，当谓词参数表示的字符串中包含 Predicates#contains 的参数所表示的正则模式时为真。Predicates#containsPattern 的功能与之类似。

我们可以看到，除了最先介绍的 4 个工厂函数，其余工厂函数返回的谓词，都和工厂函数的参数有着紧密的绑定关系，类似于我们在介绍 Predicate 时提到的闭包。然而 Guava 在实现中为了给用户更好的体验，没有直接使用闭包，而是使用了许多的内部类来支撑这些工厂函数，具体细节我们在源码分析部分展开。


接下来是谓词之间的与或非运算，还有和函数组合称为新的谓词。

Predicates#not 返回一个取反之后的谓词，Predicates#and 返回两个或多个谓词做与运算之后的谓词，Predicates#or 返回两个或多个谓词做或运算之后的谓词，Predicates#compose 将参数中的 Function 的返回值作为另一个参数谓词的参数，返回新的谓词。

### 源码分析 ###

我们先看看支撑了 Predicates#alwaysTrue 等 4 个谓词工厂函数的内部类，ObjectPredicate。

```java
enum ObjectPredicate implements Predicate<Object> {
  /** @see Predicates#alwaysTrue() */
  ALWAYS_TRUE {
    @Override public boolean apply(@Nullable Object o) { return true; }
    @Override public String toString() { return "Predicates.alwaysTrue()"; }
  },
  /** @see Predicates#alwaysFalse() */
  ALWAYS_FALSE {
    @Override public boolean apply(@Nullable Object o) { return false; }
    @Override public String toString() { return "Predicates.alwaysFalse()"; }
  },
  /** @see Predicates#isNull() */
  IS_NULL {
    @Override public boolean apply(@Nullable Object o) { return o == null; }
    @Override public String toString() { return "Predicates.isNull()"; }
  },
  /** @see Predicates#notNull() */
  NOT_NULL {
    @Override public boolean apply(@Nullable Object o) { return o != null; }
    @Override public String toString() { return "Predicates.notNull()"; }
  };

  @SuppressWarnings("unchecked") // safe contravariant cast
  <T> Predicate<T> withNarrowedType() { return (Predicate<T>) this; }
}
```

这些谓词的构造过程无需来自工厂函数的参数，因此全都用枚举类构造成了单例，类似的手法在 Functions 类中也使用过。

这里比较有意思的代码是 withNarrowedType 函数。结合 Predicates#alwaysTrue 我们就容易明白这段代码的用途。

```java
public static <T> Predicate<T> alwaysTrue() {
  return ObjectPredicate.ALWAYS_TRUE.withNarrowedType();
}
```

工厂函数返回的 Predicate 支持泛型，然而 ObjectPredicate 内部的单例却是 Predicate 接口的 Object 类型实现。这段代码其实就是把泛型参数为 Object 的 ObjectPredicate 实例，强制转换为用户指定的泛型参数的谓词。

下面我们以支撑 Predicates#or 功能的内部类 OrPredicate 为例，分析类似功能的实现。

```java
private static class OrPredicate<T> implements Predicate<T>, Serializable {
  private final List<? extends Predicate<? super T>> components;

  private OrPredicate(List<? extends Predicate<? super T>> components) {
    this.components = components;
  }
  @Override
  public boolean apply(@Nullable T t) {
    // Avoid using the Iterator to avoid generating garbage (issue 820).
    for (int i = 0; i < components.size(); i++) {
      if (components.get(i).apply(t)) {
        return true;
      }
    }
    return false;
  }
  @Override public int hashCode() {
    // add a random number to avoid collisions with AndPredicate
    return components.hashCode() + 0x053c91cf;
  }
  @Override public boolean equals(@Nullable Object obj) {
    if (obj instanceof OrPredicate) {
      OrPredicate<?> that = (OrPredicate<?>) obj;
      return components.equals(that.components);
    }
    return false;
  }
  @Override public String toString() {
    return "Predicates.or(" + COMMA_JOINER.join(components) + ")";
  }
  private static final long serialVersionUID = 0;
}
```

将多个 Predicate 做或操作，无非就是遍历集合，只要有一个谓词为真，则整体为真。

OrPredicate 的实现中，值得关注的地方，都加上了注释。第一个是 apply 函数。这段注释说的是，遍历集合的过程中，为了减少垃圾对象的产生，不使用迭代器，而是直接遍历下标。

使用迭代器的好处是，无论目标集合是什么数据结构，总能保证获取下一个元素的时间复杂度是 $O(1)$，然而根据下标获取元素则没有这个保证，假如用于初始化 OrPredicate 的 List 其实是一个链表，那么用下标遍历集合的时间复杂度就是 $O(N^2)$。

Guava 的设计者肯定不会允许一个平方复杂度的遍历存在，我们接下来看一看究竟是 Guava 是如何保证遍历谓词集合的复杂度不会退化为 $O(N^2)$ 的。

```java
public static <T> Predicate<T> or(
    Iterable<? extends Predicate<? super T>> components) {
  return new OrPredicate<T>(defensiveCopy(components));
}
static <T> List<T> defensiveCopy(Iterable<T> iterable) {
  ArrayList<T> list = new ArrayList<T>();
  for (T element : iterable) {
    list.add(checkNotNull(element));
  }
  return list;
}
```

从工厂函数的实现来看，在用一个谓词集合构造 OrPredicate 之前，这个集合首先被做了一份拷贝，这种操作被称为“防御性拷贝”。如此构造出来的谓词，即使当初用于构建谓词的集合发生了变化，谓词的行为不会随之而变。正是这个防御性拷贝，使得构造出来的谓词不依赖于外部的变量，是一个可重入的函数。同时，防御性拷贝得到的 List 是一个 ArrayList，即使根据下标来遍历列表，复杂度也是 $O(N)$。

下一个注释出现在 hashCode 函数中，解释了为作为参数的谓词集合的哈希值加上一个固定随机值的原因：为了不和 AndPredicate 产生碰撞。考虑这样一个场景，用户用一组谓词，分别通过 Predicates#and 和 Predicates#or 生成两个组合谓词。如果仅仅是使用这组谓词的哈希值作为组合谓词的哈希值，那么这两个不同的组合谓词就会产生哈希碰撞，然后哈希表退化为链表。

最后我们看一看用于判定字符串是否包含正则模式的谓词，Predicates#contains 的实现。这段代码比较长，而且包含了 Guava 开发者对 Java 官方代码的吐槽，比较有趣。

```java
private static class ContainsPatternPredicate
    implements Predicate<CharSequence>, Serializable {
  final Pattern pattern;

  ContainsPatternPredicate(Pattern pattern) {
    this.pattern = checkNotNull(pattern);
  }
  @Override
  public boolean apply(CharSequence t) {
    return pattern.matcher(t).find();
  }
  @Override public int hashCode() {
    // Pattern uses Object.hashCode, so we have to reach
    // inside to build a hashCode consistent with equals.
    return Objects.hashCode(pattern.pattern(), pattern.flags());
  }
  @Override public boolean equals(@Nullable Object obj) {
    if (obj instanceof ContainsPatternPredicate) {
      ContainsPatternPredicate that = (ContainsPatternPredicate) obj;
      // Pattern uses Object (identity) equality, so we have to reach
      // inside to compare individual fields.
      return Objects.equal(pattern.pattern(), that.pattern.pattern())
          && Objects.equal(pattern.flags(), that.pattern.flags());
    }
    return false;
  }
  @Override public String toString() {
    String patternString = Objects.toStringHelper(pattern)
        .add("pattern", pattern.pattern())
        .add("pattern.flags", pattern.flags())
        .toString();
    return "Predicates.contains(" + patternString + ")";
  }
  private static final long serialVersionUID = 0;
}
```

我们关注 hashCode 和 equals 函数。一般来说，这两个函数一旦覆盖就必须同时覆盖，如果只覆盖其中一个就有可能产生极其难以发现的 bug。我们假设逻辑相等的对象有着相同的哈希值，在覆盖这两个方法的时候也需要小心的确保这个假设成立。

我们看看 Guava 开发者吐槽了什么。这两段注释说的差不多是同一个意思，埋怨 Pattern 类的 hashCode 和 equals 都直接使用继承自 Object 的实现，导致他们不得不深入 Pattern 内部，以获取能用来实现这两个函数的东西。

因为我们永远不知道自己设计的类会被使用者用在什么地方，所以有这么一个最佳实践是为所有的类覆盖实现 hashCode 和 equals 函数。接下来我们看看为什么继承自 Object 的实现被 Guava 开发者视为不可用的实现。

我们先说 equals 函数。

```java
public boolean equals(Object obj) {
    return (this == obj);
}
```

equals 函数判断两个对象是否逻辑相等，当且仅当两个对象其实指向同一个对象。这种比较未免太简单粗暴了，完全不是逻辑相等，而是绝对相等。

然后我们看看 hashCode 函数。

```java
public native int hashCode();
```

Object 对象的 hashCode 函数是一个 native 方法，返回的哈希值依赖于对象的内存地址。

所以说，Object 的 hashCode 和 equals 对于那些需要逻辑相等的对象来说都太严格了，判断两个正则模式是否相等，需要一种较为宽松的比较方式。为什么 Guava 开发者选择了 Pattern#flags 和 Pattern#pattern 作为判断两个 Pattern 相等的依据？

考察 Pattern 的构造函数，我们发现它的构造函数最多能够接收两个参数，一个字符串格式的正则表达式，还有一个整型的标志位。

```java
public static Pattern compile(String regex, int flags) {
    return new Pattern(regex, flags);
}
private Pattern(String p, int f) {
    pattern = p;
    flags = f;
    //other codes
}
```

看到这里我们就知道了，只要 Pattern#pattern 和 Pattern#flags 一致，那么两个 Pattern 对象就是一致的。

