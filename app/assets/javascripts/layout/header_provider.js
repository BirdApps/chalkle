$(function(){
  if( $('.provider_header').length > 0 ){

    ensure_heading_fits();
    window.addEventListener("resize", ensure_heading_fits);
      
    function does_heading_fit(){
      return 50 < $('.provider_name').offset().left - $('.provider_header .avatar').offset().left
    }

    function ensure_heading_fits() {
       var font_size = parseInt( $('.provider_name').css('font-size') )
       while (  !does_heading_fit() ) {
         $('.provider_name').css('font-size', --font_size+"px");
       }
    }

  }
});