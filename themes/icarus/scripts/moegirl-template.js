/**
* heimu tag
*
* Syntax:
*   {% heimu content %}
*/

hexo.extend.tag.register('heimu', function(args) {
  var content = args.join(' ');

  var result = '<span style="background-color:#252525 !important;color:#252525 !important" title="你知道的太多了">';
  result += content;
  result += '</span>';
  return result;
});

/**
* douban tag
*
* Syntax:
*   {% douban movie 26219198 [title] %}
*/
hexo.extend.tag.register('douban', function(args) {
  var category = args.shift();
  var id = args.shift();
  var url = 'http://' + category + '.douban.com/subject/' + id + '/';
  var title = args.join(' ');
  if (title === "") {
  	title = url;
  }

  var result = '<p><a href="' + url + '">' + title + '</a></p>';
  return result;
});


