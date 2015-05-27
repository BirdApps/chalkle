$(function(){

  $('.img.img-modal').click(function(){
    var bg = $(this).css('background-image');
    bg = bg.replace('url(','').replace(')','');
    $("#img_modal .modal-content").html('<img class="col-xs-12" src="'+bg+'" />');
    $("#img_modal").modal('show');
  });

});