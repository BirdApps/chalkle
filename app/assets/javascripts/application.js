
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require twitter/bootstrap/tab
//= require twitter/bootstrap/transition
//= require twitter/bootstrap/tooltip
//= require twitter/bootstrap/popover
//= require twitter/bootstrap/modal
//= require twitter/bootstrap/dropdown
//= require twitter/bootstrap/collapse
//= require underscore
//= require modernizr
//= require front_end/front_end
//= require utils
//= require month_calendar_view
//= require bootstrap-datepicker/core
//= require plugins/bootstrap-timepicker.min
//= require_tree ./inputs
//= require_tree ./v2


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

  background_size_for_header_images = function(){
    var window_width = $(window).width();
    header.css("background-size", window_width);
    header_content_bg.css("background-size", window_width);

  };

  fade_filterbar = function(){
    scrolltop = $(document).scrollTop();
    filter_bar.css("opacity", (-scrolltop+400)/65 );
    if(scrolltop > 300) {
      filter_bar.css("top", ((-scrolltop+300)/85*30) +62);
      coloring.css( { "padding-top" : ((-scrolltop+300)/85*10) + 10 +"px" } );
      coloring.css( { "padding-bottom" : ((-scrolltop+300)/85*10) + 10 +"px" } );
    } else {
      filter_bar.css("top", '62px');
      coloring.css( { "padding-top" : '10px' } );
      coloring.css( { "padding-bottom" : '10px' } );

    };
  };

  background_size_for_header_images();
   fade_filterbar();

  window.addEventListener("resize", background_size_for_header_images);
   window.addEventListener("scroll", fade_filterbar);

});