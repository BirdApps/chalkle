$(function(){
  var prev_val = "";
  $('.currency-input').focus(function(){
    prev_val =$(this).val();
  });
  $('.currency-input').change(function(){
    var valu = $(this).val();
    valur = parseFloat(valu).toFixed(2);
    console.log(valu);
    if(isNaN(valu)){
      $(this).val(prev_val);
    }else{
      $(this).val(valu);
    }
  });
});