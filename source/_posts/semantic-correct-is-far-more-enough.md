title: 代码的语义正确真的就够了吗？
tags:
  - Python
categories:
  - Study
hljs: true
cc: true
comments: true
thumbnail: https://i.imgur.com/sAo6eFk.png
date: 2016-06-09 16:28:03
---


刚毕业之后工作的头一年多的时间里，我的工作都是围绕一个业务系统展开的。开发业务系统的一个感觉就是，作为开发者基本上不用去考虑 RPC 应该怎么写，消息队列、数据库、缓存应该怎么选型，配置文件用 ini 还是 YMAL 之类的问题，只需要专注在借助集团多年沉淀下来的技术栈上把业务系统搭建出来，确保系统稳定运行，帮助业务团队实现业绩目标就好了。

因为一直写的都是业务代码，在大量调用其他团队提供的 API 的同时，也大量提供 API 供其他团队调用，然后就渐渐地形成了一种思维惯性，理所当然地认为 API 的行为和它的命名是一致的，如果我调用某个 API 之后发现它的行为不符合它的命名描述，还可以推动 API 的维护团队去提供一个「政治正确」的 API。

<!-- more --><!-- indicate-the-source -->

{% recruit %}

业务代码写久了，每天每天和顶层设计打交道，就容易远离系统底层的各种细节，眼里看的脑里想的都是 API、架构之类的宽泛而空洞的概念，代码上的硬功夫一天一天退步，一个不小心就成了传说中的「API 程序员」。

虽然我不愿意承认，但是实际上我距离 API 程序员也不远了。出来混总是要还的，前几天我就被「语义正确」坑了一把。

代码是用 Python 写的。我最近几个月又开始用 Python 了，不过就目前来说我最擅长的语言还是 Java。

我需要打开一个 ini 格式的配置文件，读取其中的配置内容，然后修改几个配置文件，然后再将配置变更保存。考虑到未来可能有多个进程同时操作，还需要借助文件锁来避免进程间的竞争条件。写出来的代码是这样子的。

```python
import ConfigParser
import fcntl

config = ConfigParser.ConfigParser()
with open('config.ini', 'r+') as f:
    fcntl.flock(f, fcntl.LOCK_EX)
    config.readfp(f)
    if not config.has_section('section x'):
        config.add_section('section x')
    config.write(f)
```

多么简洁漂亮的代码！从语义上看，这段代码完全符合上面的需求，先用读写权限打开文件，默认假设文件存在；然后给文件加上排他锁，使得后面的代码都处于临界区；然后把文件内容读取到内存中并处理成特定的数据结构；然后是一些装模作样的配置变更；最后把配置写回文件，然后关闭文件，进程结束。

在 API 程序员的理想国中，这段代码的语义确实和需求是一致的，理论上应该工作良好。即如果从 `config.ini` 是一个空文件开始，无论这段代码运行多少次，`config.ini` 的内容都应该是下面这样的：

```
[section x]

```

然而让 API 程序员累觉不爱的现实世界是怎样的呢？让我们揭晓谜底：

执行第一次，`config.ini` 的内容是这样，一切安好：

```
[section x]

```

执行第二次，`config.ini` 的内容是这样，一定是上帝开了个玩笑：

```
[section x]

[section x]

```

执行第三次，`config.ini` 的内容是这样，我讨厌这个丑陋的世界：

```
[section x]

[section x]

[section x]

```

看到这里，懂行的读者应该会心一笑，这完全是文件游标在搞的鬼啊。进入临界区后，`config.readfp(f)` 读取了整个文件的内容，于是文件游标指向了文件的末尾；然后在出临界区前，`config.write(f)` 从游标所在位置开始，向文件写入内容。

那么能够给出正确 `config.ini` 的写法是怎样的呢？

```python
import ConfigParser
import fcntl

config = ConfigParser.ConfigParser()
with open('config.ini', 'r+') as f:
    fcntl.flock(f, fcntl.LOCK_EX)
    config.readfp(f)
    if not config.has_section('section x'):
        config.add_section('section x')
    f.seek(0)
    f.truncate(0)
    config.write(f)
```

在 `config.write(f)` 之前加上 `f.seek(0)`，能够确保文件游标回到文件开始的地方，然后用 `f.truncate(0)` 清空文件内容，最后才写配置然后关闭文件并将缓存刷到磁盘上。

故事并没有到这里结束。注意到我们在上面的代码中对文件执行了两次写操作。先是清空文件，然后才是写入配置内容。如果恰好在清空文件和写入配置两步之间，程序崩溃了，会有什么后果？

后果很严重，文件内容全部丢失，简直就是人间惨剧！

不要说感觉说这个时间窗口很狭小，碰上的概率太小就不管它，这种黑天鹅事件不发生就算了，一旦发生那可是大故障。且不说这种数据全部丢失的事情发生在一个关键生产系统上会怎样，只要看看当初 Atom 编辑器的一个会造成文件内容全部丢失的缺陷 [issue][1]，就能感受到问题的严重性。

关系数据库为了保证数据高可靠，会在执行数据变更前记录日志并将日志刷到磁盘上，我们可以采取类似的做法，在清空配置文件前先将数据保存一份到备份文件中，然后成功写入配置文件之后将备份删除。如果写入配置文件前进程崩溃了，那么在重入的时候先从备份文件中拿数据，然后把数据复制一份写到备份文件中。

```python
import ConfigParser
import fcntl
import os

config = ConfigParser.ConfigParser()
with open('config.ini', 'r+') as f:
    fcntl.flock(f, fcntl.LOCK_EX)
    bak_conf = 'config.ini.bak'
    if os.path.exists(bak_conf):
        with open(bak_conf) as bak:
            config.readfp(bak)
            bak.seek(0)
            f.truncate()
            for line in bak:
                f.write(line)
            f.flush()
        os.remove(bak_conf)
    else:
        config.readfp(f)
    if not config.has_section('section x'):
        config.add_section('section x')
    bak_conf_tmp = '~' + bak_conf
    with open(bak_conf_tmp, 'w') as bak:
        config.write(bak)
    os.rename(bak_conf_tmp, bak_conf)
    f.seek(0)
    f.truncate()
    config.write(f)
    f.flush()
    os.remove(bak_conf)
```

这样一来不管进程在执行到那一步的时候崩溃，都不影响数据的完整性和一致性了，把进程拉起来后重新执行就好。

果然之前做业务开发的时候一直秉承的「正确的语义带来正确的代码」，在我现在的开发工作中就行不通了呢。

[1]: https://github.com/atom/atom/issues/3158
