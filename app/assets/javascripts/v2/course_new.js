/* input helpers */
$(function(){
  var temp_val = "";
  function whole_positive_int(int){
    return /^[1-9]\d*$/.test(int);
  }
  function change_num(element, positive){
    temp_val = $(element).val();
    if(temp_val == ""){
      temp_val = 1;
    }
    temp_val = parseInt(temp_val);
    if(positive){
      temp_val++;
    }else{
      temp_val--; 
    }
    test_val = temp_val;
    if($(element).data("zero")){
      test_val++;
    }
    if(whole_positive_int(test_val)){
      $(element).val(temp_val);
    }
  }
  $('.number-picker input').focus(function(){
    temp_val =$(this).val();
  });
  $('.number-picker input').change(function(){
    temp_val = $(this).val();
    test_val = temp_val;
    if($(this).data('zero')){
      test_val++;
    }
    if(!whole_positive_int(test_val)){
      $(this).val(temp_val);
    }

  });
  $('.number-picker .num-up').click(function(){
    change_num($(this).parent().siblings('input'), true);
  });
  $('.number-picker .num-down').click(function(){
    change_num($(this).parent().siblings('input'), false);
  });
});

/* Navigation through form parts*/
$(function(){
  $(".new_course_form_wrapper .parts").hide();
  function part_change( location ){
    location = (typeof location == 'undefined') ? window.location.hash : location;
    $(".new_course_form_wrapper .parts").fadeOut();
    $(location).delay(350).fadeIn();
    $(".new_course_form_wrapper .breadcrumb li").removeClass('active')
    $(location+'-link').parent().addClass('active');
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
      $('.course_only').hide();
      $('.class_only').show();
    }else{
      $('.class_only').hide();
      $('.course_only').show();
    }
  });
});


/* Start at logic */
$(function() {
  var instance_time = "";
  var instance_date = "";
  var monthly  = "";
  var repeating  = "";
  var repeat_times  = "";
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
      minutes = minutes % 60;
      hours = hours + Math.floor(minutes/60);
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
      repeat_times = parseInt($("#teaching_repeat_times").val());
      repeating = repeating && repeat_times > 1
      if(repeating && monthly) {
        //monthly
        var wday = instance_date.getDay();
        var date_lapse = new Date();
        date_lapse.setYear(instance_date.getFullYear());
        date_lapse.setMonth(instance_date.getMonth() + parseInt(repeat_times) - 1);
        date_lapse.setDate(1);
        var target_nth = nth_day_instance_date();
        var end_date = nth_day_of(target_nth, wday, date_lapse);
        string_build += " on the "+ordinal(target_nth)+" "+weekdays[wday]+" of every month from "+instance_date.toDateString()+" until "+end_date.toDateString();
      }else if(repeating && !monthly){
        //weekly
        var end_date = new Date();
        end_date.setMonth(instance_date.getMonth());
        end_date.setDate(instance_date.getDate()+7*(repeat_times-1));
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
      $('#class-repeat-times').html(string_build);
      $('#class-repeat-times').show();
    } else {
      $('#class-repeat-times').hide();
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
    $('#teaching_repeat_frequency').change(calculate_class_times);
    $('#teaching_repeating').change(calculate_class_times);
    $('#teaching_repeat_times').change(calculate_class_times);
    $('#teaching_duration_minutes').change(calculate_class_times);
    $('#teaching_duration_hours').change(calculate_class_times);
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
    repeat_times = parseInt($("#teaching_repeat_times").val());
    if( isNaN(repeat_times) ) { $("#teaching_repeat_times").val(1)}; 
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