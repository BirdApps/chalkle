$(function(){
  function admin_nav_stretch(){  
      $(".nav-bumper").width( ($( document ).width() - $(".container").width())/2 );
  };
  admin_nav_stretch();
  $(window).resize(admin_nav_stretch);
});