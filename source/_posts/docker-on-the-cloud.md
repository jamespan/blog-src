title: 阿里云、Docker 和各种折腾
tags:
  - Cloud
  - Docker
categories:
  - Study
cc: true
hljs: true
comments: true
date: 2015-07-25 02:28:13
thumbnail: http://ww1.sinaimg.cn/small/e724cbefgw1euefr736eej211m0xktck.jpg
---

前几天，我在阿里云买了一台 ECS，香港节点乞丐版，1 核 1G 内存 20G SSD。

其实之前我有过一台阿里云（万网）的虚拟主机，免费的，青岛节点。让人感到憋屈的是，这台主机需要备案之后才能做域名绑定。为了不备案，这个虚拟主机我就一直闲置着。

<!-- more --><!-- indicate-the-source -->

上周开始我不满足于 Github Pages 之类的静态页面托管服务，希望在 App 部署上得到更大的自由，于是开始考虑购买国外的虚拟主机，目标锁定 Digital Ocean。晚上和室友说了一下这个事情，室友是运维方面的技术专家。

观止巨巨说阿里云的香港节点也不用备案。顿时我感觉找到了很好的解决方案。观止巨巨说香港节点到大陆的 RTT 是 100+ms，洛杉矶节点到大陆的 RTT 是 300+ms，我感觉香港的这个 RTT 完全可以接受，毕竟是挂网页嘛，又不是搞接口，1 秒之内打开都是秒开。

购买的过程感觉有点小坑，选择节点地区（香港）和配置（1 核 1G）以及网络带宽（1Mbps）之后，显示的价格是 75 软妹币。看到这个价格我很开心，半顿牛排的价格可以玩一个月的云主机还是很划算的。然而，当我选择了操作系统（Ubuntu 14.04 64bit）之后，价格居然变成了 117 软妹币。

居然选个操作系统都要多收 42 大洋 TnT。要不是 ECS 没法买裸机的话，我真想自己安装系统。后来算了一下，如果我亲自操刀装系统，按照时薪来算那可亏大了。

# 那些关于 sshd 的约定俗成 #

虽然我这次算是第一次玩云主机，但是一些约定俗成的事情，我还是知道一些的。其中要做的第一件事就是把远程登录管好。首先以 root 用户登录。

现在的远程登录都是用的 ssh，默认端口是 22。假如我们把 22 端口改了，变成一个 10000 以上的端口，那么坏人想要暴力破解你的 ssh 登录，就不得不扫描全部端口，代价瞬间增大了。

改掉端口还不算完，sshd 的约定俗成要做就做全套。禁用 root 登录、禁用密码登录都是比改端口要彻底的多的方案。禁用密码登录就意味着能且仅能用密钥登录，安全性瞬间爆棚。

```
Port 22122
PermitRootLogin no
PasswordAuthentication no
```

修改完 `/etc/ssh/sshd_config` 之后需要重启 sshd 服务。

```bash
service ssh restart
```

如果重启 sshd 之前没有创建普通用户，没有把公钥写入到 `~/.ssh/authorized_keys`，那就悲剧了，画面太美不敢看。不过这也没有什么大不了的，直接从阿里云的控制台重装系统，重新输入 root 密码，分分钟把系统装好重启。

# 那些关于 Docker 的环境问题 #

在阿里云 ECS 上安装使用 Docker，还是和一般的 Linux 不太一样的。之前我对 Docker 的使用经验仅局限于在本地使用 Dockerfile 构建镜像。

在阿里云上安装 Docker，我参考的是《[Docker —— 从入门到实践][1]》的安装命令，从 ppa 安装。

```bash
sudo apt-get install apt-transport-https
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sudo bash -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get install lxc-docker
```

然而安装完了之后，Docker Deamon 并没有像期待中的一样启动起来。

一开始的时候我以为是没有使用 root 权限去执行 docker 命令的缘故。于是我参照 Docker 文档[^1] 和 Ask Ubuntu 上面的信息[^2]搞了一个 docker 用户组。

[^1]: [Create a Docker group][2]
[^2]: [How can I use docker without sudo?][3]

然而 Docker 还是起不来。Google 一番之后，发现是阿里云的主机的路由表里面默认信息太多，把 Docker 的网段都占用了的缘故[^3]。

[^3]: [我在阿里云上成功安装docker，但是docker却不能运行起来...][4]

```bash
sudo route del -net 172.16.0.0 netmask 255.240.0.0
```

修改路由表之后 Docker 成功启动。

# 纸上得来终觉浅 #

最近一段时间，在工作中，我把 Gitlab 的 issue 功能当作工作笔记来使用。处理的各种事情，都自己给自己提 issue，然后解决过程、中间产物等等各种东西都记录在 issue 的评论里面。一开始是想着这样能够在工作中沉淀一些东西，一个是方便自己复用经验，另一个是方便和同事分享。

这样工作了一段时间之后，感觉不错，于是考虑把这种模式推广到生活中，自己搭建一套 Gitlab，作为生活和学习的记录以及私有的项目托管，Put Everything Under Version Control。

几天之内，我先后使用 Docker 在阿里云部署了 Gitlab，Gogs，Hatta 等等。后来 Gitlab 因为太占内存被我放弃，不仅仅需要我挂载 swap 分区，还占用了 800M 的内存。现在依然工作着的两个 Docker 容器分别封装了 Gogs 和 Hatta，看起来现阶段我还是比较喜欢胖容器这种部署方式的。然而，Gogs 除了极其轻量这个优势外，其余各个方面都和 Gitlab 有着很大差距，毕竟 Gitlab 是目前最成熟的开源类 Github 系统了。

折腾过程中学会了简单地使用 Docker Compose，还实践了一把用 nginx 做反向代理，具体过程有时间再写好了。

纸上得来终觉浅，绝知此事要躬行，这也许就是拥有一台云主机的好处吧~

[1]: http://dockerpool.com/static/books/docker_practice/install/ubuntu.html
[2]: https://docs.docker.com/installation/ubuntulinux/#create-a-docker-group
[3]: http://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo
[4]: http://www.zhihu.com/question/24863856

