/**
* recruit tag
*
* Syntax:
*   {% recruit %}
*/

hexo.extend.tag.register('recruit', function(args) {

  var content1 = 
  '<div style="margin: 20px 0px;padding: 10px 30px;background-color: #dff0d8;border: 1px solid #d6e9c6;">' + 
  '<p style="font-family: Garamond, Georgia, serif;font-weight: normal;font-size: 24px;margin: 0 0 10px 0;padding: 0;line-height: 1;display: inline;margin-top: 0 !important;">Careers</p>' +
  '<p style="margin-bottom: 0;">目前我所在的技术团队是「阿里云 <a href="https://www.aliyun.com/product/rds/" target="_blank" rel="external">云数据库</a> 团队」，我们正在寻找优秀的资深工程师以及技术专家。如果你有数据库、云计算等方面的工作经验，或者在 Python、Java 等语言上有一定的造诣，而且愿意在云数据库平台领域做点事情，那么，我很期待你的 <a href="mailto:jiabang.pjb@alibaba-inc.com" target="_blank" rel="external">来信</a>！</p>' + 
  '</div>';

  var content2 = 
  '<div style="margin: 20px 0px;padding: 10px 30px;background-color: #fcf8e3;border: 1px solid #faebcc;">' + 
  '<p style="font-family: Garamond, Georgia, serif;font-weight: normal;font-size: 24px;margin: 0 0 10px 0;padding: 0;line-height: 1;display: inline;margin-top: 0 !important;">Exchange</p>' +
  '<p style="margin-bottom: 0;">目前我手上有一批看完之后闲置的实体书，如果你正好也有闲置中的实体书，我们或许可以做个 <a href="/flea/">交换</a> :)</p>' + 
  '</div>';

  return content1 + content2;
});
