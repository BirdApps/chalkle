$(function(){
  if($(".course-show").length > 0){
    if($("#map-canvas").length > 0){
      function setMap() {
        var lat = $('#latitude').val();
        var lng = $('#longitude').val();
        var latlng = new google.maps.LatLng(lat, lng);
        var offcenter = new google.maps.LatLng(lat, lng-0.01);
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
            center: offcenter,
            zoom: 15,
            zoomControlOptions: {
              position: google.maps.ControlPosition.TOP_RIGHT
            },
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
  }
});