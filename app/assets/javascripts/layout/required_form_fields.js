$(function(){
  $('form').submit(function(){
    $(this).find('[required]').each(function(){
      if($(this).val().length == 0){
        $(this).addClass('required-missing');
        $(this).focus(function(){
          $(this).removeClass('required-missing');
        })
      }
    });
  });
});