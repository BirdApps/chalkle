$(function(){
  var sidebar = $('.sidebar');
  var sidebar_padded = $('.sidebar-padding')
  $('.sidebar-tab').click(function(){
    if(sidebar.hasClass('open')){
      sidebar.removeClass('open')
      sidebar_padded.removeClass('open')
      persist_sidebar_state(false);
    }else{
      sidebar.addClass('open')
      sidebar_padded.addClass('open')
      persist_sidebar_state(true);
    }
  });
  
  function persist_sidebar_state(open){
    $.post('/me/preferences/sidebar_open', { sidebar_open: open });
  }
});