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
    var provider_header = $('.provider_header');
    var coloring = $('.coloring');
    var html = $('html');
    var sidebar = $('.sidebar');
    var sidebar_padding = $('.sidebar-padding');

    var max_scroll_height = function(){
      var bg_scale = $(document).width() / bg_img().width;
      return bg_img().height * bg_scale - $('.fixed_hero').height();
    }

    var bg_image;
    var bg_img = function(){
      if(bg_image == undefined){
        bg_image = new Image;
        bg_image.src = $('html').css('background-image').replace(/url\(|\)$/ig, "");

        var scale = ($(document).width()/bg_image.width)
        var max_scroll_height
      }
      return bg_image;
    }


    var scrolltop = function(){ return $('body').scrollTop(); };

    to_show_bg();
    background_size_for_header_images();
    window.addEventListener("resize", background_size_for_header_images);
    window.addEventListener("scroll", background_size_for_header_images);
   
    function show_bg(){
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

    function hide_bg(){
      provider_header.css("padding-top", 0);
      coloring.css('top', 0);
      if(sidebar.length > 0){
        sidebar.css('left', 0);
        sidebar.css('top', coloring.height());
        sidebar_padding.removeAttr('style');
      }
    }


    function to_show_bg(){
      if(html.width() > 768){
        provider_header.click(function(e){
          if(provider_header.css("padding-top") == "0px"){
            show_bg();
          }else{
            hide_bg();
          }
        });

        $('.provider_header a').click(function(e){
          e.stopPropagation();
        });
      }
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

    function background_size_for_header_images(){
      if(scrolltop() < 0){
        overscroll_header(scrolltop());
      }
      var window_width = $(window).width();
      coloring.parent().css("width", window_width);
    }

    function header_image_parallax() {
      var new_fixed_position = (-1*(scrolltop())-100);

      if( (max_scroll_height()*-1) > new_fixed_position ){
        //scrolled past the point of no image
        new_fixed_position = (max_scroll_height()*-1);
      }
      header.css("background-position", 'center top ' + new_fixed_position  + 'px');
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