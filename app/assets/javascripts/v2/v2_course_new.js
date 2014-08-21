$(function(){

  var monthly  = "";
  var repeating  = "";
  var repeat_count  = "";
  var weekdays = ["Sunday","Monday", "Tuesday", "Wednesday", "Thursday","Friday","Saturday"];

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
    apply_start_at_controls($('body'));
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
    if(target_class_count < 1){
      $('.update_class_count input').val('1');
    }else{
      if(target_class_count > 20){
        $('.update_class_count input').val('20');
        target_class_count = 20;
        alert('Maximum 20 classes to a course at the moment. Contact Chalkle if this is an issue');
      } 
      var existing_class_count = $('.class-count').length;
      var difference = target_class_count - existing_class_count;

      /* add div.class-count that should exist */
      for(var i = 0; i < difference; i++){
        $($('.class-count')[0]).clone().insertBefore('.class-count-bumper');
        var inserted_element = $('.class-count-bumper').prev();
        $(inserted_element).find('.class-count-title').children('.class-count-title-text').html('Class <strong>'+(i+existing_class_count+1)+'</strong> Date & Time');
        number_picker(inserted_element);
        apply_start_at_controls(inserted_element);
      }

      /* remove div.class-count that shouldn't exist */
      $('.class-count').each(function(index){
        if(index+1 > target_class_count){
          $(this).remove();
        }
      });
    }
  }

  /* when course is selected over class, make the class time input into an array */
  function coursify(is_course){
    $('.class-count input').each(function(){
      var new_name = $(this).attr('name');
      if(new_name != ''){
        if(is_course){
          new_name+='[]';
        }else{
          new_name = new_name.split('[]')[0];
        }
        $(this).attr('name', new_name);
      }
    }); 
  }

  /* collects the information set throughout the form and displays it on the summary page */
  function summarize(){
    $('[id^=teaching_]').each(function(){
      var val = $(this).val() ? $(this).val() : $(this).text();
      if(val.indexOf('Your class will be held ')){
        val = val.split('Your class will be held ')[1];
      }
      var target = this.id.split('teaching_')[1];
      if(!val){
        val = '<em>{'+target+'}</em>'
      }
      var target = '#summary_'+this.id.split('teaching_')[1];
      $(target).html(val);
    });
  }

  /* shows the part of the form that matches the location anchor */
  function part_change( location ){
    location = (typeof location == 'undefined') ? window.location.hash : location;
    $(".new_course_form_wrapper .parts").fadeOut();
    $(location).delay(350).fadeIn();
    $(".new_course_form_wrapper .breadcrumb li").removeClass('active')
    $(location+'-link').parent().addClass('active');
    if(location == '#summary'){
      summarize();
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
    var key_word = $($(this).text().split(/[ ]+/)).last()[0];
    if(key_word == "class"){
      coursify(false);
      $('.course_only').hide();
      $('.class_only').show();
      show_class_opts(1);
    }else{
      coursify(true);
      $('.class_only').hide();
      $('.course_only').show();
    }
  }

  /* Retrieves list of teachers for a given channel and populates select element */
  function get_teacher_list(){
    var channel_id = $(this).val();
    $.getJSON('/v2/people/teachers.json?channel_id='+channel_id, function(data){
        $('#teaching_teacher_id').empty();
        if(data.length < 2){
          $('.teacher-select').hide();
        }else{
            $('.teacher-select').show();  
        }
        $.each(data, function(index,item) {
           $('#teaching_teacher_id').append('<option value=' + item.id + '>' + item.name + '</option>');
        });
      });
  }

  /* combines a time + hours + minutes to human readable form */
  function make_time(hours, minutes, add_hours, add_minutes) {
    hours = parseInt(hours.toString())+parseInt(add_hours.toString());
    minutes = parseInt(minutes.toString())+parseInt(add_minutes.toString());
    var meridian = "AM";
    if(hours >= 12) {
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
  function nth_day_of(target_nth, wday, date_lapse){
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
  function apply_start_at_controls(scope){
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

    /* initializes the datepicker and time picker */
    function date_time_picker_init() {
      //date picker
      var date_picker = $(scope).find('.date-picker')[0];
      $(date_picker).empty();
      $(date_picker).datepicker({
        startDate: new Date(), todayHighlight: true
      }).on('changeDate', function(e){
        instance_date = e.date;
        update_teaching_start_at();
      });
      saved_datepick = $(scope).find('#teaching_start_at').val();
      $(date_picker).datepicker('setDate', (saved_datepick=='')?new Date(+new Date + 12096e5) : saved_datepick);
      instance_date = $(scope).find('.date-picker').datepicker('getDate');

      //time picker
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

    /* if there is acceptable information to make a class, displays human readable explanation of that classe's scheduled time */
    function calculate_class_times(ignore_invalid) {
      if(instance_date && instance_time && ( duration_hours || duration_minutes )){
        var start_time = make_time(instance_date.getHours(), instance_date.getMinutes(),0,0);
        var end_time = make_time(instance_date.getHours(), instance_date.getMinutes(), duration_hours, duration_minutes);
        var string_build = "Your class will be held ";
        
        repeating = repeating && repeat_count > 1
        if(repeating && monthly) {
          //monthly
          var wday = instance_date.getDay();
          var date_lapse = new Date();
          date_lapse.setYear(instance_date.getFullYear());
          date_lapse.setMonth(instance_date.getMonth() + parseInt(repeat_count) - 1);
          date_lapse.setDate(1);
          var target_nth = nth_day_instance_date(instance_date);
          var end_date = nth_day_of(target_nth, wday, date_lapse);
          string_build += " on the "+ordinal(target_nth)+" "+weekdays[wday]+" of every month from "+instance_date.toDateString()+" until "+end_date.toDateString();
        }else if(repeating && !monthly){
          //weekly
          var end_date = new Date();
          end_date.setMonth(instance_date.getMonth());
          end_date.setDate(instance_date.getDate()+7*(repeat_count-1));
          string_build += " weekly from "+instance_date.toDateString()+" until "+end_date.toDateString();
        }else if(!repeating){
          //once-off
          string_build += " on "+instance_date.toDateString();  
        }
           
        class_length_in_hours = (instance_date.getHours()*60 + duration_hours*60+duration_minutes)/60;
        if(class_length_in_hours > 24){
          //more than a day long
          start_time = weekdays[instance_date.getDay()] + " " + start_time
          end_date = date_clone(instance_date);
          end_date.setDate(end_date.getDate() + Math.floor(class_length_in_hours/24));
          end_time = weekdays[end_date.getDay()] + " " + end_time;
        }
        string_build += " between "+start_time;
        string_build += " and "+end_time;
        $(scope).find('#teaching_times_summary').html(string_build);
        $(scope).find('#teaching_times_summary').show();
      } else {
        var error_msg = ignore_invalid ? '' : 'Invalid class time';
        $(scope).find('#teaching_times_summary').html(error_msg);
      }
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
          var start_hours = instance_time.meridian=="AM"?instance_time.hours:instance_time.hours+12;
          var start_minutess = instance_time.minutes;
          instance_date.setHours(start_hours,start_minutess,0,0);  
        }
        $(scope).find('#teaching_start_at').val(instance_date);
      }
      calculate_class_times();
    }

    start_at_controls_init();
  }

  init();
});