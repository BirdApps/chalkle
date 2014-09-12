$(function(){

  var monthly  = "";
  var repeating  = "";
  var repeat_count  = "";
  var weekdays = ["Sun","Mon", "Tues", "Wed", "Thurs","Fri","Sat"];
  var parts = ['#type','#details','#learning','#teaching','#summary','#submit'];
  var validate_off = false;

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
    $('#teaching_repeating').change(set_repeating);
    $('form#new_teaching').courseCostCalculator({resource_name: 'teaching'});
    part_change("#type");
    apply_inline_validation();
    get_teacher_list();
    init_start_at();
    image_preview();
    $('#teaching_course_upload_image').change(image_preview);
    $('.new_course_form_wrapper').fadeIn();
  }

  function init_start_at(){
    $('.class-count').each(function(){
      apply_start_at_controls(this);
    });
  }

  /* updates the image preview from local file */
  function image_preview(){
    var input = $('#teaching_course_upload_image')[0];
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            $('.image-preview .img').css('background-image', 'url('+e.target.result+')');
        }
        reader.readAsDataURL(input.files[0]);
    }
  }

  /* sets the monthly variable */
  function set_monthly(){
    monthly = $(this).val() == 'monthly';
  }

  /* sets the repeat_count variable */
  function set_repeat_count(){
    repeat_count = parseInt($("#teaching_repeat_count").val());
  }

  /* sets the repeating variable and shows/hides repeating controls */
  function set_repeating(){
    repeating = $(this).val() == 'repeating';
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
    if(channel_id == ""){
      channel_id = 0;
    }
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
      $(scope).find('.update_class_time').change(calculate_class_times);
      $(scope).find('.number-picker .number-picker-up').click(update_durations);
      $(scope).find('.number-picker .number-picker-down').click(update_durations);
      $(scope).find('#teaching_duration_hours').change(update_durations);
      $(scope).find('#teaching_duration_minutes').change(update_durations);
       date_time_picker_init();
       calculate_class_times(true);
    }

    function change_date_picker(e){
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

    /* initializes the datepicker and time picker */
    function date_time_picker_init() {
      update_durations();
      /*INIT DATE PICKER*/
      var date_picker = $(scope).find('.date-picker')[0];
      if(clear_calender != undefined){
        $(date_picker).empty();
      }
      $(date_picker).datepicker({
        startDate: new Date()
      }).on('changeDate', change_date_picker);

      //sets the initial date of the picker
      var saved_datepick = $(scope).find('#teaching_start_at').data('init-date');
      if(saved_datepick){
        saved_datepick = new Date(saved_datepick);
      }else{
        saved_datepick = new Date(+new Date + 12096e5);
      }
      $(date_picker).datepicker('setDate', saved_datepick);
      highlight_date_in_picker(date_picker);
      
      //sets the scoped variable to match the picker
      instance_date = $(scope).find('.date-picker').datepicker('getDate');

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
        repeating = repeating && repeat_count > 1
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
        $(teaching_time_summary).html(class_time_summary);
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
          if(start_hours == 0){
            start_hours = 12;
          }else if(start_hours == 12 ){
            start_hours = 0;
          }
          var start_minutess = instance_time.minutes;
          instance_date.setHours(start_hours,start_minutess,0,0);  
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
          $(target).val(val);
        }else{
          $(target).html(val);
        }
        //calculate_costs();
      }
    });
    $("#summary_times_summary").empty();
    $('.teaching_times_summary').each(function(){
      var summary_time = $("#summary_times_summary").append($(this).clone());
      $(summary_time).addClass('no-validate');
    });
  }

  function calculate_costs(){
    // var cost = 0.00;
    // var ven_cost = $('#summary_venue_cost').val();
    // if(!isNaN(ven_cost)){
    //   cost = parseFloat(ven_cost)+cost;
    // }
    // $('#summary_fixed_cost').val('$'+cost.toFixed(2));
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

  function show_error_for(element, error_msg){
    if(error_msg == undefined){
      error_msg = $(element).data('error-message');
    }
    if(!$(element).siblings('.form-error').length){
      $(element).after('<div class="info form-error">'+error_msg+'</div>');
      $(element).parent().removeClass('hidden');
    }
  }

  function validate_type(){   
    //return !!$('.course-class-radio:checked').val();
    return true;
  }

  function validate_basics(location){
    var valid = true;
    $(location).find('[data-error-message]').each(function(){ 
      if(!!!$(this).val()){
        show_error_for(this);
        valid = false;
      }
    });
    return valid;
  }

  function apply_inline_validation(){
    $('[data-error-message]').each(function(){
      $(this).focusout(function(){
        if(!!!$(this).val()){
          show_error_for(this);
        }else{
          $(this).siblings('.form-error').remove();
        }
      });
    });
  }

  function validate_details(){
    var valid = true;
    valid_basics = validate_basics('#details');
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
    if($('#teaching_longitude').val() == "")
    {
      valid = false;
      show_error_for($('#teaching_venue_address'));
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
    return valid;
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
  function part_change( location, keep_errors ){
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
        $('#new_teaching').submit();
      }
      $("html, body").animate({ scrollTop: 0 }, "slow");
    }else{
      navigate_to_invalid(location);
    }
  };

  /* makes the target href for the form anchors trigger form part changes */
  function link_part_change(e){
      part_change($(this).attr('href'));
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
});