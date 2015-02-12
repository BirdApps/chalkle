$(function(){
  var existing_account = false;
  function check_if_chalkler(email){
    if(email){
      var provider_id = $("#provider_id").val();
      var url = '/people/exists';

      var jx = $.ajax({
        url: url,
        type: 'POST',
        data: {email: email},
        complete: function(data) {
          $('#exists_result').parent().show();
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

  $('#provider_teacher_email').change(function(){
    check_if_chalkler($(this).val());
  });

   $('#provider_admin_email').change(function(){
    check_if_chalkler($(this).val());
  });
});