// =require '//maps.googleapis.com/maps/api/js?v=3.exp';
$(function(){

  var placeSearch, autocomplete;
  var componentForm = {
    street_number: 'teaching_street_number',
    route: 'teaching_street_name',
    locality: 'teaching_city',
    administrative_area_level_1: 'teaching_region',
    country: 'teaching_country',
    postal_code: 'teaching_postal_code'
  };

  

  function initialize() {
    // Create the autocomplete object, restricting the search
    // to geographical location types.
    autocomplete = new google.maps.places.Autocomplete(
        /** @type {HTMLInputElement} */(document.getElementById('teaching_venue_address')),
        {  componentRestrictions: {country: "nz"} });
    // When the user selects an address from the dropdown,
    // populate the address fields in the form.
    google.maps.event.addListener(autocomplete, 'place_changed', function() {
      fillInAddress();
    });
  }

  function fillInAddress() {
    // Get the place details from the autocomplete object.
    var place = autocomplete.getPlace();
    for (var component in componentForm) {
      document.getElementById(componentForm[component]).value = '';
      document.getElementById(componentForm[component]).disabled = false;
    }

    // Get each component of the address from the place details
    // and fill the corresponding field on the form.
    for (var i = 0; i < place.address_components.length; i++) {
      var addressType = place.address_components[i].types[0];      
      if (componentForm[addressType]) {
        var val = place.address_components[i]['long_name'];
        document.getElementById(componentForm[addressType]).value = val;
      }
    }

    //set the longitude and latitude
    document.getElementById('teaching_longitude').value = place.geometry.location['B'];
    document.getElementById('teaching_latitude').value = place.geometry.location['k'];
  }

  // Bias the autocomplete object to the user's geographical location,
  // as supplied by the browser's 'navigator.geolocation' object.
  function geolocate() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var geolocation = new google.maps.LatLng(
            position.coords.latitude, position.coords.longitude);
        autocomplete.setBounds(new google.maps.LatLngBounds(geolocation,
            geolocation));
      });
    }
  }
  initialize();
});