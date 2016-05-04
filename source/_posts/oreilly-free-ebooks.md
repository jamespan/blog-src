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


There are some books you will never want to read if you're not an expert. However, some presses are good at publishing those books, like [Huazhang](http://www.hzbook.com/ps/) and O'Reilly.

It's very easy to recognize books from these two presses. I have read lot's Huazhang books at  collage, mostly basis of computer science. We call these books "black cover books", while it's real name may be "computer science series". As for O'Reilly books, we call them "animal books" for there is always an animal in the cover. Some animal is the mascot of the technology, like python for Python, gophers for Golang, etc. As for Perl, it seems that it was O'Reilly put a camel in the cover of *Programming Perl* at first, then camel became Perl's mascot.

<!-- more --><!-- indicate-the-source -->

{% recruit %}

In my opion, the most famous book Huazhang ever published was this, Introduction to Casting :)

![](https://i.imgur.com/7L1KiAL.jpg)

And the most honest book published by O'Reilly was "Copying and Pasting from Stack Overflow" lol

![](https://i.imgur.com/aZEascJl.jpg)

Let's return to the main topic. I read *[Software Architecture Patterns][1]* several days ago, in fragmentary times.

I found it helpful for introducing some common architectures, like mud, layered, event-driven, pluggin, and even microservice, the hotest architectures nowadays. Not only tell how, but also why it design, what problem to solve, that tradeoff it made, etc.

Accidentally, I found this book about half a year ago. Accidentally again, I found a collection of free books which contains it, [Free Programming Reports](http://www.oreilly.com/programming/free/). In addition to programming, there are topics like buseniss, data, IoT, etc. What I felt was just like an eater wandering into a room full of delicious free food!

It's always a good habit to download and save the resources you like locally from the Internet, or somedays later you may never have access to it, who knows?

So, the MVP of this article comes. Following is a one line code of JavaScript that helps download O'Reilly free ebooks easily. 

```js
$.map($('body > article:nth-child(4) > div > section > div > a'), function(e){return e.href.replace(/free/, "free/files").replace(/csp.*/, "pdf")})
```

Just open the dev tools, than paste above jQuery expression into console and hit enter, boom! All the PDF ebook download links are there, it's easy to download them all using wget or axel.

![](https://i.imgur.com/txLqgnx.png)

Happy reading!

[1]: http://www.oreilly.com/programming/free/software-architecture-patterns.csp