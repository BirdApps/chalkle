// =require '//www.google.com/jsapi';
$(function(){
  if( $('#provider_fetch_wrapper').length > 0){
    var fetching_courses, take, past;
    
    function spinner_courses_spin() {
      $('#wrapper').css('opacity',0);
      fetching_courses = true;
    }
    function spinner_courses_stop(){
      $('#wrapper').css('opacity',1);
      fetching_courses = false;
    }

    function fetch(page){
      if(!fetching_courses) {
        spinner_courses_spin();
        if(page == undefined){
          page = getParam('page');
          if(page == undefined){
            page = 1;
          }
        }

        if(take == undefined){     
          take = getParam('take');
          if(take == undefined){
            take = 30;
          }
        }

        if(past == undefined){
          past = getParam('past');
          if(past == undefined){
            past = false;
          }
        }
        fetch_params = {
          'past': past,
          'take': take,
          'page': page
        }
        $.get(window.location.pathname+'/fetch',fetch_params,write_courses_to_page,'html').fail(function(){
            spinner_courses_stop();
          });
        update_url(fetch_params);
      } else {
        spinner_courses_stop();
      }
    }

    function update_url(fetch_params){
      params = {};
      if(fetch_params.past == true){
        params['past'] = fetch_params.past;
      }
      if(fetch_params.take != undefined && fetch_params.take != '30'){
        params['take'] = fetch_params.take;
      }
      if(fetch_params.page != '1'){
        params['page'] = fetch_params.page;
      }

   
        url = window.location.protocol+'//'+window.location.host+window.location.pathname;
        if(Object.keys(params).length > 0) url += "?";

        for (key in params){
          url += (key +'='+params[key]+"&")
        }
        if(url[url.length-1] == '&'){
          url = url.substring(0,url.length-1);
        }
        window.history.pushState(params, $('title').text().trim(),url);
    }

    function paginate_init(){
      $('.fetch_this').click(function(){
        take = $(this).data('take');
        page = $(this).data('page');
        past = $(this).data('past');
        if(past != undefined) {
          $('.past_present_classes').text($(this).text());
        }
        if(page != undefined){
          fetch(page);
        }else{
          fetch();
        }
      });
    }

    function write_courses_to_page(classes){
      $('#provider_fetch_wrapper').empty();
      if(classes.length > 0){
        $('#courses_missing').hide();
        $('#provider_fetch_wrapper').html(classes);
        $("#provider_fetch_wrapper").fadeIn();
        fetching_courses = false;
        spinner_courses_stop();
        if($("#signInFirstModal").length > 0) init_sign_in_first();
        paginate_init();
      }else{
        $('#courses_missing').fadeIn();
      }
    }

    function click_change_location(){
      $('#location_autocomplete').val('');
      $('.location-form').fadeIn();
      $('.change-location').fadeOut();
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
      fetch(1);
    }

    init();
  }
});