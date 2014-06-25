var ADAPT_CONFIG = {
  path: './assets/stylesheets/',
  dynamic: true,
  range: [
    '0 to 767px = unsemantic-grid-mobile.css',
    '767px = unsemantic-grid-desktop.css'
  ]
};



$(function(){

  var header = $('header');
  var header_h1 = $('header h1');
  var nav = $('nav');

  $(window).scroll(function(){
    var scroll_offset = $(document).scrollTop();

    if(scroll_offset < 500) {
      header.css('opacity', (-scroll_offset+500)/500  );
      header.css('margin-top', ((scroll_offset)/500)*-350 );
      header_h1.css('margin-top', (((scroll_offset)/500)*130)+300 );
    } else {
      header.css('opacity', 0.0);
      header.css('margin-top', -350 );
      header_h1.css('margin-top', 430 );
    };


    if(scroll_offset < 550 && scroll_offset > 300) {
      var padding_value = ((( (-scroll_offset+300)/250)*10)+20); 
      var background_color = ((( (scroll_offset-300)/250)*50)+30);
      var background_opacity = ((( (scroll_offset-300)/250)*0.94));

      nav.css('padding-top', padding_value ) ; 
      nav.css('padding-bottom', padding_value ) ;
      nav.css('background-color', 'rgba(' + background_color + ','+ background_color + ',' + background_color + ','+ background_opacity + ')'); 
    } if(scroll_offset > 550) {
      nav.css('background-color', 'rgba(80,80,80,0.94)');
      nav.css('padding-top', 10);
      nav.css('padding-bottom', 10);
    } if (scroll_offset < 300) {
      nav.css('background-color', 'rgba(30,30,30,0.0)');
      nav.css('padding-top', 20);
      nav.css('padding-bottom', 20);
    };

  });
});