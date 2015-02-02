$(function(){
  if($("#new_booking_set").length > 0){
    var last_view = "part-question";
    var group_single = "single"
    var template = $('#attendee_template').html();
    $('#attendee_template').remove();

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
        var next = $(this).parents('.attendee').next();
        if( $(next).hasClass('attendee') ){
          $(parent).fadeOut(function(){
            $(next).fadeIn();
          });
        }else{
          show_summary();
        }
      });
      $(".attendee").hide();
      $($(".attendee")[0]).show();
    }

    function show_summary(){
      $('.parts').hide();
      $('.part-summary').fadeIn();
    }

    function back(){
      $('.parts').hide();
      show_form();
    }

    function show_form(){
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
        $('.parts').hide();
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

    }

   

    bind_keys();

  }
});

