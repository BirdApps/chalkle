$(function() {
  function text_to_fit(){
    if($('.text-to-fit').length > 0){
      var text = $('.text-to-fit');
      var limit = $('.text-to-fit').parent().width();
      var fontSize = parseInt(text.css('font-size'));
      do {
          fontSize--;
          if(fontSize < 15){
            break;
          }
          text.css('font-size', fontSize.toString() + 'px');
      } while (text.width() >= limit);
       do {
          fontSize++;
          if(fontSize > 50){
            break;
          }
          text.css('font-size', fontSize.toString() + 'px');
      } while (text.width() <= limit-10);


      var vert_limit = $('.text-to-fit').parent().height();
      do {
          fontSize--;
          if(fontSize < 15){
            break;
          }
          text.css('font-size', fontSize.toString() + 'px');
      } while ($('.text-to-fit').parent().height() > 108);
    }
  }

  text_to_fit();
  window.addEventListener("resize", text_to_fit);
});

$(function(){
  $('.facebook-share').click(function(){
    FB.ui({
        method: 'share',
        href: window.location.href,
      }, function(response){});
  });
});



$(function(){

  var header = $('#header');
  var header_content_bg = $('body.v2 .header_content_bg');
  var filter_bar = $('.filter-nav');
  var coloring = $('.coloring');
  scrolltop = function(){ return $(document).scrollTop(); };

  background_size_for_header_images = function(){
    var window_width = $(window).width();
    header.css("background-size", window_width);
    header_content_bg.css("background-size", window_width);

  };

  header_image_parallax = function(){
    var header = $('.header');
    header.css("background-position", 
      ( 'center bottom ' + ((-scrolltop())/$(window).height()*200) + 'px' ) );
    header_content_bg.css("background-position", 
      ( 'center bottom ' + ((-scrolltop())/$(window).height()*200) + 'px' ) );
  };

  fade_filterbar = function(){
      var hardtop = $('.navbar-fixed-top').height();
      var can_affect =  $(".filter-nav .dropdown.open").length == 0;
      if(scrolltop() > 300 && can_affect) {
        filter_bar.css("top", ((-scrolltop()+300)/85*30) +hardtop);
        coloring.css( { "padding-top" : ((-scrolltop()+300)/85*10) + 10 +"px" } );
        coloring.css( { "padding-bottom" : ((-scrolltop()+300)/85*10) + 10 +"px" } );
      } else {
        filter_bar.css("top", hardtop);
        coloring.css( { "padding-top" : '10px' } );
        coloring.css( { "padding-bottom" : '10px' } );
      };
      if(scrolltop() > 400 && can_affect) { 
        filter_bar.css("display", 'none' );
        coloring.css( { "padding-top" : '0' } );
        coloring.css( { "padding-bottom" : '0' } );

      } else {
        filter_bar.css("display", 'block' );
        if (can_affect){
          filter_bar.css("opacity", (-scrolltop()+400)/65 ); 
        }else{
          filter_bar.css("opacity", 1); 
        }
      }
  };

  background_size_for_header_images();
   fade_filterbar();

  window.addEventListener("resize", background_size_for_header_images);
  window.addEventListener("resize", fade_filterbar);
  window.addEventListener("scroll", fade_filterbar);
  window.addEventListener("scroll", header_image_parallax);

});