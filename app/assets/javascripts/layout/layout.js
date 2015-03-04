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
    var header = $('.header-wrapper > *');
    var header_wrap = $('.header-wrapper');
    var coloring = $('.coloring');
    var html = $('html');

    show_bg_img();

    background_size_for_header_images();
    window.addEventListener("resize", background_size_for_header_images);

    function background_size_for_header_images(){
      var width = $(window).width();
      coloring.parent().css("width", width);
      
      if( $('.sidebar').length > 0 ){
        width = width - $('.sidebar').width();
        html.css('background-position', $('.sidebar').width()+"px top");
      }

      html.css('background-size', width+"px");

    }

    function show_bg_img(){
      var bg_image, bg_img,img_width,img_height;

      if($(".header-wrapper *").length > 0){
        show_bg_img_init();
      }

      function show_bg_img_init(){
        bg_img = function(){
          if(bg_image == undefined){
            bg_image = new Image;
            bg_image.src = html.css('background-image').replace(/url\(|\)$/ig, "");
          }
          return bg_image;
        }

        img_width = bg_img().width;
        img_height = bg_img().height;
        click_to_show_bg();
        scroll_to_show_bg();
        window.addEventListener("scroll", scroll_to_show_bg);
      }

      function get_padding(){
        var ratio = parseInt(html.css('background-size')) / img_width;
        var padding = img_height * ratio;
        padding = padding - header.offset().top - header.height();
        bu_padding = $(window).height() - header.offset().top - header.height();
        if( isNaN(padding) || padding > bu_padding ){
          padding = bu_padding;
        }
        return padding;
      }

      function click_to_show_bg() {
        if(html.width() >= 998) {
          header.mousedown(show_bg);
          header.mouseout(hide_bg);
          header.mouseup(hide_bg);
          header.find('a').mousedown(function(e){
            e.stopPropagation();
          });
          header.find('input').mousedown(function(e){
            e.stopPropagation();
          });
        }

        function show_bg() {
          header.css("padding-top", get_padding()+'px');
          header.css('opacity', 0.3 );
        }

        function hide_bg() {
          header.css("padding-top", 0);
          header.css('opacity', 1 );
        }
      } //- click_to_show_bg

      function scroll_to_show_bg() {
        scroll = $('body').scrollTop();
        
        if($(window).width() > 998){
          new_padding = coloring.height()+(scroll*($(window).height()/100-3)*-1);
        }else{
          new_padding = coloring.height()+(($(window).height()/100-3)*-1); 
        }

        var max_padding = get_padding();
        if(new_padding > max_padding){
          //don't scroll past limit of image
          new_padding = max_padding;
        }

        if(scroll < 0){
          //add negative scroll if page is negative scrolled
          new_padding = new_padding + scroll;
        }

        if(new_padding < coloring.height()+6){
          // ensure resting state is accurate
          new_padding = coloring.height();
        }

        header.css('padding-top', new_padding+'px' );

        var opacity = scroll == 0 ? 1 : 0.3;
        header.css('opacity', opacity );
      }//- scroll_to_show_bg
    } //- show_bg_img
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

    window.addEventListener("resize", check_notification_height);

    if($(".notifications-drop").length > 0){ 
      update_notification_list(true);
      window.setInterval(update_notification_list, 7000);
    }

    $('.notifications-drop .dropdown-toggle').click(function(){
      $.get('/me/notifications/seen');
    });

    function check_notification_height(){
      $('.dropdown-menu ul').css('max-height', window.innerHeight - 140 );
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