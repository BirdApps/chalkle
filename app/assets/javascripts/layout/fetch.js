// =require '//www.google.com/jsapi';
$(function(){
  if( $('#fetch_wrapper').length > 0){
    var autocomplete, place, geocoder, location, lng, lat, spinner_location, spinner_location_opts, tried_auto = false, fetching_now = false, bottom, top, right, left;

    function spinner_fetching_spin() {
      $('#wrapper').css('opacity',0);
    }

    function spinner_fetching_stop(){
      $('#wrapper').css('opacity',1);
    }

    function spinner_location_start(finding_location){
      
      if(spinner_location_opts == undefined){
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
          left: '25px' // Left position relative to parent
        };
      }

      if($('#toggle_map_view').is(":visible")){
        if(finding_location){
          $("#location_autocomplete").val('(Finding location...)');
        }
        $('#toggle_map_view').hide();
        spinner_location = new Spinner(spinner_location_opts).spin();
        $('#globe_holder').append(spinner_location.el);
      }
    }

    function spinner_location_stop(){
      if($('#toggle_map_view').is(":hidden")){
        if(spinner_location != undefined){
          spinner_location.stop();
        }
        $('#toggle_map_view').show();
      }
      update_preview();
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
          $('.location-reference').text("near");
        }else{
          bottom = sw.lat();
          top = ne.lat();
          right = ne.lng();
          left = sw.lng();
          $('.location-reference').text("in");
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
      if($('#fetch_wrapper').length > 0 ){
        search();
      }
      update_preview();
    }

    function update_preview(){
      $('.show-location').text($("#location_autocomplete").val());
      cancel_location();
    }

    function cancel_location(){
      $('.location-form').fadeOut(function(){
        $('.location-preview').fadeIn();
      });
    }

    function search(relocate){
      if(relocate && $('#fetch_wrapper').length == 0 ){
        $("#primary-search-form").submit();
      }else{
        fetch();
      }
    }

    function fetch(page){
      if(!fetching_now) {
        if(page == undefined){
          page = getParam('page');
          if(page == undefined){
            page = 1;
          }
        }
        fetching_now = true;
        spinner_location_start();
        update_bounds();

        take = $('.paginate-take').data('take');
        if(take == undefined){        
          take = getParam('take');
          if(take == undefined){
            take = 30;
          }
        }

        fetch_params = { 
          'top': top,
          'bottom': bottom, 
          'left': left, 
          'right': right,
          'search': $("#search_input").val(),
          'take': take,
          'page': page
        }
        $.get(window.location.pathname+'/fetch',fetch_params,write_to_page,'html').fail(function(){
          fetching_now = false;
          spinner_location_stop();
          spinner_fetching_stop();
        });
        update_url(fetch_params);
      } else {
        spinner_fetching_stop();
        spinner_location_stop();
      }
    }

    function update_url(fetch_params){
      params = {};
      if(fetch_params.search != ''){
        params['search'] = fetch_params.search;
      }
      if(fetch_params.take != undefined && fetch_params.take != '30'){
        params['take'] = fetch_params.take;
      }
      if(fetch_params.page != '1'){
        params['page'] = fetch_params.page;
      }

      if(Object.keys(params).length > 0){
        url = window.location.protocol+'//'+window.location.host+window.location.pathname+"?";
        for (key in params){
          url += (key +'='+params[key]+"&")
        }
        if(url[url.length-1] == '&'){
          url = url.substring(0,url.length-1);
        }
        window.history.pushState(params, $('title').text().trim(),url);
      }
    }

    function paginate_init(){
      $('.fetch_this').click(function(){
        take = $(this).data('take');
        if(take != undefined){
          $('.paginate-take').data('take', take);
        }
        page = $(this).data('page');
        if(page != undefined){
          fetch(page);
        }else{
          fetch();
        }
      });
    }

    function write_to_page(results){
      $('#fetch_wrapper').empty();
      if(results.length > 0){
        $('#fetch_missing').hide();
        $('#fetch_wrapper').html(results);
        $("#fetch_wrapper").fadeIn();
        fetching_now = false;
        spinner_location_stop();
        spinner_fetching_stop();
        if($("#signInFirstModal").length > 0) init_sign_in_first();
        paginate_init();
      }else{
        $('#fetch_missing').fadeIn();
      }
      $('[data-toggle="tooltip"]').tooltip();
    }

    function click_change_location(){
      $('#location_autocomplete').val('');
      $('.location-preview').fadeOut('fast', function(){
        $('.location-form').fadeIn('fast');
        $('#location_autocomplete').focus();
      });
      $("#location_autocomplete").focus();
    }

    function getParam(val) {
      var result = undefined,
          tmp = [];
      window.location.search.substr(1).split("&").forEach(function (item) {
        tmp = item.split("=");
        if (tmp[0] === val) result = decodeURIComponent(tmp[1]);
      });
      return result;
    }

    function init(){

      $('.change-location').click(click_change_location);
      $('.cancel-location').click(cancel_location);
      $('.show-location').click(click_change_location);
      
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

      $('#search_btn').click(function(){search(true)});
      $("#search_input").keypress(function(e){
        if(e.which == 13 ){
          search(true);
        }
      });

      lat = $('#coord_lat').val();
      lng = $('#coord_lng').val();
      location = $("#location_autocomplete").val();

      $('#toggle_map_view').click(get_location);

      if( !has_location() ){
        get_location();
      } else {
        after_locate(true, false);
      }
      
    }

    init();

  }
});