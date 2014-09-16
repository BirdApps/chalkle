$(function(){
  var prev_val = "";
  function make_money(valu, tryround){
    if(/\d+\.\d{2}/.test(valu)){
      return valu;
    }else if(/\d+\.\d{1}/.test(valu)){
      return valu+"0";
    }else if(/^[1-9]\d*$/.test(valu)){
      return valu+".00";
    }else{
      if(tryround){
        return make_money(parseInt(valu).toFixed(2), false);
      }
      return false;
    }
  }
  $('.currency-input').focus(function(){
    prev_val =$(this).val();
  });
  $('.currency-input').change(function(){
    var valu = make_money($(this).val(), true);
    if(valu == false){
      $(this).val(prev_val);
    }else{
      $(this).val(valu);
    }
  });
});