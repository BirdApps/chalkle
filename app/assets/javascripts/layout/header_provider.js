$(function(){
  if( $('.provider_header').length > 0 ){

    function init() {
      $('.follow').click(function(e){
        e.preventDefault();
        $(this).parent().find('form').submit();
      });

      ensure_heading_fits();
      window.addEventListener("resize", ensure_heading_fits);
      window.setInterval(ensure_heading_fits, 1000);
    }

    function does_heading_fit() {
      return $('.provider_header_name').offset().top + $('.provider_header_name').height() < $('.provider_header_links').offset().top;
    }

    function ensure_heading_fits() {
       var font_size = parseInt( $('.provider_header_name').css('font-size') );
       while ( does_heading_fit() ) {
         $('.provider_header_name').css('font-size', (font_size++)+"px");
       }
        while (  !does_heading_fit() ) {
         $('.provider_header_name').css('font-size', (--font_size)+"px");
       }
    }

    init();
  }
});