title: 从 Git 提交历史中「恢复」文件修改时间
tags:
  - Blogging
  - Git
categories:
  - Study
thumbnail: 'https://i.imgur.com/2YbLXqh.png'
cc: true
comments: true
date: 2016-04-24 12:53:09
---


几个月之前，我贪图部署方便，把博客的部署方式，从本地编译推送更新变成了借助 Github 和 Travis-CI [自动部署][1]。

用了几个月一直相安无事，直到几天前我小小修改了一下主题，展示了文章的更新日期。

<!-- more --><!-- indicate-the-source -->
{% recruit %}

本地调试的时候一切正常，直到我把变更推到 Github，触发了自动部署。下图就是出乎意料的上线效果。

![逼死处女座](https://i.imgur.com/TxfVc92.png)

注意到所有的文章的更新日期都是同一天了吗？真是伤脑筋啊。没错，正如你猜测的那样，我的星座是人见人黑的处女座。

为什么会出现这种测试效果和上线效果不一致的情况呢？我们得从 Linux 系统中文件的几个[时间属性][2]说起。

在 POSIX 系统中，每个文件都有且仅有 3 个时间属性，最后访问时间，最后修改时间，最后状态变更时间。举个例子，这个文件的内容被访问了，比如用 `cat` 或者 `less` 读取内容，最后访问时间就会被更新；如果这个文件内容被修改了，比如用 `vi` 改了点东西然后保存，就会修改最后修改时间；如果用 `chmod` 改了权限什么的，更新的就是最后状态变更时间。

为什么没有「文件创建时间」？其实在一些现代的文件系统中，比如 ext4 或者 Btrfs 是保存了文件创建时间的，只不过由于默认的 POSIX 兼容性，我们一般都不去做特殊读取罢了，毕竟出于程序的可移植性考虑，我们不能把程序绑定在某几个文件系统上。

但是作为一个博客系统，Hexo 是需要知道文件的创建时间的。也许是出于上述原因，Hexo 没有依赖文件系统的特性去保存创建时间，而是直接把时间作为文章的元数据，放在文章开头的 YAML 区域里头了。

与此同时，Hexo 也提供了获取文章修改时间的 API，由于 POSIX 保证了能够问系统要到文件的最后修改时间，Hexo 就直接把这个功能交给系统代理，文件的最后修改时间就认为是文章的修改时间。

在博客的自动部署流程中，我们是把博客源码从 Github 上 clone 到 Travis-CI 的虚拟机里，然后使用 Hexo 编译出静态页面。显然这些 clone 出来的文件，它们的最后修改时间是这些文件在 Travis-CI 的虚拟机里的创建时间，而不是我当初修改并保存的时间。至于为什么 Git 不保存文件的修改时间，原因在[这里][3]。

那么有没有什么办法恢复文件的修改时间呢？精确的恢复是不可能的，毕竟信息已经丢失了，丢失得很彻底。但是作为一个博客系统，对时间精确度的要求没那么高，近似一下，使用文件的 commit 时间作为修改时间，也是可以接受的。

Google 一下，神通广大的外国朋友已经给出了[解决方案][4]，当然我也不是啥都没做，我还是去掉了一些无用参数的！

```bash
git ls-files | while read file; do touch -d $(git log -1 --format="@%ct" "$file") "$file"; done
```

这个操作看起来也好理解，把当前 Git 仓库里正在跟踪的文件给列出来，然后依次「篡改」文件的最后修改时间。根据 `git log` 命令的[文档][5]，`%ct` 是 committer date, UNIX timestamp 的占位符，代表提交时的时间戳，那么问题来了，为什么要在时间戳前面加上 `@` 符号？

经过一番苦苦寻觅，我在 [GNU Coreutils 的文档][6]中找到了答案。原来从 Coreutils 5.3.0 开始，实用工具中只要是涉及时间的参数，都可以用 `@+unix timestamp` 的形式来替代，比如 `touch -d` 本来要带的参数是一个「人类可读」的时间描述，可以是 `Sun, 29 Feb 2004 16:21:42 -0800` 或者 `2004-02-29 16:21:42`，甚至 `next Thursday` 也行，但是我们还是可以任性地使用 `@1078042902` 作为时间输入。

于是最后的解决方案就是把上面这行代码添加到 `.travis.yml` 中，在生成静态页面之前恢复一下文件的修改时间。

![解救处女座](https://i.imgur.com/vafRxND.png)

于是这个逼死处女座的问题总算解决了~

[1]: https://blog.jamespan.me/2015/11/01/ci-your-hexo-blog/
[2]: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#tag_04_08
[3]: https://git.wiki.kernel.org/index.php/Git_FAQ#Why_isn.27t_Git_preserving_modification_time_on_files.3F
[4]: http://www.commandlinefu.com/commands/view/14335/reset-the-last-modified-time-for-each-file-in-a-git-repo-to-its-last-commit-time
[5]: https://git-scm.com/docs/git-log
[6]: https://www.gnu.org/software/coreutils/manual/html_node/Seconds-since-the-Epoch.html#Seconds-since-the-Epoch


