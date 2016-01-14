title: pyiconv - 一个文本编码探测转换器
date: 2014-08-04 22:13:02
tags: 
  - Tool
  - Python
categories:
  - Study
cc: true
hljs: true
comments: true
---

最近在 Mac 下写代码，一不小心就遭遇了编码问题，蛋疼的 GBK 陷阱，代码里面的中文注释全乱套了。本来不想自己造轮子的，但是 iconv 不具备自动探测文本编码的功能，这个很是痛点。Mac App Store 里有一个叫 [TextPal](https://itunes.apple.com/us/app/textpal/id677976033) 的 App，界面看起来很不错的样子，但是好贵，要 30 软妹币，屌丝不舍得啊。

周末的早上无聊就造了一会轮子，把代码写出来了，算是 iconv 的 Python 复刻，增加了自动识别编码的功能，顺便练习用 Python 解析命令行参数。

<!-- more --><!-- indicate-the-source -->

另外，我为了方便检测文本编码，使用了一个叫`chardet`的库。通过`pip install chardet`安装该依赖即可。

如果需要批量转换，可以结合`find`和`xargs`来使用，像这样子：

```bash
# 批量转换文本为GBK编码，覆盖原文件
find . -name "*.java" | xargs -I{} ./pyiconv -i {} -t GBK -o {}
```

更多用法在程序的 help 里，执行`pyiconv [-h|--help]`就能看到。

```bash
usage: pyiconv [-h] [-d] [-i FILE] [-o FILE] [-f ENCODING] [-t ENCODING] [-a]

detect and convert text encodings

optional arguments:
  -h, --help            show this help message and exit
  -d, --detect-only     detect the encoding of input end exit
  -i FILE, --input FILE
                        read from input file, if not given, use stdin by
                        default
  -o FILE, --output FILE
                        write to output file, if not given, use stdout by
                        default
  -f ENCODING, --from ENCODING
                        the encoding that convert from, if not given, auto
                        detect by default
  -t ENCODING, --to ENCODING
                        the encoding that convert to, if not given, UTF-8 by
                        default
  -a, --auto-detect     auto detect encoding of input
```

代码托管在 Github 上，[pyiconv](https://github.com/JamesPan/pyiconv) 项目。

希望我花了时间之后能帮助大家节省时间~
