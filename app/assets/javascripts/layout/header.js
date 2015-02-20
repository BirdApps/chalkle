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

  var header = $('body');
  var header_content_bg = $('body.v2 .coloring');
  var coloring = $('.coloring');
  scrolltop = function(){ return $(document).scrollTop(); };

  background_size_for_header_images = function(){
    var window_width = $(window).width();
    header.css("background-size", window_width*1.1);
    header_content_bg.css("background-size", window_width*1.1);
  };

  header_image_parallax = function(){
    var header = $('body');
    new_position = ((-scrolltop())/$(window).height()*200) + 'px';
    header.css("background-position", 'center top -' + new_position );
    header_content_bg.css("background-position", 'center top -' + new_position );
  };
  
  check_notification_height = function(){
    $('.notifications-drop ul').css('max-height', window.innerHeight - 140 );
  }

  $('.notifications-drop .dropdown-toggle').click(function(){
    $.get('/me/notifications/seen');
  });

  update_notification_badge = function(count) {

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

  current_notifications = function(){ 
    return $('#notifications_container').children("li._notification");
  };

  update_notification_list = function(init){
    
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

  background_size_for_header_images();
  //header_image_parallax();
  check_notification_height();

  var ORIGINAL_TITLE = $('title').html();
  var NOTIFICATIONS_LOADED = false;

  if($(".notifications-drop").length > 0){ 
    update_notification_list(true);
    window.setInterval(update_notification_list, 7000);
  }


  window.addEventListener("resize", background_size_for_header_images);
  window.addEventListener("resize", check_notification_height);
  window.addEventListener("scroll", header_image_parallax);

});