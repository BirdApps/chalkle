$(function(){
  $('.styled_upload').change(function(){
    var filename = $('input[type=file]').val().split('\\').pop();
    $(this).parent().prev().text(filename);
  })
})