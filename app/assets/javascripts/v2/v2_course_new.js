/* Show correct number of class-divs */
$(function(){  
  function show_class_opts(){
    var target_class_count = $('.update_class_count input').val();
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
        $('.class-count-bumper').prev().children('.class-count-title').children().html('Class <strong>'+(i+existing_class_count+1)+'</strong> Date & Time');
      }

      /* remove div.class-count that shouldn't exist */
      $('.class-count').each(function(index){
        if(index+1 > target_class_count){
          $(this).remove();
        }
      });
    }
  }
  $('.update_class_count .num-up').click(show_class_opts);
  $('.update_class_count .num-down').click(show_class_opts);
  $('.update_class_count input').change(show_class_opts);
});
/* Load teachers for selected channel */
$(function(){
  $('#teaching_channel_id').change(function(){
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

  });
});
/* Navigation through form*/
$(function(){
  function coursify(course){
    $('.class-count input').each(function(){
      var new_name = $(this).attr('name');
      if(new_name != ''){
        if(course){
          new_name+='[]';
        }else{
          is_course = false;
          new_name = new_name.split('[]')[0];
        }
        $(this).attr('name', new_name);
      }
    }); 
  }

  function summarize(){
    $('[id^=teaching_]').each(function(){
      var val = $(this).val() ? $(this).val() : $(this).text();
      if(val.indexOf('Your class will be held ')){
        val = val.split('Your class will be held ')[1];
      }
      var target = this.id.split('teaching_')[1];
      //console.log('val:'+val);
      if(!val){
        val = '<em>{'+target+'}</em>'
      }
      var target = '#summary_'+this.id.split('teaching_')[1];
      $(target).html(val);
    });
  }

  $(".new_course_form_wrapper .parts").hide();
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
  $(".part_link").click(function(e){
      part_change($(this).attr('href'));
      e.preventDefault();
  });
  part_change("#type");

  $("#type .btn-group label").click(function(){
    part_change( '#details' );
    var key_word = $($(this).text().split(/[ ]+/)).last()[0];
    if(key_word == "class"){
      coursify(false);
      $('.course_only').hide();
      $('.class_only').show();
    }else{
      coursify(true);
      $('.class_only').hide();
      $('.course_only').show();
    }
  });
});


/* class time and duration controls */
$(function() {
  var instance_time = "";
  var instance_date = "";
  var monthly  = "";
  var repeating  = "";
  var repeat_count  = "";
  var duration_hours  = "";
  var duration_minutes  = "";
  var weekdays = ["Sunday","Monday", "Tuesday", "Wednesday", "Thursday","Friday","Saturday"];

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

  function nth_day_instance_date() {
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

  function calculate_class_times() {
    update_durations();
    repeat_frequency_select();
    repeating_course_select();

    if(instance_date && instance_time && ( duration_hours || duration_minutes )){
      var start_time = make_time(instance_date.getHours(), instance_date.getMinutes(),0,0);
      var end_time = make_time(instance_date.getHours(), instance_date.getMinutes(), duration_hours, duration_minutes);
      var string_build = "Your class will be held ";
      repeat_count = parseInt($("#teaching_repeat_count").val());
      repeating = repeating && repeat_count > 1
      if(repeating && monthly) {
        //monthly
        var wday = instance_date.getDay();
        var date_lapse = new Date();
        date_lapse.setYear(instance_date.getFullYear());
        date_lapse.setMonth(instance_date.getMonth() + parseInt(repeat_count) - 1);
        date_lapse.setDate(1);
        var target_nth = nth_day_instance_date();
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
        end_date = instance_date_clone();
        end_date.setDate(end_date.getDate() + Math.floor(class_length_in_hours/24));
        end_time = weekdays[end_date.getDay()] + " " + end_time;
      }
      string_build += " between "+start_time;
      string_build += " and "+end_time;
      $('#teaching_times_summary').html(string_build);
      $('#teaching_times_summary').show();
    } else {
      $('#teaching_times_summary').hide();
    }
  }

  function instance_date_clone(){
    clone = new Date();
    clone.setYear(instance_date.getFullYear());
    clone.setMonth(instance_date.getMonth());
    clone.setDate(instance_date.getDate());
    return clone;
  }

  function repeat_frequency_select() {
    monthly = $('#teaching_repeat_frequency').val() == 'monthly';
  }

  function repeating_course_select() {
    repeating = $('#teaching_repeating').val() == 'repeating';
    if(repeating) {
      $('.repeating-options').show();  
    } else {
      $('.repeating-options').hide();
    }
  }

  function update_durations(){
    duration_hours = Math.floor($('#teaching_duration_hours').val() ? parseInt($('#teaching_duration_hours').val())  : 0 );
    duration_minutes = Math.floor($('#teaching_duration_minutes').val() ? parseInt($('#teaching_duration_minutes').val())  : 0 )
    if( isNaN(duration_hours) ) { duration_hours = 0 } 
    if( isNaN(duration_minutes) ) { duration_minutes = 0 }
    if( duration_hours > 167 ) { duration_hours = 167 }
    if( duration_minutes > 59 ) { duration_minutes = 59 }
    $('#teaching_duration_minutes').val(duration_minutes);
    $('#teaching_duration_hours').val(duration_hours) 
  }

  function repeating_course_init() {
    calculate_class_times();
    $('.update_class_time').change(calculate_class_times);
    $('.number-picker .num-up').click(calculate_class_times);
    $('.number-picker .num-down').click(calculate_class_times);
  }

  function update_teaching_start_at() {
    if(instance_date!=null){
      if(instance_time != null){
        var start_hours = instance_time.meridian=="AM"?instance_time.hours:instance_time.hours+12;
        var start_minutess = instance_time.minutes;
        instance_date.setHours(start_hours,start_minutess,0,0);  
      }
      $('#teaching_start_at').val(instance_date);
    }
    calculate_class_times();
  }

  function date_time_picker_init() {
    repeat_count = parseInt($("#teaching_repeat_count").val());
    if( isNaN(repeat_count) ) { $("#teaching_repeat_count").val(1)}; 
    $('.date-picker').datepicker({
      startDate: new Date(), todayHighlight: true
    }).on('changeDate', function(e){
      instance_date = e.date;
      update_teaching_start_at();
    });
    saved_datepick = $('#teaching_start_at').val();
    $('.date-picker').datepicker('setDate', (saved_datepick=='')?new Date(+new Date + 12096e5) : saved_datepick);
    instance_date = $('.date-picker').datepicker('getDate');

    $('.time-picker').timepicker({
                minuteStep: 5,
                showInputs: false,
                disableFocus: true
    }).on('changeTime.timepicker', function(e) {
      instance_time = e.time;
      update_teaching_start_at();
    });

    saved_timepick = $('#saved_timepick').val();
    $('.time-picker').timepicker('setTime', (saved_timepick==''?'6:00 PM':saved_timepick)); 
  }

  repeating_course_init();
  date_time_picker_init();
  $('form#new_teaching').courseCostCalculator({resource_name: 'teaching'});
});