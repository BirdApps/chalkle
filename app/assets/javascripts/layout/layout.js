$(window).load(function(){
  $('#wrapper').css('opacity',1);
});

$(function(){
  var header = $('.header-wrapper > *');
  var header_wrap = $('.header-wrapper');
  var coloring = $('.coloring');
  var html = $('html');

  init();

  function init(){
    facebook_init();
    header_init();
    site_messages();
    notifications_init();
    searchBar_init();
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-toggle="popover"]').popover();
  }

  function searchBar_init(){
    
    $('#search_btn').click(function(){
      $('#search_input').focus();
    });

    $('#search_input').focus(function(){
      $('.navbar-header').css('left', '-200px');
      $('.search-wrapper-wrapper').css('left', '20px');
      $('.search-wrapper').addClass('open');
      $('.navbar-nav').children().each(function(){
        if( !$(this).hasClass('search-wrapper-wrapper') ) $(this).hide();
      });
    });

    $('.search-close').click(close_search_wrapper);
    $('.header-wrapper').click(close_search_wrapper);
    $('.body-content').click(close_search_wrapper);

    function close_search_wrapper(){
      if( $('.search-wrapper').hasClass('open') ){
        $('.search-wrapper-wrapper').css('left', 'auto');
        $('.navbar-header').css('left', '0');
        $('.search-wrapper').removeClass('open');
        $('.navbar-nav').children().each(function(){
          if( !$(this).hasClass('search-wrapper-wrapper') ) $(this).fadeIn(200);
        });
      }
    }
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
    //show_bg_img();

    match_screen_width();
    window.addEventListener("resize", match_screen_width);

    function match_screen_width(){
      $('*').map(function(){
        if($(this).width() > document.body.clientWidth ) return this;
      }).css('width', document.body.clientWidth);
    }

    
    // function show_bg_img(){
    //   if($(".header-wrapper *").length > 0){
    //     show_bg_img_init();
    //   }

    //   var img_width,img_height;
    //   function show_bg_img_init(){
    //     bg_image = new Image;
    //     bg_image.src = html.css('background-image').replace(/url\(|\)$/ig, "");
    //     img_width = bg_image.width;
    //     img_height = bg_image.height;
    //     show_hide_bg();
    //   }

    //   function get_padding(){
    //     var ratio = parseInt(html.css('background-size')) / img_width;
    //     var padding = img_height * ratio;
    //     padding = padding - header.offset().top - header.height();
    //     bu_padding = $(window).height() - header.offset().top - header.height();
    //     if( isNaN(padding) || padding > bu_padding ){
    //       padding = bu_padding;
    //     }
    //     return padding;
    //   }

    //   var bg_show = false;
    //   function show_hide_bg() {
    //     header.click(function(){
    //       if(!bg_show){
    //         new_padding = get_padding();
    //         console.log(header);
    //         console.log(new_padding);
    //         header.css("padding-top", new_padding+'px');
    //         bg_show = true;
    //       }else{
    //         header.css("padding-top", 0);
    //         bg_show = false;
    //       }
    //     });

    //     header.find('a').mousedown(function(e){
    //       e.stopPropagation();
    //     });
    //     header.find('input').mousedown(function(e){
    //       e.stopPropagation();
    //     });
    //   } //- show_hide_bg

    // } //- show_bg_img
  }//- header_init

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