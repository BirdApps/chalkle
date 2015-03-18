$(function(){

  init();

  function init(){
    searchBar_init();
    notifications_init();
  }

  function searchBar_init(){  
    $('#search_btn').click(function(){
      $('#search_input').focus();
    });

    $('#search_input').focus(function(){
      $('.navbar-header').css('left', '-200px');
      $('.search-wrapper-wrapper').css('left', '20px');
      $('.search-wrapper').addClass('open');
      $('.shade').fadeIn('fast');

      $('.navbar-nav').children().each(function(){
        if( !$(this).hasClass('search-wrapper-wrapper') ) $(this).hide();
      });
    });
    $('.navbar').after('<div class="shade"></div>');
    $('.search-close, .header-wrapper, .body-content, .shade').click(close_search_wrapper);

    function close_search_wrapper(){
      if( $('.search-wrapper').hasClass('open') ){
        $('.shade').fadeOut('fast');
        $('.search-wrapper-wrapper').css('left', 'auto');
        $('.navbar-header').css('left', '0');
        $('.search-wrapper').removeClass('open');
        $('.navbar-nav').children().each(function(){
          if( !$(this).hasClass('search-wrapper-wrapper') ) $(this).fadeIn(200);
        });
      }
    }
  }

  function notifications_init(){
    var ORIGINAL_TITLE = $('title').html();
    var NOTIFICATIONS_LOADED = false;
    check_notification_height();

    window.addEventListener("resize", function(){
      window.setTimeout(check_notification_height, 300);
    });

    $('.dropdown').on('shown.bs.dropdown', function () {
      check_notification_height();
    });

    if($(".notifications-drop").length > 0){ 
      update_notification_list(true);
      window.setInterval(update_notification_list, 7000);
    }

    $('.notifications-drop .dropdown-toggle').click(function(){
      $.get('/me/notifications/seen');
    });

    function check_notification_height(){
      buffer = 47;
      if( $(window).width() > 768 ){
        buffer += 30;
      }
      $('.dropdown.open .dropdown-menu ul').each(function(){
        offset = $(this).offset().top - $(window).scrollTop();
        $(this).css('max-height', window.innerHeight - offset - buffer);
      });
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