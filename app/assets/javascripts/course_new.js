$(function(){
  $(".new_course_form_wrapper .parts").hide();
  function part_change( location ){
    location = (typeof location == 'undefined') ? window.location.hash : location;
    $(".new_course_form_wrapper .parts").fadeOut();
    $(location).delay(350).fadeIn();
    $(".new_course_form_wrapper .breadcrumb li").removeClass('active')
    $(location+'-link').parent().addClass('active');
  };
  $(".new_course_form_wrapper .breadcrumb a").click(function(e){
      part_change($(this).attr('href'));
      e.preventDefault();
  });
  part_change("#type");

  $("#type .btn-group label").click(function(){
    part_change( '#details' );
    $(".course_key_word").text( $($(this).text().split(/[ ]+/)).last()[0] );
  });
});