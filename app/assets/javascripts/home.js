$(function() {
  if($('#home').length > 0) {

    function spinner_location_start(){
      
      spinner_location_opts = {
        lines: 9, // The number of lines to draw
        length: 5, // The length of each line
        width: 2, // The line thickness
        radius: 5, // The radius of the inner circle
        corners: 0.6, // Corner roundness (0..1)
        rotate: 30, // The rotation offset
        direction: 1, // 1: clockwise, -1: counterclockwise
        color: '#333', // #rgb or #rrggbb or array of colors
        speed: 1.4, // Rounds per second
        trail: 77, // Afterglow percentage
        shadow: false, // Whether to render a shadow
        hwaccel: true, // Whether to use hardware acceleration
        className: 'spinner', // The CSS class to assign to the spinner
        zIndex: 100, // The z-index (defaults to 2000000000)
        top: '50%', // Top position relative to parent
        left: '0px' // Left position relative to parent
      };
      


        spinner = new Spinner(spinner_location_opts).spin();
        $('.location-spinner-wrapper').append(spinner.el);

    }


    spinner_location_start();

  }
})