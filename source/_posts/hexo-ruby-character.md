title: hexo-ruby-character：写作 OO 读作 XX
tags:
  - Blogging
  - Node.js
  - Hexo
categories:
  - Study
cc: true
comments: true
date: 2015-06-21 21:06:31
thumbnail: http://ww1.sinaimg.cn/large/e724cbefgw1etcx5af7hlj204v04vdfn.jpg
---

关于「写作 OO 读作 XX」这种事情，虽然已经玩了许久，但是还是感觉挺有意思。其实「写作 OO 读作 XX」是日文书写中的[旁注标记][1]，用于表达「OO 的正确含义是 XX」[^1]。

[^1]: [写作oo读作xx - 萌娘百科 万物皆可萌的百科全书][2]

早些时候，当我想要做旁注标记的时候，只能先把文字写上，发音写在括号里。其实这样的做法是很痛苦的，因为拼音的声调实在是太难输入了。

<!-- more --><!-- indicate-the-source -->

后来，iOS 的[应用商店][3]里出现了一款叫做「写(dú)」的 App，对我而言简直就是福音，我经常逛的一个推广优质应用的网站——少数派也专门为这个 App 写了博文，《[喜(sàng)闻(xīn)乐(bìng)见(kuáng)：写(dú)][11]》。

从那以后，当我需要做旁注标记的时候，写(dú) 就是我最趁手的工具。直到这两天，我在给同事科普什么叫「[鬼畜][4]」的时候，无意间进入了[绅士][5]词条，然后就看到了这种黑科技般的注音方式！

> <b>绅士</b>，或者<a href="http://zh.moegirl.org/ACG" title="ACG">ACG</a>界更常见的写法是<big><big><ruby><b>绅</b><rp>（</rp><rt>biàn</rt><rp>）</rp></ruby><ruby><b>士</b><rp>（</rp><rt>tài</rt><rp>）</rp></ruby></big></big>或<big><big><ruby><b>绅</b><rp>（</rp><rt>hen</rt><rp>）</rp></ruby><ruby><b>士</b><rp>（</rp><rt>tai</rt><rp>）</rp></ruby></big></big>。

这种注音效果果然就是我想要的！一开始我还以为是用 CSS 实现的，翻看页面源码发现是 ruby 标签，之前从没见过，果然是图样图森破了。再看 Wiki 页面的源码，发现这是通过 [Ruby Template][6] 实现的，再向上游追溯，就是 Wikipedia 了。

# A Better Wheel #

这么好玩的东西，我的博客也要用~于是经过我一个中午的 coding，一个全新的 hexo 插件——[hexo-ruby-character][8] 就来到了世界上。

我以 MIT 许可证将源码托管在 Github 上，欢迎交流。

从表面上看，这个插件其实是 Wiki 里面 Ruby Template 的一个复刻，算是另一个轮子，为什么我会认为它是一个更好的轮子？

先看 Wikipedia 给的例子。

{ruby|飞机|fēijī}{ruby|场|chǎng} → <ruby><rb>飞机</rb><rp>（</rp><rt>fēijī</rt><rp>）</rp></ruby><ruby><rb>场</rb><rp>（</rp><rt>chǎng</rt><rp>）</rp></ruby>

其实整个旁注标记中最难以输入的部分，就是拼音。而在 hexo-ruby-character 中，拼音不再是不必可少的了，取而代之的是汉字，用汉字给汉字注音。字音转换这种事情，自然是要交给机器代劳，不仅如此，还要站在巨人的肩膀上。

{ ruby 佐天泪子|掀裙狂魔 } → {% ruby 佐天泪子|掀裙狂魔 %}

在旁注标记中，字音不同是最常见的用法。假如需要标注真正的发音，那就更简单了。

{ ruby 飞机场 } → {% ruby 飞机场 %}

默认开启了分词之后，多音字的字音转换基本上不成问题，比如它能够区分{% ruby 星宿 %}和{% ruby 宿敌 %}，{% ruby 家长 %}和{% ruby 长度 %}这种弱爆了的多音字测试更是不在话下。而这一切特性，都是 [pinyin][9]，以及它背后的 jieba 分词所提供的。

hexo-ruby-character 默认的行为是在拼音之间添加空格来区分音节。当然，如果不喜欢默认的字音转换，直接像 Wiki 一样写拼音也是可以的。

{ ruby 飞机|fēijī }{ ruby 场|chǎng } → {% ruby 飞机|fēijī %}{% ruby 场|chǎng %}

至于日语或者其他国家的语言之类的，自然也是不在话下。

{ ruby 超電磁砲|レールガン } → {% ruby 超電磁砲|レールガン %}

Happy hacking! 为了让更多的人用到它，我向 Hexo 的插件列表提交了 [Pull Request][10]，~~希望能合并到主干~~~，它现在已经在 Hexo 的[插件列表][12]里面了。

![Hexo Plugin](http://ww1.sinaimg.cn/large/e724cbefgw1etd3n5q53ij20mh06wdg3.jpg)

[1]: https://zh.wikipedia.org/wiki/旁註標記
[2]: http://zh.moegirl.org/zh-cn/写作oo读作xx
[3]: https://itunes.apple.com/cn/app/xie-du/id824653857
[4]: http://zh.moegirl.org/鬼畜
[5]: http://zh.moegirl.org/绅士
[6]: http://zh.moegirl.org/Template:Ruby
[7]: https://www.npmjs.com/package/hexo-ruby-character
[8]: https://github.com/JamesPan/hexo-ruby-character
[9]: https://github.com/hotoo/pinyin
[10]: https://github.com/hexojs/site/pull/66
[11]: http://sspai.com/25440
[12]: https://hexo.io/plugins/#hexo-ruby-character