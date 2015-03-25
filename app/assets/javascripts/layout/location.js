// TODO: make location library for fetch to use

// // =require '//www.google.com/jsapi';

// var UserLocation;

// $(function(){
//   if(document.getElementById('location_autocomplete')){
    
//     UserLocation = user_location();
//     var single_user_location;

//     function user_location(){
//       if( single_user_location == undefined) {
        
//         single_user_location = {
//           _methods: {
//             geocoder: new google.maps.Geocoder(),
//             autocomplete: new google.maps.places.Autocomplete(
//             /** @type {HTMLInputElement} */(document.getElementById('location_autocomplete')) ,
//              { componentRestrictions: {country: "nz"} }
//             ),
//             place: function(){
//               UserLocation._methods.autocomplete.getPlace();
//             }
//           },
//           lng: function(){
//             UserLocation._methods.place().geometry.location.lng();
//           },
//           lat: function(){
//             UserLocation._methods.place().geometry.location.lat();
//           },
//           bounds: {
//             top: -41.290686,
//             bottom: -41.290686,
//             left: 174.782454,
//             right: 174.782454
//           },
//           location: 'Wellington'
          
//         }

//       }
//       return single_user_location;
//     }

//   }
// });
