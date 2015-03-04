$(function(){

  if( $('.provider_header').length > 0 ){
    var provider_header = $('.provider_header');
    var sidebar = $('.sidebar');
    var sidebar_padding = $('.sidebar-padding');
    var coloring = $('.coloring');
    var html = $('html');

    init();

    function init() {
      to_show_bg();
      window.addEventListener("resize", ensure_heading_fits);
      ensure_heading_fits();
    }

    function does_heading_fit(){
      return $('.provider_name').offset().left != $('.provider_header .avatar').offset().left
    }

    function ensure_heading_fits() {
       var font_size = parseInt( $('.provider_name').css('font-size') )
       while (  !does_heading_fit() ) {
         $('.provider_name').css('font-size', --font_size+"px");
       }
    }

    var bg_image;
    var bg_img = function(){
      if(bg_image == undefined){
        bg_image = new Image;
        bg_image.src = html.css('background-image').replace(/url\(|\)$/ig, "");
     }
      return bg_image;
    }


    function show_bg() {
      var ratio = $(window).width() / bg_img().width;
      var padding = bg_img().height * ratio;
      padding = padding - $('.provider_header').offset().top - $('.provider_header').height();
      bu_padding = $(window).height() - $('.provider_header').offset().top - $('.provider_header').height();
      if( isNaN(padding) || padding > bu_padding ){
        padding = bu_padding;
      }
      provider_header.css("padding-top", padding+'px');
      coloring.css('top', coloring.height()*-1);
      if(sidebar.length > 0) {
        sidebar.css('left', -320);
        sidebar.css('top', 0);
        sidebar_padding.css('margin-left', 0);
      }
    }

    function hide_bg() {
      provider_header.css("padding-top", 0);
      coloring.css('top', 0);
      if(sidebar.length > 0){
        sidebar.css('left', 0);
        sidebar.css('top', coloring.height());
        sidebar_padding.removeAttr('style');
      }
    }

    function to_show_bg() {
      if(html.width() > 768) {
        provider_header.mousedown(show_bg);
        provider_header.mouseout(hide_bg);
        provider_header.mouseup(hide_bg);
        $('.provider_header a').mousedown(function(e){
          e.stopPropagation();
        });
        $('.provider_header input').mousedown(function(e){
          e.stopPropagation();
        });
      }
    }
  }
});