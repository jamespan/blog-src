hexo.extend.tag.register('stream', function(args, content){
	var result ='';
	result += '<script src="http://cdn.bootcss.com/jquery.lazyload/1.9.1/jquery.lazyload.min.js"></script>';
	result += '<div class="hexo-img-stream">';
	result += '<style type="text/css">';
	result += '.lazy {display:none;}.hexo-img-stream{column-width:320px;column-gap:15px;width:90%;max-width:1100px;margin:50px auto}div.hexo-img-stream figure{background:#fefefe;border:2px solid #fcfcfc;box-shadow:0 1px 2px rgba(34,25,25,0.4);margin:0 2px 15px;padding:15px;padding-bottom:10px;display:inline-block;column-break-inside:avoid}div.hexo-img-stream figure img{border-bottom:1px solid #ccc;padding-bottom:15px;margin-bottom:5px;max-width:150px}div.hexo-img-stream figure figcaption{font-size:.9rem;color:#444;line-height:1.5;overflow:hidden;text-overflow:ellipsis;max-width:150px;white-space:nowrap;}div.hexo-img-stream small{font-size:1rem;float:right;text-transform:uppercase;color:#aaa}div.hexo-img-stream small a{color:#666;text-decoration:none;transition:.4s color}@media screen and (max-width:750px){.hexo-img-stream{column-gap:0}}';
	result += '</style>';
	result += content;
	result += '</div>';
	result += '<script type="text/javascript">$(\'img.lazy\').lazyload({ effect:\'fadeIn\' });</script>';
	return result;
}, {ends: true});

hexo.extend.tag.register('figure', function(args){
	
	var imgUrl = args.shift();
	var title = args.join(' ');
	var grey = 'http://ww4.sinaimg.cn/large/e724cbefgw1etyppy7bgwg2001001017.gif';

	var result = '<figure>';
	result += '<img class="lazy nofancy" src="' + grey + '" data-original="' + imgUrl + '"/>';
	result += '<noscript><img src="' + imgUrl + '"/></noscript>';
	result += '<figcaption>' + hexo.render.renderSync({text: title, engine: 'markdown'}).replace(/<p>/, '').replace(/<.p>/, '') + '</figcaption>';
	result += '</figure>';
	return result;
});


