title: 静态博客遭遇持续部署
tags:
  - CI
  - Blogging
categories:
  - Study
cc: true
hljs: true
thumbnail: //i.imgur.com/dADNdHI.png
comments: true
date: 2015-11-01 01:18:48
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

## Travis

对于第一次使用 Travis CI 的我们来说，先去 Travis CI 的网站用 Gtihub 账户登录，然后从 Travis CI 读取到的仓库列表中选一个要做持续集成的项目。然后从命令行中把 pwd 切换至项目的根目录，开始咔咔咔敲命令，最好顺便把梯子开启。

先安装 Travis CI 的命令行客户端，然后用 Github 账户登录。

```bash
gem install travis
travis login --auto
```

然后生成一对不带密码的 RSA 公私钥，专门给 Travis CI 部署代码到 Github 用。为什么不用平时我们常用的公钥？因为一会要把私钥上传的，所以这对公私钥基本上是暴露在互联网上了，平时用的那对密钥可不能这么随意对待。

```bash
ssh-keygen -f ~/.ssh/travis
touch .travis.yml
travis encrypt-file ~/.ssh/travis --add
mkdir .travis
mv travis.enc ./.travis
```

创建公私钥后需要调用 travis 客户端去对私钥做加密，并把解密操作写入 `.travis.yml` 中。travis 会自动读取本地仓库中的信息，猜测当前项目对应的 Github repo。如果加密过程看到如下错误，说明 travis 猜不出我们要把私钥加密给哪个仓库用。

> `Can't figure out GitHub repo name. Ensure you're in the repo directory, or specify the repo name via the -r option (e.g. travis <command> -r <owner>/<repo>)`

直接按照错误提示操作就好了。

travis 把加密后的私钥放在当前目录，文件命名策略是「私钥文件名.enc」。我们在当前目录创建一个隐藏目录，用来放 travis 相关的杂物，比如这个加密私钥，或者其他辅助集成的脚本、配置。

千万记得把 `~/.ssh/travis.pub` 加入要部署的仓库的 Deploy Key 中，赋予写权限。按照「最小权限原则」，如果可以，尽量不要把这个公钥设置到账户级别，设置到仓库级别就好了。

我们需要修改 travis 自动写入的解密操作，主要把输入文件修改为 `.travis/travis.enc`，把私钥输出到默认位置 `~/.ssh/id_rsa`。

然后我们就开始写 `.travis.yml`，编排自动部署的操作。为了简单起见，我把维护着 Hexo 版本以及各种插件的版本的 `pacakge.json` 也纳入了版本控制，这样就可以在在完成 Hexo 的安装后，一行命令恢复博客环境。

```json
language: node_js

node_js:
  - "0.12"

branches:
  only:
    - master

git:
  submodules: false

addons:
  ssh_known_hosts:
  - github.com
  - blog-panjiabang.app.cnpaas.io

before_install:
  - openssl aes-256-cbc -K $encrypted_3ba5678e770b_key -iv $encrypted_3ba5678e770b_iv -in .travis/travis.enc -out ~/.ssh/id_rsa -d
  - chmod 600 ~/.ssh/id_rsa
  - eval $(ssh-agent)
  - ssh-add ~/.ssh/id_rsa
  - git config --global user.name "panjiabang"
  - git config --global user.email panjiabang@gmail.com
  - sed -i 's/git@github.com:/https:\/\/github.com\//' .gitmodules
  - git submodule update --init --recursive

install:
  - npm install hexo-cli -g
  - npm install

script:
  - hexo clean
  - hexo g
  - hexo d

```

大部分的命令都很直观，命令的用途每个 Hexo 用户都一清二楚。其中比较有意思的是在 Travis CI 中以 hack 的手段去处理 Git 子模块。

平时维护 Git 仓库的时候，为了方便 push 代码，我们都是用 ssh 来做身份验证的。但是在 Travis CI 上，并没有我们常用的私钥，没法完成身份验证，然后没法下载子模块的代码。

为什么没法下载子模块的代码，却能下载没有子模块的仓库的代码？因为 Travis CI 在克隆代码的时候，用的 HTTPS 协议。Stack Overflow 上有网友机智地给出了一个 [workaround][4]，既满足了平时维护代码的方便，又实现了在 Travis CI 上下载子模块的代码。这里我直接抄过来用了。就是这个方法目测不能解决嵌套子模块的问题。

子模块这种东西，也是一种代码重用的策略，只不过比较原始。

## 得到的

使用 Travis CI 来自动博客，相比之前我手动部署，有什么好处呢？

为了使用 Travis CI，我把博客源码托管到了 Github。这就意味着我可以从其他电脑，甚至移动设备上操作博客源码，不必再为了修改几个错别字从床上爬起来了，也不用再担心硬盘崩坏造成博客丢失了。

在 iOS 设备上操作 Github 文件可以使用一个叫 [CodeHub][5] 的 App。

如果我的博客用 Wordpress 或者 Ghost 的话，我也不必为了改错别字从床上爬起来的😂从功能上来说，在静态博客这个用例中，Github ≈ 数据库 + 后台，Hexo + 编译机 ≈ WordPress 渲染，Github Pages ≈ WorkPress 访问。

一个意外收获：由于每次自动部署，Travis CI 都会根据我写的脚本去构建 Hexo 环境，所以我的博客系统用到的各种插件都会被下载下来，比如我写的 [hexo-ruby-character][6] 和 [akfish][7] 写的 [hexo-github][8]。每次部署博客都会增加插件的下载量，似乎这个还是对插件作者有一点点鼓励的，尤其是我这种 Node.js 在三脚猫水平的鶸，哈哈~

## 失去的

有得必有失。相比之前我从本地执行部署，使用 Travis CI 之后，我失去了什么？

首先是假如我想要从本地多部署，就需要为 CNPaas 单独做 SSH 配置了。因为 CNPaas 每个项目只支持导入一个公钥，我只能手动为它指定之前给 Travis CI 使用的私钥。

然后所谓的移动设备操作 Github，也就仅限于修改错别字了。我如今已经不期望能够从手机上产生一篇文章，除非 iOS 设备有让人满意的全键盘外设。有时候真是怀念当初用 Nokia E63 击键如飞的日子，这部经典的手机我至今依然保留着，不知道黑莓 Priv 到底是否值得入手，入手之后是否真能实现不错的移动编辑体验。

还有就是修改主题变得更加麻烦了，得在本地调试好之后，把变更推到主题仓库，然后再把博客变更推到博客仓库。假如我直接从本地部署的话，说不定下次就因为我没有提交变更而被修改之前的主题生成的页面覆盖了。

总体上，个人感觉失去的和得到的差不多，因为已经折腾成这样，也就懒得折腾回去了。


[1]: https://travis-ci.org
[2]: http://shields.io
[3]: http://zespia.tw/blog/2015/01/21/continuous-deployment-to-github-with-travis/
[4]: http://stackoverflow.com/a/24600210/2981813
[5]: http://codehub-app.com
[6]: https://www.npmjs.com/package/hexo-ruby-character
[7]: https://github.com/akfish
[8]: https://www.npmjs.com/package/hexo-github
