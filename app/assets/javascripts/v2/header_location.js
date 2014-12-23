// =require '//www.google.com/jsapi';
$(function(){

  var map, map_overlay, autocomplete, geocoder, location, lng, lat, spinner, spin_target, bounds,bounds_interval;
  var already_requested = false;
  var reporting = false;

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


  function report(a_report){
    if(reporting){
      console.log(a_report);
    }
  }


 

  function spinner_start(geocoding){
    if($('#toggle_map_view').is(":visible")){
      if(geocoding){
        $("#location_autocomplete").val('Finding classes near...');
      }
      $('#toggle_map_view').hide();
      spinner = new Spinner(spinner_opts).spin();
      $('#globe_holder').append(spinner.el);
    }
  }

  function spinner_stop(){
    if($('#toggle_map_view').is(":hidden")){
      spinner.stop();
      $('#toggle_map_view').show();
    }
  }

  function init(){

    $("#globe_holder").tooltip({
      placement: 'bottom'
    });


    map_overlay = $('#map_overlay');

    autocomplete = new google.maps.places.Autocomplete(
          /** @type {HTMLInputElement} */(document.getElementById('location_autocomplete')),
          {  componentRestrictions: {country: "nz"} });

    google.maps.event.addListener(autocomplete, 'place_changed', function() {
      manual_locate();
      init_map_overlay();
    });

    lat = $('#coord_lat').val();
    lng = $('#coord_lng').val();
    location = $("#location_autocomplete").val();
    $('#toggle_map_view').click(toggle_map_view);
    $('.refresh_location').click(get_location);
    
    if( !has_location() ){
      get_location();
    } else {
      after_location(location == "", false);
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
    report("hardcoded"); 
  }

  function auto_locate() {
    if(Modernizr.geolocation){
      return navigator.geolocation.getCurrentPosition(
        function(location){
          lng = location.coords.longitude;
          lat = location.coords.latitude;
          after_location(true, true);
          report("Auto");
          return has_location();
        },
        manual_locate
      );
    }
  }

  function manual_locate() {
    var place = autocomplete.getPlace();
    if(place != null && place.geometry !=null ){
      lng = place.geometry.location['D'];
      lat = place.geometry.location['k'];
      location = $("#location_autocomplete").val();
      after_location(false, true);
      report("manual");
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
      if(has_location()){
        report("fallback");
      }else{
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

  function toggle_map_view(){
    if($(map_overlay).is(':visible')){
      $('#map_overlay').fadeOut();
    }else{
      $('#map_overlay').fadeIn();
      init_map_overlay();
    }
  }

  function init_map_overlay(){
    if(!has_location()){
      get_location();
    }

    var latlng = new google.maps.LatLng(lat, lng);
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
      streetViewControl: false,
      mapTypeControl: false,
      panControl: true,
      panControlOptions: {
          position: google.maps.ControlPosition.BOTTOM_LEFT
      },
      zoomControl: true,
      zoomControlOptions: {
        position: google.maps.ControlPosition.BOTTOM_LEFT
      }
    };
    map = new google.maps.Map(document.getElementById("map_holder"), mapOptions);
    map.mapTypes.set('map_style', styledMap);
    map.setMapTypeId('map_style');

    google.maps.event.addListener(map, 'bounds_changed', function() {
      bounds = map.getBounds();
      update_bounds();
    });

  }

  function update_bounds() {
    clearInterval(bounds_interval);
    spinner_start();
    bounds_interval = setInterval(map_courses, 300);
  }

  function list_courses(){
    $("#wrapper > .container").html();
  }

  function map_courses() {
      clearInterval(bounds_interval);
      if(bounds != null){
        var bottom = bounds.Ea.k;
        var top = bounds.Ea.j;
        var right = bounds.wa.k;
        var left = bounds.wa.j;
        $.post(
          '/classes/locations.json',
          { 'top': top, 'bottom': bottom, 'left': left, 'right': right },
          function(data){
            //append each to map
             for(var i = 0; i < data.length; i++){
              datum = data[i];
              var latlng = new google.maps.LatLng(datum.lat, datum.lng);
              var marker = new google.maps.Marker({
                  position: latlng,
                  map: map,
                  title: datum.id.toString()
                });
            }
          }, 
          "json").done(function(){
            spinner_stop();
          });
      }else{
        spinner_stop();
      }
  }

  init();

});