$(function(){

  if($('.provider-form').length > 0){
    var url_unavailable = false;
    var original_value =  $('#provider_url_name').val();
    function validate(event){
      var invalid = false;
      if(url_unavailable){
        invalid = true;
        $("#provider_url_name").focus();
      }
      if($('#teaching_agreeterms input:checked').length == 0){
        invalid = true;
        $('#checkbox_error').show();
      }
      if(invalid){
        event.preventDefault();
      }
    }


    function check_url_available(new_value){
      if(new_value){
        var url = '/url_available/'+new_value+'.json';

        var jx = $.ajax({
          url: url,
          complete: function(data) {
            name = data.responseText;
            if(name == "-1") name = original_value
            if((data.status == 200 && data.responseText != "-1") || new_value == original_value ){
              url_unavailable = false;
              $("#check_url_available").text( name + " is available!" );
              $("#check_url_available").removeClass("label-danger");
              $("#check_url_available").addClass("label-success");
            }else{
              url_unavailable = true
              $("#check_url_available").text("Sorry, that web address is not available." );
              $("#check_url_available").addClass("label-danger");
              $("#check_url_available").removeClass("label-success");
            }
            $("#check_url_available").show();
          }
        });

      }
    }

    $('#teaching_agreeterms input').change(function(){
        $('#checkbox_error').hide();
    });

    $('#provider_url_name').change(function(){
      check_url_available($(this).val());
    });

    $('.provider-form').submit(validate);
  }
});