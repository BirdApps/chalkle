$(function(){
  if($("#new_booking_set").length > 0){
    var last_view = "part-question";
    var group_single = "single"
    var template = $('#attendee_template').html();

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
        var parent = $(this).parent('.attendee');
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
        var parent = $(this).parent('.attendee');
        var next = $(this).parent('.attendee').next();
        if( $(next).hasClass('attendee') ){
          $(parent).fadeOut(function(){
            $(next).fadeIn();
          });
        }else{
          show_summary();
        }
      });

      $($("#attendees").children()[0]).show();
    }

    function show_summary(){
      $('.parts').hide();
      $('.part-summary').fadeIn();
    }

    function back(){
      if(group_single == "single"){
        $('.parts').hide();
        $('.part-question').fadeIn();
      }else{
        $('.parts').hide();
        show_form();
      }
    }

    function show_form(){
      $('.part-form').fadeIn();
    }

    function bind_keys(){
      $('.set_single').click(function(){
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

      $('#new_booking').submit(function(event){
        if($('#booking_terms_and_conditions:checked').length == 0){
          alert($('#teaching_agreeterms').data('error-message'));
          event.preventDefault();
        }
      });

      $('button').click(function(){
        if($(this).data('view') != undefined){
          last_view = $(this).data('view');
        }
      });

    }

   

    bind_keys();

  }
});

