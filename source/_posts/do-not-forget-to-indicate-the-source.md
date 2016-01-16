title: 如果你转载文章不注明出处
tags:
  - Tool
  - Hexo
  - Node.js
categories:
  - Study
thumbnail: //i.imgur.com/Qy7Aw7C.gif
hljs: true
cc: true
comments: true
date: 2016-01-15 23:43:44
---

我们在独立博客上不断地创造内容，不断的分享知识，最希望得到的，也许是读者的回应。我们希望知道自己的分享被多少读者浏览，于是我们使用了各种各样的访问统计。我们希望读者能够和我们展开讨论、交换观点，于是我们维护了文章评论区。为了鼓励和促进分享，我们在知识共享协议下发布博文，要求转载文章的同时附上作者信息，演绎之后使用相同的知识共享协议。

但是这个世界总是不缺破坏规则的人。

<!-- more --><!-- indicate-the-source -->

## 背景 ##

我写博客一年多了，如今也有好几个网站在用爬虫抓取我的博文。其中有两家网站比较守规矩，至少还在文首给出了原文链接，如果读者从这两家网站看到我的分享，想要讨论还有个去处。其他的网站就是名副其实的垃圾站点了，把文章爬了去，连个出处都没有，还把作者信息给篡改成了垃圾站长。

之前我虽然心中不满，却也不愿意为了这些事情浪费时间。直到最近我看到一个博主，为了反抗垃圾站点的恶意爬取，已经到了不惜牺牲阅读体验的地步，截图出自「[基于最少使用频次的LFU缓存淘汰算法][1]」。

![](//i.imgur.com/ALauRuQl.png)

杀敌一千，自损八百，这位博主也是蛮拼的。我不愿意牺牲直接访问我的博客的读者的阅读体验，但是如果能借鉴这位博主的方法，给那些垃圾站点制造一些麻烦，我是十分乐意的。

当然，我更不希望在给垃圾站点制造麻烦的同时，给我的博文创作也带来麻烦。

## 设计 ##

为了不牺牲读者的阅读体验，也为了不牺牲我的创作体验，我决定使用一种优雅的方式来解决问题。我要实现一个 Hexo 插件，能够在我指定的位置，插入一段类似于「转载请注明出处」的信息，除此之外，还要做到如下两点：

1. 插入的「转载请注明出处」信息在博客页面中不展示，在爬虫站点页面展示
2. 卸载插件后，无需修改博文源码，「转载请注明出处」信息自动消失

## 实现 ##

目前我的博客已经用上了这个插件。如果需要，可以访问 [JamesPan/hexo-filter-indicate-the-source][2] 获取详情。为了面向更广泛的使用人群，我在 Github 分享的源码，其 REAMDE 使用英文书写，自我感觉还算详细，基本上该有的都有了。这里使用中文写一篇博客，方便不擅长英文的中文 Hexo 用户。

由于插件逻辑十分简单，以至于明显没有 bug，同时和 Hexo 核心功能耦合紧密，不便于写单元测试，我就偷懒没有搞单元测试和持续集成了。

### 安装 ###

在 Hexo 博客目录执行如下命令，安装插件并修改 `pacakge.json`。

```bash
npm install hexo-filter-indicate-the-source --save
```

### 配置 ###

约定俗成，Hexo 插件一般会在站点级别的 `_config.yaml` 中识别配置信息。如果我们什么都没做，那么就相当于 `hexo-filter-indicate-the-source` 使用了如下的配置：

```
indicate_the_source:
  enable: true
  pattern: indicate-the-source
  render_engine: ejs
  element_class: indicate
  domain_white_list:
    - localhost
  template: "<blockquote>Reproduced please indicate the <a href='<%- post.permalink %>'>source</a>!</blockquote>"
```

pattern 域是这个插件要识别的模式，默认配置中 pattern 域的值为 `indicate-the-source`，那么插件就会去寻找符合正则模式 `<!-- indicate-the-source -->` 的字符串，全部替换为「转载请注明出处」信息。这里使用注释作为信息插入位置，巧妙地实现了功能点 2。

render\_engin 域是渲染字符串模版要使用的渲染引擎，我的博客使用 `ejs` 来实现主题，于是我也就习惯了使用 ejs 渲染引擎，习惯使用其他引擎的用户可以自行替换成 swig 之类的，如果使用 `none`，插件会跳过渲染。

element\_class 域是让用户指定插入的「转载请注明出处」信息使用的 CSS class，一方面允许用户给这段信息定制样式，另一方面实现功能点 1 的时候需要借助这个 class，如果发现当前页面域名在白名单中，就把 class 为 element\_class 的 DOM 节点删除，从而实现隐藏「转载请注明出处」信息。

domain\_white\_list 域就是上面提到的域名白名单，默认是 localhost，一般来说，用户需要给出他的博客的域名，比如我就需要在白名单中添加 blog.jamespan.me。

template 域就是我们最重要的「转载请注明出处」信息的模板了，渲染这个模板的时候，插件会传入一个 post 变量，里面有当前正在处理的文章的元数据，具体细节参考 [Hexo 文档][3]。

### 示例 ###

我使用如下配置，

```
indicate_the_source:
  pattern: indicate-the-source
  enable: true
  render_engine: ejs
  element_class: source
  domain_white_list:
    - blog.jamespan.me
    - jamespan.me
    # - localhost
  template: "<blockquote><p>转载请注明出处：<%- post.permalink %></p><p>访问原文「<a href='<%- post.permalink %>'><%- post.title %></a>」获取最佳阅读体验并参与讨论</p></blockquote>"
```

然后在文章的 Markdown 源码中找一处插入 `<!-- indicate-the-source -->`，

![](//i.imgur.com/C2EMBmFl.png)

就会得到这样的效果：

![](//i.imgur.com/Pv2YQeal.png)

注意，我在域名白名单配置中特意注释了 localhost，而截图页面是访问的运行在本地的 hexo server，所以能看到插入的信息。如果把注释解开，就看不到了。

## 其他 ##

自我感觉效果不错，我希望能够给之前写的文章也插入这个信息。但是我已经有将近 100 篇博文了，一篇篇人肉去改太麻烦，我想到了一个取巧的方案。

对于已经存在的文章，我可以在注释 `<!-- more -->` 的后面追加 `<!-- indicate-the-source -->`，反正每篇文章都有这个 more 注释，反正「转载请注明出处」信息放在哪里并不重要，放了就差不多了。

于是我用一行命令就搞定了过往博文的处理。

```bash
find ./source/_posts -name "*.md" | xargs sed -i "s/<\!-- more -->/<\!-- more --><\!-- indicate-the-source -->/"
```

## 总结 ##

这个插件是我有想法之后连夜写出来的，近期会提交 PR 尝试把它添加到 Hexo 官网的插件列表。

希望这个插件能够帮到同为 Hexo 用户，同样不满垃圾站点无断转载的你~



[1]: http://xiaorui.cc/2015/04/20/基于频次的缓存淘汰算法之lfu/
[2]: https://github.com/JamesPan/hexo-filter-indicate-the-source
[3]: https://hexo.io/docs/variables.html#Page_Variables


