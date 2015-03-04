$(window).load(function(){
  $('#wrapper').css('opacity',1);
});

$(function(){

  init();

  function init(){
    facebook_init();
    header_init();
    site_messages();
    notifications_init();
  }

  function facebook_init(){
    $('.facebook-share').click(function(){
      FB.ui({
        method: 'share',
        href: window.location.href,
      }, function(response){});
    });
  }

  function header_init(){
    var header_wrap = $('.header-wrapper');
    var coloring = $('.coloring');
    var html = $('html');
    var scrolltop = function(){ return $('body').scrollTop(); };

    background_size_for_header_images();
    window.addEventListener("resize", background_size_for_header_images);
    window.addEventListener("scroll", background_size_for_header_images);

    function background_size_for_header_images(){
      if(scrolltop() < 0 && $(".header-wrapper *").length > 0){
        overscroll_header(scrolltop());
      }
      var window_width = $(window).width();
      coloring.parent().css("width", window_width);
    }

    function overscroll_header(scroll) {
      if($(window).width() > 998){
        new_padding = coloring.height()+(scroll*($(window).height()/100-3)*-1);
      }else{
        new_padding = coloring.height()+(($(window).height()/100-3)*-1);
      }

      if(new_padding < coloring.height()+6){
        new_padding = coloring.height();
      }

      var header_bg_opacity = 1-(scroll*-1/75);
      header_wrap.css('opacity', header_bg_opacity );
      header_wrap.css('padding-top', new_padding+'px' );
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

  function notifications_init(){
    var ORIGINAL_TITLE = $('title').html();
    var NOTIFICATIONS_LOADED = false;
    check_notification_height();

    window.addEventListener("resize", check_notification_height);

    if($(".notifications-drop").length > 0){ 
      update_notification_list(true);
      window.setInterval(update_notification_list, 7000);
    }

    $('.notifications-drop .dropdown-toggle').click(function(){
      $.get('/me/notifications/seen');
    });

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
      if(count > 0) {
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
  }

});