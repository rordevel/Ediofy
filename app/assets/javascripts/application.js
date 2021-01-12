// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require nested_form_fields
//= require isotope
//= require rellax.min.js
//= require wow.min.js
//= require main.js
//= require jquery.fancybox
//= require jquery-hotkeys
//= require jquery-cookie
//= require jquery.tokenInput
//= require fileuploader.js
//= require jquery.flot.min
//= require jquery.flot.pie.min
//= require jquery-progressbar.min
//= require_tree ./ediofy
//= require wysihtml5/simple
//= require wysihtml5/wysihtml5-0.3.0
//= require custom/on-off-switch.js
//= require custom/on-off-switch-onload.js
//= require scripts
//= require media
// require pnotify
// require unobtrusive_flash
//= require jquery.slick
//= require custom/custom_master
//= require jquery.infinite-pages
//= require s3_direct_upload
//= require bootstrap-typeahead.js
//= require jquery.floatinglabel
//= require images
//= require froala_editor.min.js
//= require plugins/paragraph_format.min.js
//= require plugins/paragraph_style.min.js
//= require plugins/lists.min.js
//= require plugins/quote.min.js
//= require jquery.atwho
//= require bootbox
//= require autocomplete.js
//= require main
//= require cable
//= require select2-full
//= require html5sortable
//= require_tree ./channels
//= require bootstrap-datepicker
//= require flatpickr
//= require_self



document.addEventListener('DOMContentLoaded', function() {
  flatpickr('.flatdateselector', {
    altInput: true,
    altFormat: "M j, Y",
    dateFormat: "d-m-Y",
    minDate: "01-01-2019",
    maxDate: "01-01-2025"
  });
})



$(document).ready(function() {
  $("#b_ediofy_dashboard_index_people_sort").on("change", function() {
    var sort_by = $(
      "#b_ediofy_dashboard_index_people_sort option:selected"
    ).val();
    var q = $("#search-query").val();
    $("#b_ediofy_dashboard_index_people_load").attr("href");
    var url =
      location.protocol +
      "//" +
      location.host +
      "/?b_ediofy_dashboard_index_people_sort=" +
      sort_by +
      "&q=" +
      q +
      "&result_item=user&page=1";
    var load_url =
      location.protocol +
      "//" +
      location.host +
      "/?b_ediofy_dashboard_index_people_sort=" +
      sort_by +
      "&q=" +
      q +
      "&result_item=user&page=2";
    $("#b_ediofy_dashboard_index_people_load").attr("href", load_url);
    $.ajax({
      url: url,
      method: "GET",
      dataType: "script"
    });
  });

  $(
    ".b-ediofy-dashboard-index #content_type, .b-ediofy-dashboard-index #sort_by"
  ).on("change", function() {
    var sort_by = $(".b-ediofy-dashboard-index #sort_by option:selected").val();
    var content_type = $(
      ".b-ediofy-dashboard-index #content_type option:selected"
    ).val();
    var url =
      location.protocol +
      "//" +
      location.host +
      "/?content_type=" +
      content_type +
      "&sort_by=" +
      sort_by +
      "&only_content=true&page=1";

    if ($("#search-query").length) {
      searchQuery = encodeURIComponent($("#search-query").val());
      url += "&[q]=" + searchQuery;
    }

    $.ajax({
      url: url,
      method: "GET",
      dataType: "script"
    });
  });


  $(".b-ediofy-users-show #content_type, .b-ediofy-users-show #sort_by").on(
    "change",
    function() {
      var sort_by = $(".b-ediofy-users-show #sort_by option:selected").val();
      var content_type = $(
        ".b-ediofy-users-show #content_type option:selected"
      ).val();

      length_is_one = $(".b-ediofy-users-show .contributions").length == 1;
      var url = "";
      if (length_is_one) {
        url =
          location.protocol +
          "//" +
          location.host +
          location.pathname +
          "/?content_type=" +
          content_type +
          "&sort_by=" +
          sort_by;
      }

      length_is_one = $(".b-ediofy-users-show .history").length == 1;
      if (length_is_one) {
        url =
          location.protocol +
          "//" +
          location.host +
          location.pathname +
          "/?type=history&content_type=" +
          content_type +
          "&sort_by=" +
          sort_by;
      }

      $.ajax({
        url: url,
        method: "GET",
        dataType: "script"
      });
    }
  );

  var ignoreIds = [
    "privacy",
    "token-input-ignored",
    "ghost_mode_ignore",
    "media_description",
    "conversation_description",
    "question_body",
    "question_explanation"
  ];
  if ($(".answer-body").length) {
    $(".answer-body").each(function() {
      ignoreIds.push($(this).attr("id"));
    });
  }
  if ($(".ignore-comment-box").length) {
    $(".ignore-comment-box").each(function() {
      ignoreIds.push($(this).attr("id"));
    });
  }

  $(".pageContent form").floatinglabel({
    // animationIn     : {top: '-5px', opacity: '1'},
    // animationOut    : {top: '0', opacity: '0'},
    // delayIn         : 300,
    // delayOut        : 300,
    // easingIn        : false,
    // easingOut       : false,
    ignoreId: ignoreIds
  });

  $(".pageContent form input").each(function() {
    if ($(this).val() == "") {
      if (
        $(this)
          .parents("li")
          .find("label.floating-label").length
      ) {
        $(this)
          .parents("li")
          .find("label.floating-label")
          .css("opacity", "0");
      } else {
        $(this)
          .parents(".form-group")
          .find("label.floating-label")
          .css("opacity", "0");
      }
    } else {
      $(this)
        .parents("li")
        .find("label.floating-label")
        .css("opacity", "1");
    }
  });

  if ($(".floating-label").length) {
    $(".floating-label")
      .parents("li")
      .css("text-align", "left");
    $(".floating-label").each(function() {
      if ($(".floating-label").text() == "") {
        $(this).css("display", "none");
      }
    });
  }

  $(".tagDisplay").css("opacity", 0);
  if ($(".token-input-list-facebook .token-input-token-facebook").length > 0) {
    $(".tagDisplay").css("opacity", 1);
  }

  

  $(".token-input-list-facebook .token-input-input-token-facebook input")
    .on("focus", function() {
      $(".tagDisplay").css("opacity", 1);
    })
    .on("blur", function() {
      if (
        $(".token-input-list-facebook .token-input-token-facebook").length > 0
      ) {
        $(".tagDisplay").css("opacity", 1);
      } else {
        $(".tagDisplay").css("opacity", 0);
      }
    });
  $(".mainHeader .myAccount > a").on("click", function(e) {
    if ($(".mobileNavOuter").css("display") == "inline-block") {
      $(".mobileNavOuter .mobileNav.change").click();
    }
    if ($(".myAccount .myaccountInner").css("visibility") == "hidden") {
      $(".myAccount .myaccountInner").css("visibility", "visible");
    } else {
      $(".myAccount .myaccountInner").css("visibility", "hidden");
    }
  });
  $(".mobileNav").on("click", function() {
    if ($(".myAccount .myaccountInner").css("visibility") == "visible") {
      $(".myAccount .myaccountInner").css("visibility", "hidden");
    }
  });
});

$(document).ajaxSend(function(options, xhr, settings) {
  //dont mess with ajax query if its from autocmplete control
  if (settings.url.indexOf("/autocomplete/persons_and_companies.json") > -1) {
    return false;
  }
  var url = $(".b-ediofy-load-more").attr("href");
  var page = (RegExp("page=" + "(.+?)(&|$)").exec(url) || [, null])[1];
  var old_content_type = (RegExp("content_type=" + "(.+?)(&|$)").exec(url) || [
    ,
    null
  ])[1];
  var old_sort_by = (RegExp("sort_by=" + "(.+?)(&|$)").exec(url) || [
    ,
    null
  ])[1];
  var query = (RegExp("q=" + "(.+?)(&|$)").exec(url) || [, null])[1];
  var content_type = $("#content_type option:selected").val();
  var sort_by = $("#sort_by option:selected").val();
  var length_is_one =
    $(".b-ediofy-conversations-index .content_type_select").length == 1;
  if (length_is_one) {
    settings.url =
      location.protocol +
      "//" +
      location.host +
      "/?content_type=" +
      content_type +
      "&sort_by=" +
      sort_by +
      "&only_content=true";
  }

  length_is_one =
    $(".b-ediofy-histories-index .content_type_select").length == 1;
  if (length_is_one) {
    settings.url =
      location.protocol +
      "//" +
      location.host +
      "/histories/?content_type=" +
      content_type +
      "&sort_by=" +
      sort_by;
  }
  if (
    length_is_one &&
    (old_content_type == null || old_content_type == content_type) &&
    (old_sort_by == null || old_sort_by == sort_by)
  ) {
    settings.url += "&page=" + page + "";
  }

  if (length_is_one && query != null) {
    settings.url += "&q=" + query + "";
  }
});

window.request_follow_unfolow = function(that) {
  if (that.checked == false) {
    confirm_unfollow_user(that);
  } else if (that.getAttribute("data-pending") == "true") {
    that.checked = false;
    confirm_cancel_request(that);
  } else {
    url =
      location.protocol +
      "//" +
      location.host +
      "/follows/" +
      that.getAttribute("data-id") +
      "/request";
    that.checked = false;
    confirm_follow_user(that);
  }
};

function confirm_follow_user(elm) {
  return bootbox.confirm({
    title: "Follow",
    message: "Are you sure you want to send the user a follow request?",
    buttons: {
      cancel: {
        label: "No"
      },
      confirm: {
        label: "Yes"
      }
    },
    callback: function(result) {
      if (result) {
        $.ajax({
          url: url,
          method: "POST",
          dataType: "script",
          data: { user_id: elm.getAttribute("data-id") },
          success: function(result) {
            elm.checked = false;
            elm.setAttribute("data-pending", "true");
            $('input[name="commit"]').prop('value','Next')
          }
        });
      } else {
        elm.checked = false;
      }
    }
  });
}
function confirm_unfollow_user(elm) {
  return bootbox.confirm({
    title: "Unfollow",
    message: "Are you sure you no longer want to follow this user?",
    buttons: {
      cancel: {
        label: "Cancel"
      },
      confirm: {
        label: "Yes"
      }
    },
    callback: function(result) {
      if (result) {
        $.ajax({
          url:
            location.protocol +
            "//" +
            location.host +
            "/follows/" +
            elm.getAttribute("data-id"),
          type: "DELETE",
          success: function(result) {}
        });
      } else {
        elm.checked = true;
      }
    }
  });
}

function confirm_cancel_request(elm) {
  return bootbox.confirm({
    title: "Cancel Follow Request",
    message: "Are you sure you want to cancel your follow request?",
    buttons: {
      cancel: {
        label: "No"
      },
      confirm: {
        label: "Yes"
      }
    },
    callback: function(result) {
      if (result) {
        $.ajax({
          url:
            location.protocol +
            "//" +
            location.host +
            "/cancel_follow/" +
            elm.getAttribute("data-id"),
          type: "GET",
          success: function(result) {
            elm.checked = false;
            elm.setAttribute("data-pending", "false");
            pending_items = $('input[name="followable_id"][data-pending=true]')
            if (pending_items.length > 0)
              $('input[name="commit"]').prop('value','Next')
            else
              $('input[name="commit"]').prop('value','Later')
          }
        });
      } else {
      }
    }
  });
}
var froala_editor_key = "aG3C2B10A6bA4B3E3C1I3H2B6C6C3D1uooebhvC1rD-11B-9==";

$(document).ready(function() {
  sortable("#contents", {
    items: "tr",
    forcePlaceholderSize: true,
    placeholderClass: 'row plrow spaceUnder border-blue',
    hoverClass: 'hover-blue',
    // handle: '.js-handle'
  });
  if (typeof sortable("#contents")[0] != "undefined") {
    sortable("#contents")[0].addEventListener("sortupdate", function(e) {
      var dataIDList = $(this)
        .children()
        .map(function(index) {
          $(this)
            .find(".position")
            .text(index + 1);
          return "content[]=" + $(this).find(".position").prevObject[0].id;
        })
        .get()
        .join("&");
      $.ajax({
        url: $(this).data("url"),
        type: "PATCH",
        data: dataIDList
      });
    });

    sortable('#contents', 'disable');
  }
});
