$(document).ready(function(e) {
  var user_img_src = $('#user-detail').find('img').attr('src');
  var default_img_src = $('#default-url').val();
  var author_name = $('#user-detail').find('.authinfoWrapName').html();
	function stickyNav() {
		var stickyNavTop = $('.mainHeader').offset().top;
		var scrollTop = $(window).scrollTop();
		if (scrollTop > 0) {
			$('.mainHeader').addClass('whiteBg');
		} else {
			$('.mainHeader').removeClass('whiteBg');
		}
	};

	$(window).scroll(function() {
		stickyNav();
	});
	stickyNav();

  $('.remove-picture-button').click(function(e) {
    var self = $(this);

    $('#image_upload_button').val('');
    var profilePicture = $('.profile-pic');
    profilePicture.attr('src', profilePicture.data('placeholder'));
    var hiddenInput = $('<input type="hidden" name="user[remove_avatar]" value="1" />');
    self.parents('form').append(hiddenInput);
    self.hide();

    e.stopImmediatePropagation();
  });

  $('#image_upload').click(function(e) {
    $('#image_upload_button').click();
  });

  $('#image_upload_button').change(function(e) {
    readImage(this);
    $('input[name="user[remove_avatar]"]').remove();
    $('.remove-picture-button').show();
  });

  var readImage = function(input) {
    if (input.files && input.files[0]) {
      var reader = new FileReader();

      reader.onload = function(e) {
        $('#image_upload .profile-pic').attr('src', e.target.result);
      }

      reader.readAsDataURL(input.files[0]);
    }
  };

	$('.mobileNav').click(function(e) {
		e.preventDefault();
		$('body').toggleClass('openNav');
		$('.mobileNav').toggleClass('change');
		$('.userAccount').slideToggle();
	});

	$('[data-toggle="tooltip"]').tooltip();

	new DG.OnOffSwitchAuto({
		cls:'.custom-switch',
		textOn: 'On',
		textOff: 'Off',
    listener: function(name, checked){
      toggleUserIdentity($(this), checked);
    }
	});

    new DG.OnOffSwitchAuto({
        cls:'.user_ghost_mode_top_menu .custom-switch',
        textOn: 'On',
        textOff: 'Off',
        listener: function(name, checked){
            url = location.protocol + '//' + location.host +"/users/settings/change_ghost_mod";
            $.ajax({
                url: url,
                method: "PUT",
                data: { checked: checked}
            });
            //alert("Name: " + name + " - checked: " + checked);
        }
    });
	$('.seeMoreContent').click(function(e) {
		e.preventDefault();
		$(this).text(function(i, text){
			return text === "Less" ? "See more" : "Less";
		});
		$('.postContent').toggleClass('overFlowHidden');
	});

  function toggleUserIdentity(elm, checked) {
    if (checked) {
      $('#user-detail').find('img').attr('src', default_img_src);
      $('#user-detail').find('.authinfoWrapName').find('h6').text('Anonymous');
      $('#user-detail').find('.authinfoWrapName').find('p').text('Ghost mode');
    } else {
      $('#user-detail').find('img').attr('src', user_img_src);
      $('#user-detail').find('.authinfoWrapName').html(author_name);
    }
  }

});

function select_question_answer(ele){
  $(ele).children("type[hidden]")
  if($(ele).is(':checked')){
    $(".correct-incorrect").val("0")
    // id = $($(ele).siblings()[0]).attr("id")
    // $("li#"+id+" input.correct-incorrect").val("1")
    $(ele).parents('.displayCell.radi-btn').find("input.correct-incorrect").val("1")
  }
}