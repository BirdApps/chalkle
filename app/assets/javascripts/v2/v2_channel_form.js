$(function(){
  function check_url_available(new_value){
    if(new_value){
      var channel_id = $("#channel_id").val();
      console.log(channel_id);
      var url = '/providers/'+channel_id+'/url_available/'+new_value;
      $.getJSON(url, function(data){
        console.log(data);
      });
    }
  }

  $('#channel_url_name').change(function(){

    check_url_available($(this).val());
  });
});