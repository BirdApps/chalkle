// =require '//www.google.com/jsapi';
$(function(){
  var autocomplete, geocoder, location, lng, lat, spinner, loading_courses, course_template;
  var already_requested = false, getting_courses = false;
  var bottom, top, right, left;

  var spinner_opts = {
    lines: 9, // The number of lines to draw
    length: 5, // The length of each line
    width: 2, // The line thickness
    radius: 5, // The radius of the inner circle
    corners: 0.6, // Corner roundness (0..1)
    rotate: 30, // The rotation offset
    direction: 1, // 1: clockwise, -1: counterclockwise
    color: '#fff', // #rgb or #rrggbb or array of colors
    speed: 1.4, // Rounds per second
    trail: 77, // Afterglow percentage
    shadow: false, // Whether to render a shadow
    hwaccel: true, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 100, // The z-index (defaults to 2000000000)
    top: '50%', // Top position relative to parent
    left: '25px' // Left position relative to parent
  };

  var course_spinner_opts = {
    lines: 9, // The number of lines to draw
    length: 20, // The length of each line
    width: 4, // The line thickness
    radius: 18, // The radius of the inner circle
    corners: 1, // Corner roundness (0..1)
    rotate: 0, // The rotation offset
    direction: 1, // 1: clockwise, -1: counterclockwise
    color: $('.coloring').css('background-color'), // #rgb or #rrggbb or array of colors
    speed: 1.4, // Rounds per second
    trail: 77, // Afterglow percentage
    shadow: false, // Whether to render a shadow
    hwaccel: true, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 9, // The z-index (defaults to 2000000000)
    top: '50px', // Top position relative to parent
    left: '50%' // Left position relative to parent
  };

  function loading_courses_start(){
    $('#courses_missing').fadeOut();
    $("#courses_wrapper").fadeOut(function(){
      $('#courses_loading').show();
      loading_courses = new Spinner(course_spinner_opts).spin();
      $('#courses_loading').append(loading_courses.el);
    });
  }

  function loading_courses_stop(){
    $('#courses_loading').fadeOut(function(){
      loading_courses.stop();
      $("#courses_wrapper").fadeIn();
    });
  }

  function spinner_start(geocoding){
    if($('#toggle_map_view').is(":visible")){
      if(geocoding){
        $("#location_autocomplete").val('Finding location...');
      }
      $('#toggle_map_view').hide();
      spinner = new Spinner(spinner_opts).spin();
      $('#globe_holder').append(spinner.el);
    }
  }

  function spinner_stop(){
    if($('#toggle_map_view').is(":hidden")){
      if(spinner != undefined){
        spinner.stop();
      }
      $('#toggle_map_view').show();
    }
  }

  function search(){
    if(window.location.pathname != "/"){
      window.location.href = "/?search="+$("#search_input").val();
    }else{
      list_courses();
    }
  }

  function location_changed(){
    if(autocomplete != undefined && autocomplete.getPlace() != undefined){
      var place = autocomplete.getPlace();
      if(place.geometry != undefined){
        $('#location_unknown').hide();
      }else{
        $('#location_unknown').show();
      }
    }
  }


  function init(){
    loading_courses_start();
    if($('#course_template').length > 0){
      course_template = document.getElementById("course_template").innerHTML;
    }

    $('[data-toggle="tooltip"]').tooltip()

    autocomplete = new google.maps.places.Autocomplete(
          /** @type {HTMLInputElement} */(document.getElementById('location_autocomplete')) ,
           { componentRestrictions: {country: "nz"} }
          );

    google.maps.event.addListener(autocomplete, 'place_changed', function(e){
      if(autocomplete.getPlace().geometry != undefined){
        manual_locate();
      }
      location_changed();
    });

    $('#search_btn').click(search);
    $("#search_input").keypress(function(e){
      if(e.which == 13 ){
        search();
      }
    });

    lat = $('#coord_lat').val();
    lng = $('#coord_lng').val();
    location = $("#location_autocomplete").val();
    $('#toggle_map_view').click(auto_locate);
    $('.refresh_location').click(get_location);
    
    if( !has_location() ){
      get_location();
    } else {
      after_location(location == "", false);
    }

     if( $('#courses_wrapper').length > 0 ){
      loading_courses_start();
    }
  }

  function after_location(geocode, persist){
    if(geocode) {
      if(geocoder == null){
        geocoder = new google.maps.Geocoder();
      }

      var latlng = new google.maps.LatLng(lat, lng);
      geocoder.geocode({'latLng': latlng}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          if (results[1]) {
            location = results[1].formatted_address;
            $("#location_autocomplete").val(location);
          }
        }
        if(persist){
          persist_location();
        }
        spinner_stop();
      });
    }else{
      if(persist){
        persist_location();
      }
      spinner_stop();
    }
    location_changed();
    if(window.location.pathname == "/"){
      search();
    }
  }
  

  function has_location() {
    return ($('#coord_lat').val().length > 0) && ($('#coord_lng').val().length > 0);
  }

  function get_location(){
    spinner_start(true);
    if(already_requested){
      manual_locate();
    }else{
      already_requested = true;
      auto_locate();
    }
  }

  function hardcode_locate(){
    lng = 174.782454;
    lat = -41.290686;
    location == "Wellington";
    $("#location_autocomplete").val("Wellington");
    after_location(false, false);
  }

  function auto_locate() {
    if(Modernizr.geolocation){
      return navigator.geolocation.getCurrentPosition(
        function(location){
          lng = location.coords.longitude;
          lat = location.coords.latitude;
          after_location(true, true);
          return has_location();
        },
        manual_locate
      );
    }
  }

  function manual_locate() {
    var place = autocomplete.getPlace();
    if(place != null && place.geometry !=null ){
      lng = place.geometry.location.lng();
      lat = place.geometry.location.lat();
      location = $("#location_autocomplete").val();
      after_location(false, true);
    }else{
      fallback_locate();
    }
  }

  function fallback_locate(){
    $.get('/people/get_location', function(data){
      if( data.lng != 0 && data.lat != 0){
        lng = data.lng;
        lat = data.lat;
        location = data.location;
      }
    }).done(function(){
      if(!has_location()){
        hardcode_locate();
      }
    });
  }

  function persist_location(){
    $('#coord_lng').val(lng);
    $('#coord_lat').val(lat);
    data = { latitude: lat, longitude: lng, location: location };
    $.post('/people/set_location', data);
  }

   function update_bounds() {
    var place;
    if(autocomplete != undefined){
      place = autocomplete.getPlace();
    }
    if(place != undefined && place != null && place.geometry != undefined && place.geometry.viewport != undefined){
      var ne = place.geometry.viewport.getNorthEast();
      var sw = place.geometry.viewport.getSouthWest();
      if(ne.lat() == sw.lat()){
        //approximate bounds if only have center
        bottom = sw.lat() - 0.5;
        top = ne.lat() + 0.5;
        right = ne.lng() + 0.5;
        left = sw.lng() - 0.5;
      }else{
        bottom = sw.lat();
        top = ne.lat();
        right = ne.lng();
        left = sw.lng();
      }
    }else{
      top = parseFloat(lat) + 1.5;
      right = parseFloat(lng) + 1.5;
      bottom = parseFloat(lat) - 1.5;
      left = parseFloat(lng) - 1.5;
    }
  }

  function list_courses(){
    if(!getting_courses) {
      spinner_start();
      getting_courses = true;
      update_bounds();
      $.post(
        '/classes/fetch.json',
        { 'top': top, 'bottom': bottom, 'left': left, 'right': right, 'search': $("#search_input").val() },
        update_list, 
        "json").always(function(){
          getting_courses = false;
          spinner_stop();
          loading_courses_stop();
        });
    } else {
      loading_courses_stop();
      spinner_stop();
    }
  }

  function update_list(classes){
    $('#courses_wrapper').empty();
    if( $('#courses_wrapper').length > 0 ){
      if(classes.length > 0){
        $('#courses_missing').hide();
        for(var i = 0; i < classes.length; i++){
          clas = classes[i];
          $('#courses_wrapper').append(course_template);
          var ele = $('#courses_wrapper').children().last();
          $(ele).find('.set_url').attr('href', clas.url);
          $(ele).find('.set_title').attr('title', clas.name);
          $(ele).find('.set_name').text(clas.name);
          $(ele).find('.set_bgcolor').css('background-color', clas.color);
          $(ele).find('.set_color').css('color',clas.color);
          $(ele).find('.set_action_call').text(clas.action_call);
          $(ele).find('.set_provider').text(clas.provider);
          $(ele).find('.set_provider_url').attr('href', clas.provider_url);
          $(ele).find('.set_booking').text(clas.booking);
          $(ele).find('.set_booking_url').attr('href', clas.booking_url);
          $(ele).find('.set_teacher').text(clas.teacher);
          $(ele).find('.set_teacher_url').attr('href', clas.teacher_url);
          $(ele).find('.set_cost').text(clas.cost);
          $(ele).find('.set_address').text(clas.address);
          $(ele).find('.set_time').text(clas.time);
          if(clas.status != 'Published'){
            $(ele).find('.set_status').show();
            $(ele).find('.set_status h4').text(clas.status);
            $(ele).find('.set_status_color').addClass(clas.status_color)
          }
          if(clas.image != null){
            $(ele).find('.set_image').css('background', 'url('+clas.image+')');
          }
          if(clas.provider_image != null){
            $(ele).find('.set_provider_image').attr('src', clas.provider_image );
          }
        }
      }
      $("#courses_loading").fadeOut(function(){
        $("#courses_wrapper").fadeIn();
        if(classes.length == 0){
          $('#courses_missing').fadeIn();
        }
      });
    }
  }

  init();

});