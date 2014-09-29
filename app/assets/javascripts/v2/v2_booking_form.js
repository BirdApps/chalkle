$(function(){
  if($("#new_booking").length > 0){
    if($("#map-canvas").length > 0){
      function setMap() {
        var lat = $('#latitude').val();
        var lng = $('#longitude').val();
        var latlng = new google.maps.LatLng(lat, lng);
        if(lat != "" && lng != ""){
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
            mapTypeControlOptions: {
              mapTypeIds: [google.maps.MapTypeId.ROADMAP, 'map_style']
            }
          };
          var map = new google.maps.Map(document.getElementById("map-canvas"),
              mapOptions);
          map.mapTypes.set('map_style', styledMap);
          map.setMapTypeId('map_style');
          var marker = new google.maps.Marker({
            position: latlng,
            map: map,
            title: 'Class location'
        });
        }
      }
      setMap();
    }

    // $("#booking_guests").change(function(){
    //   var friend_invite = $($('.booking_bookings')[0]).clone();
    //   $('#friend_pen').html('<br />');
    //   for(var i = 0; i < $(this).val(); i++){
    //     $('#friend_pen br').before(friend_invite);
    //   }
    // })

  }
});