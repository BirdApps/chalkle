$(function() {
  
  function repeating_course_select() {
    var once_off = $('#repeating-course-select').val() == 'once-off';
    if(once_off) {
      $('.once-off-option').show();
      $('.repeating-options').hide();
    } else {
      $('.once-off-option').hide();
      $('.repeating-options').show();  
    }
  }

  repeating_course_select();
  $('#repeating-course-select').change(repeating_course_select);

  $('.date-picker').datepicker({startDate: new Date(), todayHighlight: true}).on('changeDate', function(e){
      alert(e.date)
    });
  
});