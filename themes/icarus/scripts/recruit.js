/**
* recruit tag
*
* Syntax:
*   {% recruit %}
*/

hexo.extend.tag.register('recruit', function(args) {
  var content = args.join(' ');

  var result = 
  '<blockquote>' + 
  '<p>目前我所在的技术团队是「阿里云 <a href="https://www.aliyun.com/product/rds/" target="_blank" rel="external">云数据库</a> 服务团队」，我们正在寻找优秀的资深工程师以及技术专家。如果你有数据库、云计算等方面的工作经验，或者在 Python、C++ 等语言上有一定的造诣，而且愿意在云数据库方向做点事情，那么，我很期待你的<a href="mailto:panjiabang@gmail.com" target="_blank" rel="external">来信</a>！</p>' + 
  '</blockquote>';
  return result;
});

