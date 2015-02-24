$(window).load(function(){
  $('#wrapper').css('opacity',1);
});

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
      text.css('opacity', 1);
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

  var header = $('.header');
  var coloring = $('.coloring');

  var max_scroll_height = function(){
    var bg_scale = $(document).width() / bg_img().width;
    return bg_img().height * bg_scale - $('.fixed_hero').height();
  }

  var scrolltop = function(){ return $('body').scrollTop(); };

  function overscroll_header(scroll) {
    if(scroll*-1 > header.height()){
      scroll = header.height()*-1;
    }
    header.css('padding-top', (coloring.height()+(scroll*5*-1))+'px' );
  }

  function background_size_for_header_images(){
    if(scrolltop() < 0){
      overscroll_header(scrolltop());
    }
    var window_width = $(window).width();
    //header.css("background-size", window_width*1.1);
  }

  function header_image_parallax() {
    //new_position = ((-scrolltop())/$(window).height()*200) + 'px';

    //scroll_hero.css("background-position", 'center top -' + new_position );

    var new_fixed_position = (-1*(scrolltop())-100);

    if( (max_scroll_height()*-1) > new_fixed_position ){
      //scrolled past the point of no image
      new_fixed_position = (max_scroll_height()*-1);
    }
    header.css("background-position", 'center top ' + new_fixed_position  + 'px');
  }
  
  function check_notification_height(){
    $('.notifications-drop ul').css('max-height', window.innerHeight - 140 );
  }

  function update_notification_badge(count) {

    // update the nav
    $(".notification-count").each(function(){
      if( $(this).hasClass("brackets") ) {
        new_badge = "(" + count + ")";
      } else { 
        new_badge = count;
      };
      if(count<1) { new_badge = '' };
      $(this).html(new_badge);
    });

    // update the title element
    if(count>0) {
      $('title').html( "(" + count + ") " + ORIGINAL_TITLE); 
    } else { 
      $('title').html(ORIGINAL_TITLE); 
    };
    
    return false;
  };

  function current_notifications(){ 
    return $('#notifications_container').children("li._notification");
  };

  function update_notification_list(init){
    
    var notification_badge_count = current_notifications().filter(".unseen").size();
    
    if(init != undefined){
      notification_badge_count = -1;
    }
    
    var get_url = "/me/notifications/list?current_unseen_notification_count=" + notification_badge_count;

    $.ajax({
      type: "GET",
      url: get_url,
      dataType: "html"
    }).done(function(data){

      if( data != '' ) { 
        //do not update if there os no new data 
        $('#notifications_container').html(data);

        var new_notification_badge_count = current_notifications().filter(".unseen").size();

        //play the notificaiton sound after updating the UI 
        update_notification_badge(new_notification_badge_count);
        if(notification_badge_count < new_notification_badge_count && NOTIFICATIONS_LOADED) {
          var audio = new Audio('/sounds/notification.mp3');
          audio.play(); 
        };
      };
      NOTIFICATIONS_LOADED = true;
    });
    update_notification_badge(notification_badge_count);
  };

  var ORIGINAL_TITLE;
  var NOTIFICATIONS_LOADED;

  function init(){
    background_size_for_header_images();
    //header_image_parallax();
    check_notification_height();

    ORIGINAL_TITLE = $('title').html();
    NOTIFICATIONS_LOADED = false;

    if($(".notifications-drop").length > 0){ 
      update_notification_list(true);
      window.setInterval(update_notification_list, 7000);
    }

    $('.notifications-drop .dropdown-toggle').click(function(){
      $.get('/me/notifications/seen');
    });

    window.addEventListener("resize", background_size_for_header_images);
    window.addEventListener("resize", check_notification_height);
    window.addEventListener("scroll", background_size_for_header_images);
  }

  init();

});