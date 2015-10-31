title: 持续部署我的博客，舍弃的与得到的
tags:
  - Tool
  - Blogging
categories:
  - Study
cc: false
hljs: true
thumbnail: //i.imgur.com/dADNdHI.png
comments: false
---

持续部署是敏捷开发中的概念，是持续集成的延伸。大体的外在特征是代码合并到主干之后，集成系统自动地把主干代码部署到生产环境。

现在 Github 上大量的开源软件都在使用一个叫 [Travis CI][1] 的服务来做持续集成，也就是在代码推到 Github 之后，Travis CI 根据位于项目根目录的 `.travis.yml` 中的描述来构建集成环境、运行测试并产出集成报告。

<!-- more -->

项目维护者们还可以把 Travis CI 产出的测试结果、覆盖率等等指标，通过 [Shields.io][2] 生成一个个的「badge」放在 README 最开始的地方，仿佛一个军人骄傲地向世人展示胸前的勋章。

之前我的博客虽然部署在 Github 和 CNPaas 上，但是博客的源码，也就是符合 Hexo 约定的那个保存博文和主题的目录，一直没有纳入版本控制，就这么危险地放在笔记本里面。还好在过去一年多的时间里，我的 Macbook 一直足够稳定，没有让我陷入丢失博客源码的尴尬境地。

最近我打算尝试一下把博客源码托管到 Github，然后借助 Travis CI 实现持续部署。说是持续部署，其实只是一个噱头，因为我把博客源码合并推到主干的动作，连持续集成都算不上，顶多算是自动部署罢了，因为我推的不是可测试的代码，而是不可测试的内容。

审视了一下我现在的博客源码，似乎需要做一定程度的重新组织才能放心地交给 Travis CI 去部署。

首先是博客主题。我的主题是从别人那里 fork 出来的，自己做了很多的修改，平时也有推到自己的分支里面。当前我面临两个选择，一个是把主题目录纳入博客目录的版本控制，一个是使用 「Git 子模块」 来管理。假如选择方案一，那么从今以后对主题的修改，我需要先在博客目录中改好之后，手动地把变更同步到维护主题的仓库中，这简直是作死。于是我只好选择 submoudle。

然后是博客的内容目录。由于历史原因，早期的时候我博客中的图片是跟随着页面直接部署到 Github 的，后来使用微博图床后，还是出于懒惰遗留了一批博文没有把图片替换干净。这次我不想把这些图片再推到 Github 去了，于是给遗留图片来了个大扫除，全都搞到图床上去了。

在本地正确建立了仓库以及子模块后，我把源码推送到 Github，开始研究 Travis CI，参考 Hexo
作者的博文「[用 Travis CI 自動部署網站到 GitHub][3]」，然后更进一步处理了子模块、多部署等。

对于第一次使用 Travis CI 的我们来说，先去 Travis CI 的网站用 Gtihub 账户登录，然后从 Travis CI 读取到的仓库列表中选一个要做持续集成的项目。然后从命令行中把 pwd 切换至项目的根目录，开始咔咔咔敲命令，最好顺便把梯子开启。

先安装 Travis CI 的命令行客户端，然后用 Github 账户登录。

```bash
gem install travis
travis login --auto
```

然后生成一对不带密码的 RSA 公私钥，专门给 Travis 部署代码到 Github 用。为什么不用平时我们常用的公钥？因为一会要把私钥上传的，所以这对公私钥基本上是暴露在互联网上了，平时用的那对密钥可不能这么随意对待。

```
ssh-keygen -f ~/.ssh/travis
touch .travis.yml
travis encrypt-file ~/.ssh/travis --add
mkdir .travis
mv travis.enc ./.travis
```

创建公私钥后需要调用 travis 客户端去对私钥做加密，并把解密操作写入 `.travis.yml` 中。travis 会自动读取本地仓库中的信息，猜测当前项目对应的 Github repo。如果加密过程看到如下错误，说明 travis 猜不出我们要把私钥加密给哪个仓库用。

> `Can't figure out GitHub repo name. Ensure you're in the repo directory, or specify the repo name via the -r option (e.g. travis <command> -r <owner>/<repo>)`

直接按照错误提示操作就好了。

travis 把加密后的私钥放在当前目录，文件命名策略是「私钥文件名.enc」。我们在当前目录创建一个隐藏目录，用来放 travis 相关的杂物，比如这个加密私钥。

[1]: https://travis-ci.org
[2]: http://shields.io
[3]: http://zespia.tw/blog/2015/01/21/continuous-deployment-to-github-with-travis/
