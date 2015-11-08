title: 'SSH::Batch，在公有云中使用  ssh 工具箱'
tags:
  - Ops
  - Tool
categories:
  - Study
hljs: true
thumbnail: //i.imgur.com/rWzB0iql.jpg
cc: true
comments: true
date: 2015-11-07 04:29:22
---


人呐就都不知道，自己就不可以预料。一个人的命运啊，当然要靠自我奋斗，但是也要考虑到历史的行程，我绝对不知道，我作为一个服务端开发者怎么开始研究运维去了，所以 ECS 酱同我讲话，说「大家都决定了，你来负责运维」，我说另请高明吧。我实在我也不是谦虚，我一个服务端开发者怎么就搞运维了呢？但是呢，ECS 酱讲「大家已经研究决定了」，所以后来我就念了两首诗，叫「苟利集群生死以，岂因祸福避趋之」，所以我就开始运维。

<!-- more -->

就像之前的博文中讲的那样，我买了两台阿里云的 ECS，一台在香港，一台在新加坡。由于总所周知的网络原因，从大陆 ping 这两台服务器的 RTT 一直都在两三百毫秒，之前只有一台位于香港的 ECS 的时候，我 ssh 上去部署一些服务，碰上网络抖动的时候都能卡出翔，敲击一个按键之后许久才出现在屏幕上。

如今我有了两台服务器，如果还像之前那样直接用 ssh 去维护的话，简直就是不敢想象的事情。且不说一样的配置文件我要修改两遍，仅仅想象一下刚刚在 A 机器卡成翔的情况下完成维护，又要去 B 机器上再次被卡成翔，就会让我怀疑人生。不要问为什么卡成翔了还不用 [mosh][1]，我也不知道😂

其实说起来，虽然过去一年多，我做的是服务端开发，但是也涉足一些简单的运维工作。应用服务器从我刚入职时候的几台扩容到几十台到现在的一百多台，一次又一次的自主发布，偶尔的手动批量重启、下线服务器，捕获线程快照、内存快照、大批量处理应用日志，经历过虚拟机宕机、物理机宕机，不胜枚举……当 AppOps 的日子，其实就是不那么规范的 DevOps 的日子。

集团的对内运维水平还处在 IaaS 的时代，这也给了我们开发者接触运维的机会。如果哪天对内的运维达到了 PaaS 的级别，开发者们也许就接触不到这些东西了。PaaS 似乎有点遥远，目前来说比较现实的是 CaaS，Containers-as-a-Service，要是能做到这个，开发者估计也没啥机会接触运维了。

在工作中，当我需要批量地在集群中执行命令时，我会使用一个叫 pgm 的内部脚本。这个脚本是 Python 写的，基于 [pssh][2]，用起来很不错，能够并发地在集群中执行命令。这个命令应该是我到目前为止会用的唯一一个内部脚本，其他的像开源的 tsar 反而不会用。

![](//i.imgur.com/rVK23fv.png)

离开了公司的环境，我就没有 pgm 用了。昨天我尝试寻找一个能够在集群中批量执行 ssh 命令的工具，这样我能够比较轻松地管理我的 ECS 们。那时候我还不知道 pgm 是基于 pssh 实现的。随便 Google 了一下 「ssh batch」，就找到一个 Github repo，[agentzh/sshbatch][3]。

进去看了一下 README，这是一个用 Perl 实现的工具箱，4 个命令分别实现如下功能：

1. fornodes 计算机器列表
2. atnodes 在指定机器集上执行命令
3. tonodes 把文件或目录上传到指定机器集
4. key2nodes 把公钥上传到指定机器集

看起来很厉害的样子，不过 agentzh 是谁？点开主页一看，我当时就跪了，有眼不识泰山，这不是传说中的春哥「章亦春」么！几个月前孤陋寡闻的我是不知道春哥的存在的，直到我出差去北京参加 Velocity，在大会上见识了[王院生][5]对的 OpenResty 的简介[^1]，当时就惊为天人。后来通过各种渠道加深了对 Nginx 和 OpenResty 的学习和了解，更是对春哥顶礼膜拜。

[^1]:[OpenResty高性能实践][4]

sshbatch 的文档写的很详细，从安装到使用面面俱到，因此我这里就不再赘述，虽然文档用英文写的。

这里主要介绍一下 sshbatch 中让我感觉惊艳的地方。

首先是机器列表的管理方式。之前用 pgm 的时候，一个应用分组的机器放在一个文件里面，在执行批处理的时候指定存放机器列表的文件。fornodes 则是把机器列表看做是一个个的集合，集合与集合之间可以做交并补等运算，通过集合运算得到不同的机器列表。这灵活性简直不能更赞。

其次是批量推送文件的 tonodes。之前用 pgm 只能批量执行命令，我在内网一直没有找到科学的批量向服务器推送文件的脚本。tonodes 很好地满足了我的需求。

于是我用 tonodes 和 atnodes 把我两台 ECS 上的 Nginx 配置文件重新维护了一遍，之前是直接登录服务器修改的，如今变成本地使用一个 git repo 去维护这些配置文件，修改完成后批量推送并重启 Nginx。

事情并没有想象中的一帆风顺。

由于服务器位于公有云，出于安全考虑，我禁止了 root 登录，禁止了密码登录，只允许公钥登录。于是我没法直接把 nginx.conf 放到 /etc/nginx/ 中。因为我懒，不想在启动 nginx 的时候指定配置文件，于是只好把 nginx.conf 放到 /tmp/，然后再把它移动到 /etc/nginx/ 并重启。

```bash
tonodes ./nginx/nginx.conf '{ecs}:/tmp/'
atnodes 'sudo mv /tmp/nginx.conf /etc/nginx/ && sudo nginx -t && sudo service nginx restart' '{ecs}' -w
```

根据文档中的描述，atnodes 加了 -w 参数，会要求用户输入密码，作为登录密码和 sudo 密码。抱着试一试的心态执行了一下，果然跪了。

```bash
➜  sshbatch git:(master) ✗ atnodes 'sudo mv /tmp/nginx.conf /etc/nginx/ && sudo nginx -t && sudo service nginx restart' '{ecs}' -w
Password:
Permission denied (publickey).
===================== server ip =====================
ERROR: unable to establish master SSH connection: bad password or master process exited unexpectedly
```

唉，我都把密码登录禁用了，这里还强行要密码登录，不跪才怪了。从文档中发现似乎把 -w 替换为 -tty 也可以实现远程执行 sudo 命令，赶紧试试。结果发现，用了 tty 倒是能输入密码执行 sudo 了，但是，每台机器都得输入一次密码，这是什么鬼！

目前我只有两台机器，输密码就忍了，假如哪天我有 10 台机器了，光输密码就得累死。

其实这个问题在企业环境甚至私有云环境应该都不是问题。哪个运维会闲着蛋疼把服务器禁止密码登录啊！反正机器都在局域网，IP 不暴露在公网就是相对安全的，只要守护好边界出口就好。所以说在内网批量执行 sudo 命令的时候，直接用 -w 参数就好了。

问题来了，就要解决问题。最直接暴力的方案是，把我的账号设置为 sudo 免密码模式，很黄很暴力，我并不喜欢。第二种方法，就是修改 atnodes，支持 -w 参数输入的密码仅作为 sudo 密码，不作为登录密码。

于是我 fork 了代码，拉到本地做了些修改。虽然是完全没用过的 Perl，但还是分分钟就改好了~通过增加参数 -W 来表达「passowrd for sudo only」的含义。

随便执行一个 sudo 命令看看效果。

```
➜  sshbatch git:(master) ✗ atnodes 'sudo ls' '{ecs}' -W
Password:
===================== server ip =====================
sudo: no tty present and no askpass program specified
Remote command returns status code 1.
```

居然，出错了……根据报错信息，给之前的命令追加一个 -tty 参数，于是我终于能在服务器上使用 sudo 了！不幸的是，开启 tty 之后，批处理就没法并发执行了，只能按顺序一个一个来。不过想想也是，开启 tty 之后一般是要做一些交互操作的，而标准输入流就只有一个，所以只好一个一个来了。

```bash
➜  sshbatch git:(master) ✗ atnodes 'sudo ls /etc/nginx/sites-enabled/' '{ecs}' -W -tty -q
Password:
===================== server ip =====================
[sudo] password for admin:
blog.jamespan.me  blog.xuminzheng.com  default	hatta  wekan

===================== server ip =====================
[sudo] password for admin:
blog.jamespan.me  default
```

我把我的修改补充测试之后提交了 [PR][7]，<del>希望能被春哥接收😇</del>经过春哥一番悉心教导，经历 7 次修改，终于被合并到了主干~

然后我又尝试了一下 pssh，似乎它没法很好地应对类似于我的机器这种禁止密码登陆之后还要执行 sudo 命令的场景。所以说啊，企业上云还不是把内部应用换个地方部署那么简单，对企业的技术水平还是很有挑战的。上云不保证系统质量会因此变好，稳定性因此而提高，甚至因为基础设施变化太大，本来部署在小型机上的现在只能部署在虚拟机上而导致应用几乎残废也不是没有。

最后的最后，今天我发现了一个叫 [Ansible][6] 的运维工具，感觉有点强大，而且对系统毫无入侵，正在看文档学习中。

Update：

春哥 Review 代码后，我按照他的意见把 `-so` 修改成了 `-W`。

[1]: https://mosh.mit.edu
[2]: https://pypi.python.org/pypi/pssh/2.3.1
[3]: https://github.com/agentzh/sshbatch
[4]: http://velocity.oreilly.com.cn/2015/index.php?func=session&id=37
[5]: http://weibo.com/p/1005053393407444
[6]: http://www.ansible.com
[7]: https://github.com/agentzh/sshbatch/pull/5
