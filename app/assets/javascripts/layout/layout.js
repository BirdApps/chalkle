
$(window).load(function(){
  $('#wrapper').css('opacity',1);
});

$(function(){

  init();

  window.setTimeout(function(){
    if($('#wrapper').css('opacity') == '0'){
      $('#wrapper').css('opacity',1);
    }
  }, 1000);


  function single_tap_links(){

    $('*').on('touchstart mouseenter focus', function(e) {
      //WEIRD FIX: stops requiring double clicks on touchscreens 
    });
  }

  function init(){
    facebook_init();
    //fix_too_wide_bug();
    site_messages();
    single_tap_links();
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-toggle="popover"]').popover();
  }

  function facebook_init(){
    $('.facebook-share').click(function(){
      FB.ui({
        method: 'share',
        href: window.location.href,
      }, function(response){});
    });
  }

  function fix_too_wide_bug(){
    match_screen_width();
    window.addEventListener("resize", match_screen_width);

    function match_screen_width(){
      $('*').map(function(){
        if($(this).width() > window.innerWidth ) return this;
      }).css('width', window.innerWidth);
    }
  }


  function site_messages(){
    var messages = $('.site-messages');
    if(messages.length > 0){
      var height = messages.height();
      messages.css('top', height*-1);
      messages.css('opacity',1);
      messages.animate({top: 0}, 200);
      messages.click(function(){
        messages.animate({top: height*-1}, 200);
      });
      window.setTimeout(function(){ messages.click(); }, 5000);
    }
  }

});