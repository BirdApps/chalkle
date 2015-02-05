$(function(){
  if($("#new_booking_set").length > 0){
    var last_view = "part-question";
    var template = $('#attendee_template').html();
    $('#attendee_template').remove();

    function show_attendee(attendee_i){
      var attendees = $('.attendee');
      if(attendees.length-1 < attendee_i) {
        attendee_i = attendees.length-1;
      }
      $(attendees).hide();
      $(attendees[attendee_i]).show();
      $('#booking_names li').removeClass("selected");
      $(".attendee_id_"+attendee_i).addClass("selected");
      show_form();
    }

    function bind_attendee_links(){
      $("#booking_names li").click(function(){
        var attendee_i = $(this).data('attendee');
        show_attendee(attendee_i);
      });

      $('.remove_attendee').click(function(){
        var attendee_i = $(this).parent().data('attendee');
        remove_attendee(attendee_i);
      });

      $('.add_attendee').click(add_attendee);
    }

    function update_selected_booking_name(){
      var selected_i = $('.attendee').index( $('.attendee:visible') );
      var new_val = $('.attendee:visible .booking_names').val();
      $('.attendee_id_'+selected_i+' .attendee_name').html(new_val);
      return false;
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
            remove = "<span class='remove_attendee'>×</span>"
          }
          $("#booking_names ol").append("<li data-attendee="+name_i+" class='attendee_id_"+name_i+"''><span class='attendee_name'>"+name+"</span>"+remove+"</li>");
        });
        $("#booking_names ol").append("<li class='add_attendee'><a class='add_attendee'><span></span>+ Attendee</a></li>");
        bind_attendee_links();
        $("#booking_names").fadeIn();
      }else{
        $("#booking_names").fadeOut();
      }
    }

    function add_attendee(event){
      event.preventDefault();
      $('#attendees').append(template);
      set_booking_names();
      show_attendee( $(".attendee").length -1 );
      $(".booking_names").keyup(update_selected_booking_name);
      $(".booking_names").change(update_selected_booking_name);
      $('.email_input').keyup(check_for_existing_chalklers_by_email);
      $('.email_input').change(check_for_existing_chalklers_by_email);
    }

    function remove_attendee(attendee_i){
      if(attendee_i != 0){
        var attendees = $('.attendee');
        $(attendees[attendee_i]).remove();
        set_booking_names();
        show_attendee(attendee_i);
      }
    }

    function check_for_existing_chalklers_by_email(e){
      var value = $(e.target).val();
      var re =  /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      re.test(value);
      if( value.length>0 && re.test(value) ){
        $.ajax({
          type: 'POST',
          url: '/people/exists', 
          data: { email: value },
          success: function(data){
            if(data) {
              $(e.target).parent().siblings(".booking_set_bookings_invite_chalkler").fadeOut(function(){
                $(e.target).parent().siblings(".booking-email-info").fadeIn();
              });
            } else {
              $(e.target).parent().siblings(".booking-email-info").fadeOut(function(){
                $(e.target).parent().siblings(".booking_set_bookings_invite_chalkler").fadeIn();
              });
            }
          },
          dataType: 'json'
        })
      } else {
        $(e.target).parent().siblings(".booking_set_bookings_invite_chalkler").fadeOut();
        $(e.target).parent().siblings(".booking-email-info").fadeOut();
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
      $('.booking-count').text(attendee_count);
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

      //arrange first email
      var first_email = $(".booking_set_bookings_email")[0];
      $(first_email).hide();
      var first_booking_name = $(".booking_names")[0];
      $(first_booking_name).keyup(function(){
        $(first_email).fadeIn();
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
    set_booking_names();
    show_attendee(0);
  }
});

