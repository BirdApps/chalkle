function number_picker(scope){
  var prev_val;
  function whole_positive_int(int){
    return /^[0-9]\d*$/.test(int);
  }
  function change_num(element, increment){
    if(isNaN(prev_val)){
      data_min = $(element).data('min');
      prev_val = isNaN(data_min) ? 0 : data_min;
    }
    $(element).focus();
    if(increment){
      new_val = prev_val+1;
    }else{
      new_val = prev_val-1;
    }
    $(element).val(validate_picker_val(element, new_val));
  }

  function validate_picker_val(element, this_val){
    var data_min = $(element).data('min');
    var data_max = $(element).data('max');
    var min_error = $(element).data('min-error');
    var max_error = $(element).data('max-error');
    data_min = isNaN(data_min) ? 0 : data_min;
    data_max = isNaN(data_max) ? 9999999 : data_max;
    min_error = min_error ? min_error : 'Minimum is '+data_min;
    max_error = max_error ? max_error : 'Maximum is '+data_max;
    this_val = isNaN(this_val) ? $(element).val() : this_val; 

    var return_val;
    if(!whole_positive_int(this_val)){
      return_val = prev_val;
    } else {
      if(whole_positive_int(data_min)){
        if(this_val < data_min){
          this_val = data_min;
          alert(min_error);
        }else if(this_val > data_max){
          this_val = data_max;
          alert(max_error);
        }
      }
      prev_val = this_val;
      return_val = this_val;
    }
    return return_val;
  }

  //stored previous variable to revert if new input invalid
  $(scope).find('.number-picker-input').focus(function(){
    this_val = $(this).val();
    if(whole_positive_int(this_val)){
      prev_val = parseInt(this_val);
    }
  });

  // input_invalid ? revert : update;
  $(scope).find('.number-picker-input').change(function (){
    $(this).val(validate_picker_val(this));
  });
  $(scope).find('.number-picker-up').click(function(){
    change_num($(this).parent().siblings('input'), true);
  });

  $(scope).find('.number-picker-down').click(function(){
    change_num($(this).parent().siblings('input'), false);
  });
};

$(function(){
  $('.number-picker').each(function(){
    number_picker(this);
  });
});