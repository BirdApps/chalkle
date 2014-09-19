$(function(){
  $('.styled_upload').change(function(){
    //set name
    var filename = $('input[type=file]').val().split('\\').pop();
    $(this).parent().prev().text(filename);

    //set preview
    var preview_class = $(this).data('preview');
    if(!preview_class){
      preview_class = 'image-preview .img';
    }
    if (this.files && this.files[0]) {
      var reader = new FileReader();
      var previewer = $('.'+preview_class);
      reader.onload = function (e) {
          $(previewer).css('background-image', 'url('+e.target.result+')');
      }
      reader.readAsDataURL(this.files[0]);
    }
  });
});