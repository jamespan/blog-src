title: SVN 连接超时与 http-timeout 参数
tags:
  - Subversion
  - Tool
categories:
  - Work
cc: true
comments: true
hljs: true
date: 2015-04-15 01:08:28
---

我厂大部分项目使用 SVN 进行版本控制，只有一些新的项目，然后项目的开发者们都喜欢使用 Git，才会使用 Git 和 Gitlab 进行代码托管。

我正在开发的一个项目就是这种情况，主应用托管在 SVN 上，由我亲自搭建的后台应用托管在 Gitlab，然后另一个新搭建的半后台应用由于某种原因，又使用了 SVN。

最近我在使用 SVN 的时候遭遇了奇怪的问题。提交和更新都没有问题，唯独拉取提交记录的时候，总是失败，无论是用 IDEA 还是命令行。错误信息是类似下面这样的。

```
svn: E175012: Connection timed out
```

<!-- more -->

一开始的时候我怀疑是 SVN 的版本比较低，于是用 brew 安装了最新的稳定版，问题依旧。

使用错误码在 Google 上一番搜索之后，发现一个参数，http-timeout 或许能够帮助解决问题。

接下来直接搜索 http-timeout，结果找到一篇很长的英文文档，[Runtime Configuration Area][1]。当时我随便扫了扫，没有仔细阅读。我直接在文章中搜索 http-timeout，结果第一个出现的位置是关于 Windows 注册表的，第二个就是介绍参数的作用、单位之类的，对于我调整参数没什么帮助。

无意间我从这篇文档中看到，用户对 SVN 的自定义配置在 ~/.subversion 目录。于是我直接切换到这个目录，然后用 ack 命令搜索 http-timeout，果然被我找到了。

从配置上看，超时时间被设置成了 10s。于是我试着把超时时间调整为 60s，接着执行 svn log 查看提交记录，果然成功获取到记录，不再超时了。


[1]: http://svnbook.red-bean.com/en/1.7/svn.advanced.confarea.html

