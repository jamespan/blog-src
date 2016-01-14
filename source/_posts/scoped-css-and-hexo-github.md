title: "Scoped CSS 与 Github 挂件"
date: 2015-06-03 12:48:04
tags:
  - CSS
  - Blogging
categories:
  - Study
hljs: true
cc: true
comments: true
thumbnail: http://ww1.sinaimg.cn/large/e724cbefgw1esqttwyc4tj205p02jmx5.jpg
---

最近协助小师妹搭建 Hexo 博客的时候，发现官网的插件列表里面多出了好些插件，其中有一个酷炫的 Github 挂件让我心动不已。

之前我用的 Github 挂件是从开源中国社区的页面上抠下来的，勉强能用，但是和这个挂件比起来就差的远了。

<!-- more --><!-- indicate-the-source -->

# 命令崩坏 #

在充满期待的心情中安装了 [hexo-github][5] 插件，迎接我的却是 hexo 的崩坏。除了 server 命令能够照常运行，其余的命令几乎都没法结束退出，仿佛遭遇了死循环。

本想放弃这个插件，但是又实在舍不得那狂拽酷炫的界面和动效，于是我只好硬着头皮翻看插件的源码。

在代码各个部位插入 print 之后，似乎没有发现死循环存在的痕迹。于是我只好开始二分法，一半一半的去注释代码。上古时期流传下来的手段总是好用的，我很快抓到了导致命令无法退出的元凶，就是下面这行代码。

```js
nunjucks.configure(__dirname);
```

发现凶手又能怎样，我又不能轻易把这行代码删去。一开始的时候我还是习惯性的瞎改，希望能够碰到死耗子。各种尝试无果后，我只能向 Google 屈服，老老实实查看文档。

nunjucks 是一个来自 Mozilla 的模板引擎，这行代码的作用是初始化引擎的配置[^1]。我注意到一个默认参数 watch，如果不传任何值，watch 默认为 true，即监听文件的变更并重新渲染。

[^1]: [Nunjucks - Documentation - configure][1]

既然监听都用上了，那么死循环也就是在这里出现的了。我给 configure 函数多传了一个参数，让它不去监听文件变化，于是 Hexo 的命令们又可以正常结束了。

```js
nunjucks.configure(__dirname, {watch: false});
```

# 样式崩坏 #

把 Hexo 弄好之后，本以为万事大吉，没想到一波方平一波又起。这次是 Github 挂件把页面的样式弄坏了，使用了挂件的页面，Header 短了一截，看起来各种不和谐。

![Header 被 Github 挂件玩坏了](http://ww2.sinaimg.cn/large/e724cbefgw1esqn99rqrij20rb046wez.jpg)

虽然我知道肯定是哪个 CSS 没写好，把影响范围扩展到了整个页面，但是我一时没法定位，在 Chrome 中各种调整 CSS 都没有效果。

无奈翻看源码，这个插件的 CSS 是使用 less 生成的，找到一个叫做 style.less 的文件，内容看起来和 CSS 差不多。

我在其中发现一条万恶的样式，很黄很暴力，附上 Github [传送门][2]。

```
* {
  box-sizing: border-box;
}
```

什么鬼啊，直接把所有元素的样式都改了啊！果断把它干掉。

可是干掉之后，Header 是好了，又轮到 Github 挂件崩坏了，左下角出现大片空白。

![Github 控件的样式被我玩坏了](http://ww1.sinaimg.cn/large/e724cbefgw1esqnxn91ftj20i505wq3d.jpg)

怎么才能把样式的作用范围限定在某个 DOM 树？我想到了之前看过的一个 CSS3 特性，scoped[^2]。

[^2]: [Saving the Day with Scoped CSS][3]

于是我尝试着去修改 tag.html，在挂件所在的结点加上限定作用域的样式。

```html
<div id="{{id}}" style="padding: 8px 0px; width: 100%;">
	<style type="text/css" scoped>
	* {box-sizing: border-box;}
	</style>
</div>
```

出乎我的意料，这样修改之后，样式还是把 Header 破坏了。也许是 Chrome在是实现 scoped css 的时候有bug，或者根本就没有实现，或者实现了然后作为试验特性没有开启，反正这种写法在 Chrome 里面是崩坏的，到了 Firefox 是好的。

为了让样式更具通用性，我只好放弃 scoped css，老老实实使用选择器。于是我把 tag.html 里面的修改复原，在 style.less 加上下面这段 CSS。

```css
.hexo-github * {
  box-sizing: border-box;
}
```

终于完成了。我把我对 hexo-github 的变更提交了 [Pull Request][4]，希望能够合并到主干，让其他人不要重复我的工作。

{% github JamesPan hexo-github 959ade0 %}



[1]: https://mozilla.github.io/nunjucks/api.html#configure
[2]: https://github.com/akfish/hexo-github/blob/442e27dc38f1f26742645a254cdb37d7762058bf/static/style.less#L34:L37
[3]: https://css-tricks.com/saving-the-day-with-scoped-css/
[4]: https://github.com/akfish/hexo-github/pull/1/files
[5]: https://github.com/JamesPan/hexo-github

