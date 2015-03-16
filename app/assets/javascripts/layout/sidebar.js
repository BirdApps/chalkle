$(function(){
  var sidebar = $('.sidebar');
  var sidebar_padded = $('.sidebar-padding')
  $('.sidebar-tab').click(function(){
    if(sidebar.hasClass('open')){
      sidebar_close();
    }else{
      sidebar_open();
    }
  });
  ensure_closed_on_mobile_load();
  
  function sidebar_open(){
    sidebar.addClass('open')
    sidebar_padded.addClass('open')
    persist_sidebar_state(true);
  }

  function sidebar_close(){
    sidebar.removeClass('open')
    sidebar_padded.removeClass('open')
    persist_sidebar_state(false);
  }

  function persist_sidebar_state(open){
    $.post('/me/preferences/sidebar_open', { sidebar_open: open });
  }

  function ensure_closed_on_mobile_load(){
    if($(window).width() < 758){
      sidebar_open();
    }
  }
});