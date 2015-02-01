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
  scrolltop = function(){ return $(document).scrollTop(); };

  background_size_for_header_images = function(){
    var window_width = $(window).width();
    header.css("background-size", window_width);
    header_content_bg.css("background-size", window_width);
  };

  header_image_parallax = function(){
    var header = $('.header');
    header.css("background-position", 
      ( 'center bottom ' + ((-scrolltop())/$(window).height()*200) + 'px' ) );
    header_content_bg.css("background-position", 
      ( 'center bottom ' + ((-scrolltop())/$(window).height()*200) + 'px' ) );
  };

  big_color = function(){
    coloring.css('padding-top','10px');
    coloring.css('padding-bottom','10px');
  }

  fade_filterbar = function(){
      var can_hide_filter =  $(".filter-nav .dropdown.open").length == 0;
      var can_shrink_color = can_hide_filter && $(".coloring .dropdown.open").length == 0;
      var hardtop = parseInt(coloring.css('padding-top'))*2+42;
      var breakPoint = $(document).width() > 768 ? 300 : 65;
      if(scrolltop() > breakPoint && can_hide_filter) {
        filter_bar.css("top", ((-scrolltop()+breakPoint)/85*30) +hardtop);
      }else{
        filter_bar.css("top", hardtop);
      }

      if(scrolltop() > breakPoint && can_shrink_color) {
        coloring.css( { "padding-top" : ((-scrolltop()+breakPoint)/85*10) + 10 +"px" } );
        coloring.css( { "padding-bottom" : ((-scrolltop()+breakPoint)/85*10) + 10 +"px" } );
      } else {
        coloring.css( { "padding-top" : '10px' } );
        coloring.css( { "padding-bottom" : '10px' } );
      };

      if(scrolltop() > breakPoint+100 && can_hide_filter) { 
        filter_bar.css("display", 'none' );
      } else {
        filter_bar.css("display", 'block' );
        if (can_hide_filter){
          filter_bar.css("opacity", (-scrolltop()+breakPoint+100)/65 ); 
        }else{
          filter_bar.css("opacity", 1); 
        }
      }

      if(scrolltop() > breakPoint+100 && can_shrink_color) { 
        coloring.css( { "padding-top" : '0' } );
        coloring.css( { "padding-bottom" : '0' } );
      }
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
  fade_filterbar();
  check_notification_height();

  var ORIGINAL_TITLE = $('title').html();
  var NOTIFICATIONS_LOADED = false;

  if($(".notifications-drop").length > 0){ 
    update_notification_list(true);
    window.setInterval(update_notification_list, 7000);
  }


  coloring.click(big_color);
  window.addEventListener("resize", background_size_for_header_images);
  window.addEventListener("resize", check_notification_height);
  window.addEventListener("resize", fade_filterbar);
  window.addEventListener("scroll", fade_filterbar);
  window.addEventListener("scroll", header_image_parallax);

});