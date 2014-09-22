$(function(){
  var existing_account = false;
  function check_if_chalkler(email){
    if(email){
      var channel_id = $("#channel_id").val();
      var url = '/people/exists';

      var jx = $.ajax({
        url: url,
        type: 'POST',
        data: {email: email},
        complete: function(data) {
          $('#exists_result').parent().show();
          console.log(data.responseText);
          if(data.status == 200 && data.responseText == "true"){
            $('.exists-warning').hide();
            $('.exists-success').show();
          }else{
            $('.exists-success').hide();
            $('.exists-warning').show();
          }
        }
      });
    }
  }

  $('#channel_teacher_email').change(function(){
    check_if_chalkler($(this).val());
  });
});