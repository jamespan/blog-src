'use strict';

var config = {
  'jquery': '//cdn.bootcss.com/jquery/2.1.0/jquery.min.js',
  'jquery_lazyload': '//cdn.bootcss.com/jquery.lazyload/1.9.1/jquery.lazyload.min.js',
  'img_placeholder': 'http://ww4.sinaimg.cn/large/e724cbefgw1etyppy7bgwg2001001017.gif'
}

if (hexo.config.image_stream) {
  for (var key in config) {
    if (hexo.config.image_stream[key] != null) {
      config[key] = hexo.config.image_stream[key];
    }
  }
}

hexo.extend.tag.register('stream', function(args, content){
  var result = '';
  if (config['jquery']) {
    result += '<script src="' + config['jquery'] + '"></script>';
  }
  if (config['jquery_lazyload']) {
    result += '<script src="' + config['jquery_lazyload'] + '"></script>';
  }
  result += '<div class="hexo-img-stream">';
  result += '<style type="text/css">';
  result += '.hexo-image-steam-lazy {display:none;}.hexo-img-stream{width:90%;max-width:1100px;margin:3% auto}div.hexo-img-stream figure{background:#fefefe;box-shadow:0 1px 2px rgba(34,25,25,0.4);margin:0 0.05% 3%;padding:3%;padding-bottom:10px;display:inline-block;max-width:25%}div.hexo-img-stream figure img{border-bottom:1px solid #ccc;padding-bottom:15px;margin-bottom:5px}div.hexo-img-stream figure figcaption{font-size:.9rem;color:#444;line-height:1.5;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}div.hexo-img-stream small{font-size:1rem;float:right;text-transform:uppercase;color:#aaa}div.hexo-img-stream small a{color:#666;text-decoration:none;transition:.4s color}@media screen and (max-width:750px){.hexo-img-stream{column-gap:0}}';
  result += '</style>';
  result += content;
  result += '</div>';
  result += '<script type="text/javascript">$(\'img.hexo-image-steam-lazy\').lazyload({ effect:\'fadeIn\' });</script>';
  return result;
}, {ends: true});

hexo.extend.tag.register('figure', function(args){
  var imgUrl = args.shift();
  var title = args.join(' ');
  var placeholder = config['img_placeholder'];

  var result = '<figure>';
  result += '<img class="hexo-image-steam-lazy nofancy" src="' + placeholder + '" data-original="' + imgUrl + '"/>';
  result += '<noscript><img src="' + imgUrl + '"/></noscript>';
  result += '<figcaption>' + hexo.render.renderSync({text: title, engine: 'markdown'}).replace(/<p>/, '').replace(/<.p>/, '') + '</figcaption>';
  result += '</figure>';
  return result;
});
