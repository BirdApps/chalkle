$(function(){
  if($("#new_booking_set").length > 0){
    var last_view = "part-question";
    var group_single = "single"
    var template = $('#attendee_template').html();
    $('#attendee_template').remove();

    function show_attendee(attendee_i){
      var attendees = $('.attendee');
      $(attendees).hide();
      $(attendees[attendee_i]).show();
      show_form();
    }

    function bind_attendee_links(){
      $("#booking_names ol li").click(function(){
        var attendee_i = $(this).data('attendee');
        show_attendee(attendee_i);
      });
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
          $("#booking_names ol").append("<li data-attendee="+name_i+">"+name+"</li>");
        });
        bind_attendee_links();
        $("#booking_names").fadeIn();
      }else{
        $("#booking_names").fadeOut();
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

      $('.prev_attendee').unbind( "click" );
      $('.next_attendee').unbind( "click" );

      $('.prev_attendee').click(function(){
        var parent = $(this).parents('.attendee').first();
        var prev = $(parent).prev();
        if( $(prev).hasClass('attendee') ){
          $(parent).fadeOut(function(){
            $(prev).fadeIn();
          });
        }else{
          $('.parts').hide();
          if(group_single == "single"){
            $('.part-question').fadeIn();
          }else{
            $('.part-count').fadeIn();
          }
        }
      });

      $('.next_attendee').click(function(){
        var parent = $(this).parents('.attendee').first();
        var next = $(parent).next();
        
        if( $(parent).find('#booking_set_bookings__name').val() == "" ){
          alert("Every booking must have a name");
        }else{
          set_booking_names();
          if( $(next).hasClass('attendee') ){
            $(parent).fadeOut(function(){
              $(next).fadeIn();
            });
          }else{
            show_summary();
          }
        }

      });
      set_booking_names();
      $(".attendee").hide();
      $($(".attendee")[0]).show();
    }

    function show_summary(){
      var cost = $("#booking-summary").data('cost');
      var attendee_count = $('.attendee').length;
      $('.booking-count').text(attendee_count);
      if(parseFloat(cost) != 0){
       $('.total-cost').text('$'+(attendee_count*cost).toFixed(2).toString());
      }
      $('.parts').hide();
      $('.part-summary').fadeIn();
    }

    function back(){
      show_form();
    }

    function show_form(){
      $('.parts').hide();
      $('.part-form').fadeIn();
    }

    function bind_keys(){
      $('.set_single').click(function(){
        change_attendee_count(1);
        
        group_single = "single";
      });

      $('.back').click(back);
  
      $('.set_group').click(function(){
        group_single = "group";
      });

      $('.see_form').click(function(){
        show_form();
      });

      $('.see_number').click(function(){
        $('.parts').hide();
        $('.part-count').fadeIn();
      });

      $('.count_attendees').click(function(){
        change_attendee_count($('#booking_set_count').val());
      });

      $('#new_booking_set').submit(function(event){
        if($('#booking_terms_and_conditions:checked').length == 0){
          alert($('#teaching_agreeterms').data('error-message'));
          event.preventDefault();
        }
      });

      $('button').click(function(){
        if($(this).data('target-part') != undefined){
          last_view = $(this).data('target-part');
        }
      });

      $('#new_booking_set').submit(validate);
    }

    function validate(){
      var has_names = $('.booking_names').filter(function(){ return $(this).val() != "" }).length == $('.booking_names').length;
      if(!has_names){
        alert('All attendees must have names');
        return false;
      }
    }
   

    bind_keys();

  }
});

