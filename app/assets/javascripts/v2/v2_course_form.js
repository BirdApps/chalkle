$(function(){
  if($('.new_course_form_wrapper').length > 0){
    var monthly  = "";
    var repeating  = "";
    var repeat_count  = "";
    var weekdays = ["Sun","Mon", "Tues", "Wed", "Thurs","Fri","Sat"];
    var parts = ['#type','#details','#learning','#teaching','#summary','#submit'];
    var validate_off = false;
    var ready_to_submit = false;
    if(validate_off){
      alert("Warning: Validation is off");
    }

    /* initilizes on page load */
    function init(){
      $('#teaching_channel_id').change(get_teacher_list);
      $("#type .btn-group label").click(course_class_select);
      $('.update_class_count .number-picker-up').click(show_class_opts);
      $('.update_class_count .number-picker-down').click(show_class_opts);
      $('.update_class_count .number-picker-input').change(show_class_opts);
      $('.update_repeat_count .number-picker-up').click(set_repeat_count);
      $('.update_repeat_count .number-picker-down').click(set_repeat_count);
      $('.update_repeat_count .number-picker-input').change(set_repeat_count);
      $(".new_course_form_wrapper .parts").hide();
      $(".part_link").click(link_part_change);
      $('#teaching_repeat_frequency').change(set_monthly);
      $('#teaching_teacher_pay_type').change(set_teacher_pay_type);
      set_teacher_pay_type();
      $('#teaching_max_attendee').change(set_attendee_summary);
      $('#teaching_min_attendee').change(set_attendee_summary);
      set_attendee_summary();
      $('#teaching_repeating').change(set_repeating);
      $('form#new_teaching').courseCostCalculator({resource_name: 'teaching'});
      if($('#type_unchangable').length > 0){
        part_change( '#details' );
      }else{
        part_change("#type");
      }
      $('#teaching_cost').change(display_pay_type);
      display_pay_type();
      hijack_navigation();
      apply_inline_validation();
      get_teacher_list();
      bind_agree_terms();
      init_custom_fields();
      init_start_at();
      $('.new_course_form_wrapper').fadeIn();

      // stop changing selection away from address field when no address is set
      $('#teaching_venue_address').blur(function(){ if($('#teaching_longitude').val().length==0){ $(this).focus() } } );
    }

    function custom_field_has_options(field){
      return (['radio', 'checkbox'].indexOf(field) > -1)
    }

    function init_custom_fields(){
      var editing_label = null;

      $('#custom_field_ui .btn').click(function(){
        $('#customFieldModal').modal('show');
      });

      $('.custom_type').change(function(){
        var type = $(this).val();
        if(custom_field_has_options(type)){
          $('.check_box_options').show();
        } else {
          $('.check_box_options').hide();
        }
      });


      $('#create_custom_field_btn').click(function(){
        var type = $('#customFieldModal .custom_type').val();
        var type_name = $('#customFieldModal .custom_type option:selected').text();
        var prompt = $('#customFieldModal .custom_prompt').val();
        var tag;
        if(custom_field_has_options(type)){
          var options = $('#customFieldModal .custom_options').tagsinput('items');
          friendly_options ='<br />';
          $(options).each(function(option_i){
            friendly_options += '['+options[option_i]+'] '
          });
          tag = '<span class="label label-default" data-type="'+type+'" data-prompt="'+prompt+'" data-options="'+options+'"><span class="edit_label">'+type_name+': "'+prompt+'" '+friendly_options+'</span><span class="remove">&times;</span></span>'
        }else{
          tag = '<span class="label label-default" data-type="'+type+'" data-prompt="'+prompt+'"><span class="edit_label">'+type_name+': "'+prompt+'"</span><span class="remove">&times;</span></span>'
        }

        var error = "";
        if(prompt == undefined || prompt == ""){
          error += "Must provide a prompt."
        }
        if(type == undefined || type == ""){
          error += "Must select a format."
        }
        if(custom_field_has_options(type) && (options == undefined || options.length == 0 || options == "")){
          error += "Must provide options."
        }
        if(error == ""){
          $('#custom_field_tags').append(tag);
          $('#custom_field_tags .label .edit_label').click(function(){
            editing_label = $(this).parent();
            var prompt = $(this).parent().data('prompt');
            var type = $(this).parent().data('type');
            var options = $(this).parent().data('options');
           
            $('.custom_prompt').val(prompt);
            $('.custom_type').val(type);
            if(options != undefined){
              $(options.split(",")).each(function(option_i){
                $('.custom_options').tagsinput('add', options[option_i]);
              });
              $('.check_box_options').show();
            }
            $('#customFieldModal').modal('show');
          });

          $('#custom_field_tags .label .remove').click(function(){
            $(this).parent().remove();
            evaluate_custom_field_tags();
          });

          reset_custom_field_form();
        }else{
          alert(error);
        }
      });
      
      $('.custom_options').on('itemRemoved', function(event) {
        evaluate_custom_field_tags();
      });
      
      function evaluate_custom_field_tags(){
        var tags =  $('#custom_field_tags').children();
        var new_val = []
        $(tags).each(function(tag_i){
          var hash = {
            type: $(tags[tag_i]).data('type'),
            prompt: $(tags[tag_i]).data('prompt'),
            options: $(tags[tag_i]).data('options')
          }
          new_val.push(hash);
        });
        $('#teaching_custom_fields').val(JSON.stringify(new_val));
      }

      function reset_custom_field_form(){
        if(editing_label != null){
          $(editing_label).remove();
          editing_label = null;
        }
        evaluate_custom_field_tags();
        $('#customFieldModal .custom_prompt').val('');
        $('#customFieldModal .custom_type').val('text');
        $('#customFieldModal').modal('hide');
        $('.custom_options').tagsinput('removeAll');
        $('.check_box_options').hide();
      }

    }//init custom fields

    

    function display_pay_type(){
      if ( $('#teaching_cost').val() > 0 ){
        $("#teaching_teacher_pay_type").removeAttr("disabled");
        $(".teacher_pay_type_wrapper").show();
      }else{
        $("#teaching_teacher_pay_type").attr("disabled","disabled");
        $(".teacher_pay_type_wrapper").hide();
      }
    }

    function init_start_at(){
      set_monthly();
      set_repeating();
      set_repeat_count();
      $('.class-count').each(function(){
        apply_start_at_controls(this);
      });
    }

    function set_attendee_summary(){
      var min_max = $('#teaching_max_attendee').val()+$('#teaching_min_attendee').val();
      switch(min_max.trim()){
        case "":
          $('.min-max-attendee-summary').hide();
          break;
        default:
          $('.min-max-attendee-summary').show();
          break;
      }
    }

    function set_teacher_pay_type(){
      switch($('#teaching_teacher_pay_type').val()){
        case "Flat fee":
          $('.teaching_fee_summary').hide();
          $('.teaching_fee_wrapper').show();
          $('.teaching_flat_fee_summary').show();

          $('.teacher_fee_label').text('Teacher flat fee');
          break;
        case "Fee per attendee":
          $('.teaching_flat_fee_summary').hide();
          $('.teaching_fee_wrapper').show();
          $('.teaching_fee_summary').show();

          $('.teacher_fee_label').text('Teacher fee per attendee');
          break;
        default:
          $('.teaching_fee_wrapper').hide();
          $('.teaching_flat_fee_summary').hide();
          $('.teaching_fee_summary').hide();
          break;
      }
    }

    /* sets the monthly variable */
    function set_monthly(){
      monthly = $('#teaching_repeat_frequency').val() == 'monthly';
    }

    /* sets the repeat_count variable */
    function set_repeat_count(){
      repeat_count = parseInt($("#teaching_repeat_count").val());
    }

    /* sets the repeating variable and shows/hides repeating controls */
    function set_repeating(){
      repeating = $("#teaching_repeating").val() == 'repeating';
      if(repeating) {
        $('.repeating-options').show();  
      } else {
        $('.repeating-options').hide();
      }
    }

    /* Show correct number of class-divs */
    function show_class_opts(target_class_count){
      if(isNaN(target_class_count)){
        target_class_count = $('.update_class_count input').val();
      }
      var existing_class_count = $('.class-count').length;
      var difference = target_class_count - existing_class_count;

      /* add div.class-count that should exist */
      for(var i = 0; i < difference; i++){
        $($('.class-count-bumper').prev()).clone().insertBefore('.class-count-bumper');
        var inserted_element = $('.class-count-bumper').prev();
        //set the title to the class number
        $(inserted_element).find('.class-count-num').text(i+existing_class_count+1);
        $(inserted_element).find('.teaching_times_summary').text("");
        number_picker(inserted_element);
        apply_start_at_controls(inserted_element, true);
      }

      /* remove div.class-count that shouldn't exist */
      $('.class-count').each(function(index){
        if(index+1 > target_class_count){
          $(this).remove();
        }
      });
      
    }

    /* Retrieves list of teachers for a given channel and populates select element */
    function get_teacher_list(){
      var channel_id = $('#teaching_channel_id').val();
      var selected_val = -1;
      if($('#saved_teacher_id').length){
        selected_val = $('#saved_teacher_id').val();
      }
      if(!isNaN(channel_id)){
        $.getJSON('/providers/'+channel_id+'/teachers.json', function(data){
            $('#teaching_teacher_id').empty();
            if(data.length < 2){
              $('.teacher-select').hide();
            }else{
                $('.teacher-select').show();  
            }
            $.each(data, function(index,item) {
              if(item.id == selected_val){
               $('#teaching_teacher_id').append('<option selected="selected" value=' + item.id + '>' + item.name + '</option>');
              }else{
               $('#teaching_teacher_id').append('<option value=' + item.id + '>' + item.name + '</option>');
              }
            });
        });
      }
    }

    /* returns count of that weekday in the month preceeding a date, including that date */
    function nth_day_instance_date(instance_date) {
      var nth = 1;
      var date_lapse = new Date(instance_date.getFullYear(), instance_date.getMonth(), 1);
      while(date_lapse.getDate() != instance_date.getDate()){
        if(date_lapse.getDay() == instance_date.getDay()){
          nth++;
        }
        date_lapse.setDate(date_lapse.getDate()+1);
      }
      if(nth > 4){
        nth = 4;
      }
      return nth;
    }

    /* initializes a div.class-count (a set of time and duration controls) */
    function apply_start_at_controls(scope, clear_calender){
      var instance_time = "";
      var instance_date = "";
      var duration_hours  = "";
      var duration_minutes  = "";
     
      /* initilizes the start_at_controls */
      function start_at_controls_init() {
        $('#teaching_repeating').change(calculate_class_times);
        $('#teaching_repeat_frequency').change(calculate_class_times);
        $('#teaching_repeat_count').change(calculate_class_times);
        $('.teaching_repeat_count .number-picker .number-picker-down').click(calculate_class_times);
        $('.teaching_repeat_count .number-picker .number-picker-up').click(calculate_class_times);

        $(scope).find('.update_class_time').change(calculate_class_times);

        $(scope).find('.number-picker .number-picker-up').click(update_durations);
        $(scope).find('.number-picker .number-picker-down').click(update_durations);

        $(scope).find('#teaching_duration_hours').change(update_durations);
        $(scope).find('#teaching_duration_minutes').change(update_durations);
         date_time_picker_init();
         calculate_class_times(true);
      }

      function change_date_picker(e){
        if(e.date != undefined){
          instance_date = e.date;
          //update the minimum date of next datepicker to be this instance_date
          var next_date_picker = $(scope).next().find('.date-picker');
          if(next_date_picker.length){
            $(next_date_picker[0]).datepicker('setStartDate', e.date);
            //ensures the next class datetime cannot have a lesser number and be considered valid
            var next_hidden_start_at = $(scope).next().find('#teaching_start_at')[0];
            var next_hidden_date = new Date($(next_hidden_start_at).val());
            if(next_hidden_date < e.date){
              $(next_hidden_start_at).val("");
              var next_visible_date = $(next_date_picker).datepicker('getDate');
              if(next_visible_date == "Invalid Date" || next_visible_date < e.date){
                $(next_date_picker).datepicker('setDate', e.date);
                highlight_date_in_picker(next_date_picker);
              }
              $(scope).next().find('.teaching_times_summary').text("");
            }
          }
          update_teaching_start_at();
        }
      }

      /* initializes the datepicker and time picker */
      function date_time_picker_init() {
        update_durations();
        /*INIT DATE PICKER*/
        var date_picker = $(scope).find('.date-picker')[0];
        if(clear_calender != undefined){
          $(date_picker).empty();
        }

        var saved_datepick = $(scope).find('#teaching_start_at').data('init-date');
        if(saved_datepick){
          saved_datepick = new Date(saved_datepick);
        }else{
          saved_datepick = new Date(+new Date + 12096e5);
        }
        instance_date = saved_datepick;

        $(date_picker).datepicker({
          startDate: new Date() //instance_date
        }).on('changeDate', change_date_picker);
        
        $(date_picker).datepicker('update',saved_datepick);
        highlight_date_in_picker(date_picker);
        
        /*INIT TIME PICKER*/
        var time_picker = $(scope).find('.time-picker')[0];
        $(time_picker).timepicker({
                    minuteStep: 5,
                    showInputs: false,
                    disableFocus: true
        }).on('changeTime.timepicker', function(e) {
          instance_time = e.time;
          update_teaching_start_at();
        });
        saved_timepick = $(scope).find('#saved_timepick').val();
        $(time_picker).timepicker('setTime', (saved_timepick==''?'6:00 PM':saved_timepick)); 
      }

      /* issue with plugin is when you set date it doesn't highlight - this is fix */
      function highlight_date_in_picker(date_picker){
        var date = $(date_picker).datepicker('getDate');
        if(date == 'Invalid Date'){
          date = instance_date
        }
        if(date instanceof Date){
          highlight_text = date.getDate();
          var highlight_element = $(date_picker).find('td.day:contains('+highlight_text+')').filter(function(){
              return $(this).text() == highlight_text;
          });
          highlight_element.each(function(){
            if(!$(this).hasClass('old') && !$(this).hasClass('new')){
              $(this).addClass('active')
            }
          });

        }
      }

      /* if there is acceptable information to make a class, displays human readable explanation of that classe's scheduled time */
      function calculate_class_times(ignore_invalid) {
        var teaching_time_summary = $(scope).find('.teaching_times_summary')[0];
        if(instance_date && instance_time && ( duration_hours != 0 || duration_minutes != 0 )){
          var start_time = make_time(instance_date.getHours(), instance_date.getMinutes(),0,0);
          var end_time = make_time(instance_date.getHours(), instance_date.getMinutes(), duration_hours, duration_minutes);
          var class_time_summary = "";

          repeating = repeating && repeat_count > 1;
          if(repeating && monthly) {
            //monthly
            var wday = instance_date.getDay();
            var date_lapse = new Date();
            date_lapse.setYear(instance_date.getFullYear());
            date_lapse.setMonth(instance_date.getMonth() + parseInt(repeat_count) - 1);
            date_lapse.setDate(1);
            var target_nth = nth_day_instance_date(instance_date);
            var end_date = nth_day_of(target_nth, wday, date_lapse, instance_date);
            class_time_summary += ordinal(target_nth)+" "+weekdays[wday]+" of every month from "+instance_date.toDateString()+" until "+end_date.toDateString();
          }else if(repeating && !monthly){
            //weekly
            var end_date = new Date();
            end_date.setMonth(instance_date.getMonth());
            end_date.setDate(instance_date.getDate()+7*(repeat_count-1));
            class_time_summary += " Weekly from "+instance_date.toDateString()+" until "+end_date.toDateString();
          }else if(!repeating){
            //once-off
            class_time_summary += instance_date.toDateString();  
          }
             
          class_length_in_hours = (instance_date.getHours()*60 + duration_hours*60+duration_minutes)/60;
          if(class_length_in_hours > 24){
            //more than a day long
            //start_time = weekdays[instance_date.getDay()] + " " + start_time
            end_date = date_clone(instance_date);
            end_date.setDate(end_date.getDate() + Math.floor(class_length_in_hours/24));
            end_time = weekdays[end_date.getDay()] + " " + end_time;
          }
          class_time_summary += " between "+start_time;
          class_time_summary += " and "+end_time;
          //if(class_time_summary.indexOf('Invalid Date') == -1){
            $(teaching_time_summary).html(class_time_summary);
          //}
        } else {
          $(teaching_time_summary).empty();
        }
        $(teaching_time_summary).siblings('.form-error').remove();
      }

      /* validates and/or corrects duration input 
       * sets hidden duration input elements
       */
      function update_durations(){
        duration_hours = $(scope).find('#teaching_duration_hours').val();
        duration_minutes = $(scope).find('#teaching_duration_minutes').val();
        duration_hours = (!isNaN(duration_hours) && duration_hours) ? Math.floor( parseInt(duration_hours)) : 0;
        duration_minutes = ( !isNaN(duration_minutes) && duration_minutes) ? Math.floor( parseInt(duration_minutes)) : 0;
        if( duration_hours > 167 ) { duration_hours = 167 }
        if( duration_minutes > 59 ) { duration_minutes = 59 }
        $(scope).find('#teaching_duration_minutes').val(duration_minutes);
        $(scope).find('#teaching_duration_hours').val(duration_hours) 
        calculate_class_times();
      }

      /* calculates the start_at and stored in hidden input, 
       * runs function to display changes in UI 
       */
      function update_teaching_start_at() {
        if(instance_date!=null){
          if(instance_time != null){
            var start_hours = instance_time.hours;
            if(instance_time.meridian == "PM"){
              start_hours += 12;
            }
            if(start_hours == 24){
              start_hours = 12;
            }
            if(start_hours == 12){
              if(instance_time.meridian == "AM"){
                start_hours = 0;
              }
            }
            var start_minutes = instance_time.minutes;
            instance_date.setHours(start_hours,start_minutes,0,0);  
          }
          $(scope).find('#teaching_start_at').val(instance_date);
        }
        calculate_class_times();
      }
      start_at_controls_init();
    }

    /* collects the information set throughout the form and displays it on the summary page */
    function summarize(){
      $('[id^=teaching_]').each(function(){
        var val = "";
        if($(this).is("select")){
          val = $(this).find("option:selected").text();
        }else if($(this).is("input") || $(this).is("textarea")){
          val = $(this).val();
        }else{
          val = $(this).text();
        }
        if(val != ""){
          var target = this.id.split('teaching_')[1];
          var target = '#summary_'+this.id.split('teaching_')[1];
          if($(target).is('input')){
            if($(target).hasClass('currency')){
              $(target).val('$'+val);
            }else{
              $(target).val(val); 
            }
          }else{
            $(target).html(val);
          }
        }
      });
      $("#summary_times_summary").empty();
      $('.teaching_times_summary').each(function(){
        var summary_time = $("#summary_times_summary").append($(this).clone());
        $(summary_time).addClass('no-validate');
      });
    }

    //---START NAVIGATION 
    function navigate_to_invalid(location){
      var prev_location = parts[parts.indexOf(location)-1]; 
      if(!$(prev_location).is(':visible')){
        part_change(prev_location, true);
      }else{
        $('.form-error').remove();
        validate_part(location);
      }
    }

    function show_error_for(element, error_msg, focus){
      if($(element).length > 0){
        if(focus == undefined){
          focus = true;
        }
        if(error_msg == undefined){
          error_msg = $(element).data('error-message');
        }
        if(!$(element).siblings('.form-error').length){
          $(element).after('<div class="info form-error">'+error_msg+'</div>');
          $(element).parent().removeClass('hidden');
        }
        if(focus){
          if(isScrolledIntoView(element)){
            $(element).focus();
          }else{
            var scroll_to = $(element).offset().top - 150;
            $("html, body").animate({ scrollTop: scroll_to }, "slow", function(){
              $(element).focus();
            });
          }
        }
      }
    }

    function isScrolledIntoView(elem)
    {
      if ($(elem).length > 0){
        var docViewTop = $(window).scrollTop();
        var docViewBottom = docViewTop + $(window).height();
        var elemTop = $(elem).offset().top;
        var elemBottom = elemTop + $(elem).height();

        return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));
      }else{
        return false;
      }
    }

    function validate_type(){   
      //return !!$('.course-class-radio:checked').val();
      return true;
    }

    function validate_element(elem){
     if(!!!$(elem).val() && !$(elem).is('div') && !$(elem).is('label')) {
        show_error_for(elem);
        return false
      }
      return true;
    }

    function validate_basics(location){
      var valid = true;
      $(location).find('[data-error-message]').each(function(){ 
        if(valid && $(this).data('validate-complex') == null){
          valid = validate_element(this);
        }
      });
      return valid;
    }

    function apply_inline_validation(){
      $('[data-error-message]').each(function(){
        $(this).focusout(function(){
          if(!!!$(this).val() && !$(this).is("div") && !$(this).is('label')){
            show_error_for(this, undefined, false);
          }else{
            $(this).siblings('.form-error').remove();
          }
        });
      });
    }

    function validate_details(){
      var valid = true;
      valid_basics = validate_basics('#details');
      //validate complex
      if(repeating){
        valid = validate_element($('#teaching_repeat_frequency'));
      }

      //validate the datetime pickers by their output
      $('.teaching_times_summary').each(function(){
        if($(this).text() == ""){
          valid = false;
          show_error_for(this,'Ensure a valid date, time, and duration for this class');
        }
      });
      return valid && valid_basics;
    }

    function validate_learning(){
      return validate_basics('#learning');
    }

    function validate_teaching(){
      var valid = true;
      valid_basics = validate_basics('#teaching');

      //validate complex
      if($('#teaching_cost').val() > 0 && $('#teaching_teacher_pay_type').length > 0 ){
        valid = validate_element($('#teaching_teacher_pay_type'));
      }

      if($('#teaching_longitude').val() == "" && $('#teaching_venue_address').length > 0)
      {
        valid = false;
        show_error_for($('#teaching_venue_address'));
      }
      var min_a = $('#teaching_min_attendee').val();
      var max_a = $('#teaching_max_attendee').val();
      if(!isNaN(min_a) && !isNaN(max_a) && parseInt(min_a) > parseInt(max_a))
      {
        valid = false;
        show_error_for($('.min-max-error'));
      }
      if(!isNaN(min_a) && min_a < 0)
      {
        valid = false;
        show_error_for($('.min-max-error'), "Minimum attendee cannot be negative");
      }
      if(!isNaN(max_a) && max_a < 0)
      {
        valid = false;
        show_error_for($('.min-max-error'), "Maximum attendee cannot be negative");
      }
      var teaching_cost = $('#teaching_cost').val();
      if(isNaN(teaching_cost) || teaching_cost < 0)
      {
        valid = false;
        show_error_for($('#teaching_cost'), "Advertised price cannot be less than 0");
      }
      var teacher_cost = $("#teaching_teacher_cost").val();
      if(teacher_cost < 0)
      {
        valid = false;
        show_error_for($('#teaching_teacher_cost'), "Teacher fee cannot be less than 0");
      }
      return valid && valid_basics;
    }

    function validation_submit(){
      var valid = true;
      if(!$('#teaching_agreeterms input').is(':checked'))
      {
        valid = false;
        show_error_for($('#teaching_agreeterms'));
      }
      if($('#providing_agreeterms').length > 0){
        if(!$('#providing_agreeterms input').is(':checked'))
        {
          valid = false;
          show_error_for($('#providing_agreeterms'));
        }
      }
      return valid;
    }

    function bind_agree_terms(){
      //$('input[name=teaching_agreeterms]').change(validation_submit);
    }

    function validate_part(location){
      var valid = true;
      if(location == '#type'){ return valid; }
      if(valid){ valid = validate_type(); }
      if(parts.indexOf(location) <= parts.indexOf('#details')){ return valid; }
      if(valid){  valid = validate_details(); }
      if(parts.indexOf(location) <= parts.indexOf('#learning')){ return valid; }
      if(valid){ valid = validate_learning(); }
      if(parts.indexOf(location) <= parts.indexOf('#teaching')){ return valid; }
      if(valid){ valid = validate_teaching(); }
      if(parts.indexOf(location) <= parts.indexOf('#summary')){ return valid; }
      if(valid){ valid = validation_submit(); }
      return valid;
    }

    /* shows the part of the form that matches the location anchor */
    function part_change( location, keep_errors, scroll ){
      if(scroll == undefined){
        scroll = false;
      }
      location = (typeof location == 'undefined') ? window.location.hash : location;
      var valid = validate_part(location);
      if(valid || validate_off){
        if(!keep_errors){
          $('.form-error').remove();
        }
        $(".new_course_form_wrapper .parts").fadeOut();
        $(location).delay(350).fadeIn(400, setMap);
        $(".new_course_form_wrapper .breadcrumb li").removeClass('active')
        $(location+'-link').parent().addClass('active');
        if(location == '#summary'){
          summarize();
        }
        if(location == '#submit'){
          ready_to_submit = true;
          $('#new_teaching').submit();
        }
        if(scroll){
          top = 0;
          if( $(window).width() > 768 ){
            top = 207;
          }
          $("html, body").animate({ scrollTop: top }, "slow");
        }
      }else{
        navigate_to_invalid(location);
      }
    };

    /* makes the target href for the form anchors trigger form part changes */
    function link_part_change(e){
      if($(this).hasClass('btn')){
        part_change($(this).attr('href'),false,true);
      }else{
        part_change($(this).attr('href'),false,false);
      }
      e.preventDefault();
    }

    /* handles changing between course or class on the first form part */
    function course_class_select(){
      part_change( '#details' );
      var key_word = $($(this).children('input')[0]).val();
      $('#teaching_course_class_type').val(key_word);
      if(key_word == "class"){
       // inputs_to_array(false);
        $('.course_only').hide();
        $('.class_only').show();
        show_class_opts(1);
      }else{
        repeating = false;
       // inputs_to_array(true);
        $('.class_only').hide();
        $('.course_only').show();
        $('#teaching_repeating').val('once-off');
        show_class_opts();
      }
    }

    function setMap() {
      var lat = $('#teaching_latitude').val();
      var lng = $('#teaching_longitude').val();
      var latlng = new google.maps.LatLng(lat, lng);
      if(lat != "" && lng != ""){
        var styles = [
          {
            stylers: [
              { visibility: "simplified" },
              { weight: 1.3 },
              { hue: "#5e00ff" },
              { saturation: -85 },
              { gamma: 1.16 },
              { lightness: 13 }
            ]
          }
        ];
        var styledMap = new google.maps.StyledMapType(styles, {name: "Styled Map"});
        var mapOptions = {
          center: latlng,
          zoom: 15,
          mapTypeControlOptions: {
            mapTypeIds: [google.maps.MapTypeId.ROADMAP, 'map_style']
          }
        };
        var map = new google.maps.Map(document.getElementById("map-canvas"),
            mapOptions);
        map.mapTypes.set('map_style', styledMap);
        map.setMapTypeId('map_style');
        var marker = new google.maps.Marker({
          position: latlng,
          map: map,
          title: 'Class location'
      });
      }
    }

    function get_location(){
      return $('.breadcrumb li.active a').attr('href');
    }

    function hijack_navigation(){
      window.onbeforeunload = function () {
        if(!ready_to_submit && !validate_off){
          return "The class has not been saved.";
        }        
      }
    }

    //---END NAVIGATION

    //---START LIBRARY-ISH
    /* combines a time + hours + minutes to human readable form */
    function make_time(hours, minutes, add_hours, add_minutes) {
      hours = parseInt(hours.toString())+parseInt(add_hours.toString());
      minutes = parseInt(minutes.toString())+parseInt(add_minutes.toString());
      var meridian = "AM";
      if(hours%24 >= 12) {
        meridian = "PM";
      }
      if(hours > 12) {
        hours = hours % 12;
        if(hours == 0) {
          hours = 12
        }      
      }
      if(minutes > 59){
        hours = hours + Math.floor(minutes/60);
        minutes = minutes % 60;
      }
      if(minutes < 10){
        minutes = "0"+minutes
      }
      return hours+":"+minutes+" "+meridian;
    }

    /* returns the nth weekday after a day */
    function nth_day_of(target_nth, wday, date_lapse, instance_date){
      var nth = 0;
      while(nth != target_nth){
        if(date_lapse.getDay() == instance_date.getDay()){
          nth++;
        }
        date_lapse.setDate(date_lapse.getDate()+1);
      }
      date_lapse.setDate(date_lapse.getDate()-1);
      return date_lapse;
    }

    /* 1 returns 1st, 222 returns 222nd, 34 returns 34th, etc. */
    function ordinal(num){
      parts = num.toString().split('');
      ordinal_num = parts[parts.length-1];
      switch(ordinal_num){
        case "1":
          return num+"st";
        case "2":
          return num+"nd";
        case "3":
          return num+"rd";
        default:
          return num+"th";
      }
    }

    /* clones a date so the new variable is not just a pointer */
    function date_clone(instance_date){
      clone = new Date();
      clone.setYear(instance_date.getFullYear());
      clone.setMonth(instance_date.getMonth());
      clone.setDate(instance_date.getDate());
      return clone;
    }

    //---END LIBRARY-ISH
    init();
  }
});