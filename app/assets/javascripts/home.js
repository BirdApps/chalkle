$(function() {
  if($('.application-home').length > 0) {
    var autocomplete, place, geocoder, location, lng, lat, spinner, tried_auto = false, fetching_now = false, bottom, top, right, left;

    init();

    function init(){
      autocomplete = new google.maps.places.Autocomplete(
      /** @type {HTMLInputElement} */(document.getElementById('location_autocomplete')) ,
       { componentRestrictions: {country: "nz"} }
      );

      google.maps.event.addListener(autocomplete, 'place_changed', function(e){
        place = autocomplete.getPlace();
        if(place.geometry != undefined){
          manual_locate(true);
        }
        check_valid_location();
      });

      lat = $('#coord_lat').val();
      lng = $('#coord_lng').val();
      
      location = $("#location_autocomplete").val();

      if( !has_location() ){
        get_location();
      } else {
        after_locate(true, false);
      }
    }

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
      $('.provider-preview-loading').show();
    }

    function spinner_location_stop(){
      $('.provider-preview-loading').hide();
    }

    function check_valid_location(){
      if(place != undefined && place.geometry != undefined){
        $('#location_unknown').hide();
      }else{
        $('#location_unknown').show();
      }
    }

    function update_bounds() {
      if(place && place.geometry != undefined && place.geometry.viewport != undefined){
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

    function has_location() {
      return ($('#coord_lat').val().length > 0) && ($('#coord_lng').val().length > 0);
    }

    function persist_location(){
      $('#coord_lng').val(lng);
      $('#coord_lat').val(lat);
      data = { latitude: lat, longitude: lng, location: location };
      $.post('/people/set_location', data);
    }

    function get_location(){
      spinner_location_start(true);
      if(!tried_auto){
        tried_auto = true;
        auto_locate();
      }else{
        manual_locate();
      }
    }

    function auto_locate() {
      if(Modernizr.geolocation){
        var options = {
          enableHighAccuracy: true,
          timeout: 2000,
          maximumAge: 0
        };
        return navigator.geolocation.getCurrentPosition(
          did_auto_location,
          manual_locate,
          options
        );
      }else{
        manual_locate();
      }
    }

    function did_auto_location(location){
      lng = location.coords.longitude;
      lat = location.coords.latitude;
      tried_auto = false; //auto worked, so retry is allowed
      after_locate(true, true);
      return has_location();
    }


    function manual_locate() {
      var place = autocomplete.getPlace();
      if(place != null && place.geometry !=null ){
        lng = place.geometry.location.lng();
        lat = place.geometry.location.lat();
        location = $("#location_autocomplete").val();
        after_locate(false, true);
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
        }else{
          after_locate(false, true);
        }
      });
    }

    function hardcode_locate(){
      lng = 174.782454;
      lat = -41.290686;
      location == "Wellington";
      $("#location_autocomplete").val("Wellington");
      after_locate(false, false);
    }

    function after_locate(do_geocode, do_persist){
      if(do_geocode) {
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
          if(do_persist){
            persist_location();
          }
          spinner_location_stop();
        });
      }else{
        if(do_persist){
          persist_location();
        }
        spinner_location_stop();
      }
      if($('#home_fetch_wrapper').length > 0 ){
        fetch();
      }   
    }

    function fetch(){
      if(!fetching_now) {
        fetching_now = true;
        spinner_location_start();
        update_bounds();

        fetch_params = {
          'top': top,
          'bottom': bottom, 
          'left': left, 
          'right': right,
        }
        $.get('providers/featured',fetch_params,write_to_page,'html').fail(function(){
          fetching_now = false;
          spinner_location_stop();
        });

      }
    }

    function write_to_page(results){
      $('#home_fetch_wrapper').empty();
      if (results.length > 0) {
        $('#home_fetch_wrapper').html(results);
        $("#home_fetch_wrapper").fadeIn();
        fetching_now = false;
        spinner_location_stop();
      } else {
        //no results
      }
    }



  }
})