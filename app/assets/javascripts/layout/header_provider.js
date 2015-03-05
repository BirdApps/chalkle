$(function(){
  if( $('.provider_header').length > 0 ){

    $('.favourite').click(function(e){
      e.preventDefault();
      $(this).parent().find('form').submit();
    });

    ensure_heading_fits();
    window.addEventListener("resize", ensure_heading_fits);
    window.setInterval(ensure_heading_fits, 1000);
    function does_heading_fit(){
      // width = 50 < $('.provider_name').offset().left - $('.provider_header .avatar').offset().left
      // height = 45 > $('.provider_name').height();
      // return width && height;
      return $('.provider_name').offset().top + $('.provider_name').height() < $('.provider_header .avatar').offset().top + $('.provider_header .avatar').height();
    }

    function ensure_heading_fits() {
       var font_size = parseInt( $('.provider_name').css('font-size') )
      
       while ( does_heading_fit() ) {
         $('.provider_name').css('font-size', (font_size++)+"px");
       }
        while (  !does_heading_fit() ) {
         $('.provider_name').css('font-size', (--font_size)+"px");
       }
    }

  }
});