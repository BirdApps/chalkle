$(function(){
  function no_match(){
    $('#match_message').text("Password confirmation must match!");
    $('#match_message').show();
  }

  function good_match(){
    $('#match_message').text("");
    $('#match_message').hide();
  }

  function too_short(){
    $('#match_message').text("Password too short - 6 digits at least please");
    $('#match_message').show();
  }

  function check_match(hard){
    var p1 = $('#chalkler_password').val();
    var p2 = $('#chalkler_password_confirmation').val();
    if(p2 != p1){
      if(hard){
        no_match();
      }
      return false;
    }else{
      if(p1.length < 6){
        if(p1.length > 0 || hard){
          too_short();
        }
        return false;
      }else{
        good_match();
        return true; 
      }
    }
  }
  $('#chalkler_password_confirmation').change(function(){
    check_match(true)
  });
  $('#chalkler_password').change(function(){
    check_match(false)
  });
  $('#new_chalkler').submit(function(event){
    if(!check_match(true)){
      //event.preventDefault();
    }
  });
});