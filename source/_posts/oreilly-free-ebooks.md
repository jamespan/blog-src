title: "O'Reilly Free e-Books"
tags:
  - Reading
categories:
  - Study
hljs: true
thumbnail: 'https://i.imgur.com/NrX0gRz.jpg'
cc: true
comments: true
date: 2016-05-04 23:25:10
---

There are some books you will never want to read if you're not an expert. Yet, some presses are good at publishing those books, like [Huazhang](http://www.hzbook.com/ps/) and O'Reilly.

It's easy to recognize books from these two presses. I have read lot's Huazhang books at  college, mostly the basis of computer science. We call these books "black cover books" while it's actual name may be "computer science series". 

<!-- more --><!-- indicate-the-source -->

{% recruit %}

As for O'Reilly books, we call them "animal books" for there is always an animal on the cover. Some animal is the mascot of the technology, like python for Python, gophers for Golang, etc. As for Perl, it seems that it was O'Reilly who first put a camel on the cover of *Programming Perl*, then camel became Perl's mascot.

In my opinions, the most famous book Huazhang ever published was this, Introduction to Casting :)

![](https://i.imgur.com/7L1KiAL.jpg)

And the most honest book published by O'Reilly was following.

![](https://i.imgur.com/aZEascJl.jpg)

Let's return to the main topic. I read *[Free Programming Reports][2]* several days ago, in fragmentary times.

The book introducing some common architectures like mud, layered, event driven, etc. The most surprising part is there is a chapter about microservice, which is the hottest architectures nowadays. Not only tell how but also why it design, what problem it solved, that tradeoff it made, etc.

This book is one of the O'Reilly free book collection, Free Programming Reports. Besides programming, there are topics like business, data, IoT, etc. Just like an eater wandering into a room full of delicious free food!

I used to download the resource I like from the internet, in case of I can't find it anywhere some days later. Who knows, life is a bitch, so as the internet.

So, the MVP of this article comes. Following is a one line code of JavaScript that helps download O'Reilly free ebooks easily. 

```js
$.map($('body > article:nth-child(4) > div > section > div > a'), function(e){return e.href.replace(/free/, "free/files").replace(/csp.*/, "pdf")})
```

Just open the dev tools, then paste above jQuery expression into the console and hit enter, boom! All the PDF ebook download links are there, it's easy to download them all using wget or axel.

![](https://i.imgur.com/txLqgnx.png)

Happy reading!

[1]: http://www.oreilly.com/programming/free/software-architecture-patterns.csp
[2]: http://www.oreilly.com/programming/free/

