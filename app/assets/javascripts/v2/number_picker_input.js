$(function(){
  var temp_val = "";
  function whole_positive_int(int){
    return /^[1-9]\d*$/.test(int);
  }
  function change_num(element, positive){
    $(element).focus();
    temp_val = $(element).val();
    if(temp_val == ""){
      temp_val = 1;
    }
    temp_val = parseInt(temp_val);
    if(positive){
      temp_val++;
    }else{
      temp_val--; 
    }
    test_val = temp_val;
    if($(element).data("zero")){
      test_val++;
    }
    if(whole_positive_int(test_val)){
      $(element).val(temp_val);
    }
  }
  $('.number-picker input').focus(function(){
    temp_val =$(this).val();
  });
  $('.number-picker input').change(function(){
    temp_val = $(this).val();
    test_val = temp_val;
    if($(this).data('zero')){
      test_val++;
    }
    if(!whole_positive_int(test_val)){
      $(this).val(temp_val);
    }

  });
  $('.number-picker .num-up').click(function(){
    change_num($(this).parent().siblings('input'), true);
  });
  $('.number-picker .num-down').click(function(){
    change_num($(this).parent().siblings('input'), false);
  });
});