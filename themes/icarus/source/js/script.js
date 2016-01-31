(function($) {
  // Caption
  $('.article-entry').each(function(i){
    $(this).find('img').each(function(){
      if ($(this).parent().hasClass('fancybox')) return;
      if ($(this).hasClass('nofancy')) return;
      var alt = this.alt;
      if (alt) $(this).after('<span class="caption">' + alt + '</span>');
      $(this).wrap('<a href="' + ($(this).attr('data-src') == null ? this.src : $(this).attr('data-src')) + '" title="' + alt + '" class="fancybox"></a>');
    });
  });

  if ($.fancybox) {
    $('.fancybox').fancybox({
      helpers: {
        overlay: {
          locked: false
        }
      }
    });
  }

})(jQuery);
