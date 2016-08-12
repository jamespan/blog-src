title: Timestamp - 一个关于时间戳的轻应用
tags:
  - JavaScript
  - Tool
categories:
  - Study
cc: true
hljs: true
comments: true
date: 2015-01-19 18:26:13
---

点击[这里][8]访问应用。

# 背景

我在博客给自己开了一个[时间轴][1]页面，这样我的一些心情、一些临时的想法感受就能够通过时间轴记录下来，好处是不依赖于第三方的社交服务。

为了以比较好的效果展示时间轴，同时我希望记录写下心情的时间，我会在每条心情的前面加上一个格式为 `YYYY-MM-DD HH:mm:ss` 的时间戳。

<!-- more --><!-- indicate-the-source -->

之前好几条状态都是在电脑上写的，我可以执行命令 `date +"%F %T" | pbcopy` 直接将时间戳复制到剪贴板。后来我觉得这样还是不方便，需要我从编辑器切到终端再切回编辑器。然后我就用 Python 给 Sublime Text 写了一个小插件，通过快捷键向当前编辑的文本插入时间戳。于是电脑上编辑心情的方案算是比较完美了。

然后我想到，如果电脑不在手边，我又希望记录心情，如何是好？当然要通过手机来记录啦。

然后我开始在 App Store 搜索翻找，希望能找到一个带有输入时间戳功能的输入法、笔记 App，或者直接生成时间戳的 App。事与愿违，没有一个能让我满意。

Notebooks Lite 虽然能够输入时间戳，但是格式不是我希望的。没有同步功能不要紧，大不了我把文本复制到备忘录走 iCloud 同步，时间戳格式不对就好伤，难道我复制到电脑上之后还要手动调整？

那些直接生成时间戳的应用就更不靠谱，连自定义格式的功能都不支持。

既然没有现成的轮子可用，我只好制造一个轮子了。

# 分析

决定自己写一个应用之后，就是技术选型。该用什么方式实现好呢？

一开始我打算直接写一个 iOS App。后来同事@不周建议我可以简单搞，先弄一个轻应用。正好我前不久在没有前端同学帮助的情况下独自搭建了一个后台应用，积累了微薄的前端经验，而且我可以把这个应用挂在我的博客里。

想到我的博客是一个静态站点，我这个应用也是一个静态页面，要想实现功能，就是能用 JavaScript 了。

于是技术方案就此确定，使用 Bootstrap 渲染样式，JavaScript 实现功能。

期望完成后的 Light App 具有如下功能：

1. 计算当前时间
2. 根据给定的格式描述，返回符合格式的时间戳
3. 能够比较方便的把时间戳复制到剪贴板

# 实现

时间的格式化是整个应用的核心，如果这个搞不定，应用就没法实现了。经过一番 Google 之后，我发现了一个库，[Moment.js][2]。看起来完全符合我对时间格式化的要求，还有完善的文档，于是这个问题就算解决了。至于如何指定不同的时间戳格式，可以暂时不考虑，因为我一般只用一种格式。

搞定时间方案之后，就要开始设计页面了。照例先去 Bootstrap 的[实例精选][3]看看有木有可以直接套用的模板。还真被我找到一个，[Justified nav][4]。

把页面源码下载下来一番裁剪，去掉我用不到的页面元素和链接之后，开始修改页面内容为我想要的结果。

一开始的效果是下面这样的。

![](https://ws3.sinaimg.cn/large/e724cbefgw1exdxs7gn6aj208w08wwer.jpg)

绿色 Genreate 按钮的 click 事件绑定了函数，一旦触发就会计算当前时间戳并更新页面显示。如此一来，生成时间戳的功能就算是完成了。

```js
var generate = function() {
    fmt = 'YYYY-MM-DD HH:mm:ss';
    var formated_date = moment().format(fmt);
    $("#timestamp").text(formated_date);
}

$('#generate-button').on('click', function (e) {
    generate();
})
```

# 优化

然后我开始想着怎么把时间戳弄到剪贴板里去。各种 Google 之后遗憾的发现，关于浏览器的剪贴板操作没有纯 JavaScript 的解决方案，即使是 Github 的复制仓库地址的功能，也依赖于一个叫 [ZeroClipboard][5] 的库，而这个库借助的 Flash 来完成复制到剪贴板的操作。

考虑我的应用在 PC 端实现复制到剪贴板是没有意义的，因为我在 PC 端的时候基本不会用到它，而 iOS 端由于浏览器不支持 Flash，ZeroClipboard 根本没法使用。

虽然复制到剪贴板的功能不考虑了，我还是需要设计一种比较方便复制的方案。

## p 标签
现在的时间戳，我是只使用 p 标签包裹的，在我人肉复制的时候，比较难以快速的实现全选，大部分时候需要手动拖曳光标，只有少数运气好的时候会自动全选。

## input 标签

于是我开始考虑使用 input 标签作为时间戳的容器。因为在 input 标签处于焦点的情况下，长按其中的文字，会有一个 popup，可以全选然后复制。使用 input 标签之后为了页面美观，就需要考虑调整 input 的宽度，即 size 属性。

我修改 Generate 按钮的 on_click 函数，生成时间戳之后调整 input 标签的 size，同时将 input 的 click 事件绑定了函数，触发的时候自动全选。

```js
var generate = function() {
    fmt = 'YYYY-MM-DD HH:mm:ss';
    var formated_date = moment().format(fmt);
    $('#timestamp').val(formated_date);
    $('#timestamp').attr('size', formated_date.length-2);
}

var select_all = function(obj) {
    obj.selectionStart = 0;
    obj.selectionEnd = obj.value.length;
}

$('#generate-button').on('click', function (e) {
    generate();
})

$('#timestamp').on('click', function (e) {
    select_all(this)
})
```

这时候效果是下面这样。

![](https://ws3.sinaimg.cn/large/e724cbefgw1exdxsiynuoj207407474e.jpg)

## URL 参数解析

这时候的复制辅助看起来已经可以了，下一步就是想要支持多格式的时间戳生成。

其实我要解决的问题就是从哪里获取用户指定的时间戳格式。首先想到的是用户可以从 URL 中把时间戳格式传进来。如果这是一个可行的方案，那么我就要解决 JavaScript 解析 URL 的问题了。

再次 Google， 翻看 Stack Overflow 上的回答和 Github Gist，基本上都是写一段原生代码去解析，其中有一个写的不错的 [Gist][6]。不过我可不想在我的应用里面写上这么一坨代码。

一番更加努力的搜索之后，我发现了一个已经停止维护了的库，[purl][7]。这个库最新一次代码更新已经是 2 年前了，不过没关系，高老头的 TeX 都那么久没更新了，不还是用的好好的。

然后就是看文档、调试，反正就是能从 URL 把时间格式作为参数传进来了。

```
var generate = function() {
    fmt = $.url().param('format') || 'YYYY-MM-DD HH:mm:ss';
    var formated_date = moment().format(fmt);
    $('#timestamp').val(formated_date);
    $('#timestamp').attr('size', formated_date.length-2);
}
```

后来我想了想，给应用加上了一个导航条，黑白配，萌！萌！哒！

## div + p 标签

就这么用了几天之后，感觉略有不爽。因为使用了自动全选之后，对操作的要求比较高，只能轻轻触碰选区才能触发复制选项，如果操作失误，选择就变成了光标，只能长按 + 全选 + 复制。

![](https://ws1.sinaimg.cn/large/e724cbefgw1exdxsu8rssj20hs08zq36.jpg)

如果不使用自动全选，那么就得点击 + 长按 + 全选 + 复制。

这个动作流程我总感觉可以再缩短一些。

经过一番 Google 之后，我发现 div + p 标签的写法应该可行。据说，浏览器上长按一个区域的空白区，那个区域的文字会被全选，要求是目标文本需要以 div 为容器。

试验之后，果然好用，这个操作流程就缩减为长按 + 复制了。顺带的，之前写的一段 JavaScript 代码也可以被删除。最后我写的驱动这个应用的代码就只剩下面这几行。

```
var generate = function() {
    fmt = $.url().param('format') || 'YYYY-MM-DD HH:mm:ss';
    var formated_date = moment().format(fmt);
    $("#timestamp").text(formated_date);
}

generate();

$('#generate-button').on('click', function (e) {
    generate();
})
```

最终的效果是下面这样。

![](https://ws3.sinaimg.cn/large/e724cbefgw1exdxt6rflij2092082wer.jpg)

# 总结

这是一次为了满足自身需求而进行的开发。虽然总共只用了几个小时的时间，但是样式调整、交互优化却颇费时间。特别是亲身感受到使用中的痛点改进点，回过头来在下班之后进一步调优。

JavaScript 日渐流行，哪天 Node.js 成为各大系统默认集成的基础组件也不是不可能，这个 Timestamp 轻应用就算是我涉足前端开发的 Hello World 好了。

[1]: /timeline
[2]: http://momentjs.com
[3]: http://v3.bootcss.com/getting-started/#examples
[4]: http://v3.bootcss.com/examples/justified-nav/
[5]: http://zeroclipboard.org
[6]: https://gist.github.com/varemenos/2531765
[7]: https://github.com/allmarkedup/purl
[8]: http://www.jamespan.me/lapp/timestamp/index.html
