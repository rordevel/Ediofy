// flashes.js
PNotify.prototype.options.styling = "bootstrap3";
PNotify.prototype.options.styling = "fontawesome";
$(function() {
  $(window).bind('rails:flash', function(e, params) {
    if (params.type == "notice" || params.type == "notify") {
      type = "success"
    }
    else if (params.type == "alert"){
      type = "error"
    } else{
      type = params.type
    }
    new PNotify({
      title: params.type,
      text: params.message,
      type: type
    });
  });
});