$(function(){
  if($("#new_booking_set").length > 0){
    var last_view = "part-question";
    var template = $('#attendee_template').html();
    $('#attendee_template').remove();

    function show_attendee(attendee_i){
      var attendees = $('.attendee');
      $(attendees).hide();
      $(attendees[attendee_i]).show();
      show_form();
    }

    function bind_attendee_links(){
      $("#booking_names .attendee_name").click(function(){
        var attendee_i = $(this).parent().data('attendee');
        show_attendee(attendee_i);
      });

      $('.remove_attendee').click(function(){
        var attendee_i = $(this).parent().data('attendee');
        remove_attendee(attendee_i);
      });

      $('.add_attendee').click(add_attendee);
    }

    function set_booking_names(){
      $("#booking_names ol").html('');
      var booking_names = $('.booking_names').filter(function(){ return $(this).val() != "" });
      if(booking_names.length > 0){
        $('.booking_names').each(function(name_i){
          var name = $(this).val();
          if(name == ""){
            name = "New Attendee";
          }
          var remove = "";
          if(name_i != 0){
            remove = "<span class='remove_attendee'> — </span>"
          }
          $("#booking_names ol").append("<li data-attendee="+name_i+"><span class='attendee_name'>"+name+"</span>"+remove+"</li>");
        });
        $("#booking_names ol").append("<li class='add_attendee'><span></span>Add Attendee</li>");
        bind_attendee_links();
        $("#booking_names").fadeIn();
      }else{
        $("#booking_names").fadeOut();
      }
      ensure_attendee_visible();
    }

    function ensure_attendee_visible(){
      if($("#attendees").is(":visible")){
        var visible_Attendees = $('.attendee').filter(function(){ return $(this).is(":visible") });
        if(visible_Attendees.length == 0){
          show_attendee( $(".attendee").length-1 );
        }
      }
    }

    function add_attendee(){
      $('#attendees').append(template);
      set_booking_names();
      show_attendee( $(".attendee").length -1 );
      $(".booking_names").change(set_booking_names);
    }

    function remove_attendee(attendee_i){
      if(attendee_i != 0){
        var attendees = $('.attendee');
        $(attendees[attendee_i]).remove();
        set_booking_names();
      }
    }

    function change_attendee_count(count){
      var difference = count - $('#attendees').children().length
      if(difference > 0){
        for(var i = 0; i < difference; i++){
          $('#attendees').append(template);
        }
      }else{
        for(var i = 0; i < difference; i++){
          $('#attendees').children().last().remove();
        }
      }

      set_booking_names();
    }



    function show_summary(){
      var cost = $("#booking-summary").data('cost');
      var attendee_count = $('.attendee').length;
      if(parseFloat(cost) != 0){
       $('.total-cost').text('$'+(attendee_count*cost).toFixed(2).toString()+" - ");
      }
      $('.parts').hide();
      $('.part-summary').fadeIn();
    }

    function show_form(){
      $('.parts').hide();
      $('.part-form').fadeIn();
    }

    function bind_keys(){
      $('.continue').click(function(){      
        if( validate() ){
          show_summary();
        }
      });

      $('.back').click(show_form);
  
      $('#new_booking_set').submit(function(event){
        if(validate()){
          if($('#booking_terms_and_conditions:checked').length == 0){
            alert($('#teaching_agreeterms').data('error-message'));
            event.preventDefault();
          }
        }else{
          event.preventDefault();
        }
      });
    }

    function validate(){
      var blank_names = $('.booking_names').filter(function(){ return $(this).val() == "" });
      if(blank_names.length > 0){
        alert('Every attendee must have a name');
        return false;
      }else{
        return true;
      }
    }
   

    bind_keys();
    show_attendee(0);
    set_booking_names();
  }
});

