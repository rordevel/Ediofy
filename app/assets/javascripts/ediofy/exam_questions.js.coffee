$(document).ready ->
  hide_hotkey_info()
  setup_hotkey_listener()
  setup_hotkey_close_button_listener()
  setup_hotkey_show_button_listener()
  setup_translation_button_listeners()
  setup_explanation_toggle()

setup_hotkey_listener = () ->
  if $('.user-exam-questions').length

    $(document).bind 'keydown', '1', -> select_answer 1
    $(document).bind 'keydown', '2', -> select_answer 2
    $(document).bind 'keydown', '3', -> select_answer 3
    $(document).bind 'keydown', '4', -> select_answer 4
    $(document).bind 'keydown', '5', -> select_answer 5
    $(document).bind 'keydown', '6', -> select_answer 6
    $(document).bind 'keydown', '7', -> select_answer 7
    $(document).bind 'keydown', '8', -> select_answer 8
    $(document).bind 'keydown', '9', -> select_answer 9

    $(document).bind 'keydown', 'return', (e)-> answer_question(e)
    $(document).bind 'keydown', 's', (e)-> skip_question(e)
    $(document).bind 'keydown', 'n', (e)-> answer_question_with_not_sure(e)


# Selects an choice
select_answer = (number) ->
  # Index starts at 0 so we take one from our number
  answer = $('.question input[type=radio]')[number - 1]
  if answer
    $(answer).attr 'checked', 'checked'

# Selects an answer
answer_question = (e) ->
  e.preventDefault()

  # If there are answers on the page then allow submit if one is selected
  if $('.question input[type=radio]').length
    if $('.question input[type=radio]:checked').length
      $('#member_exam_question_submit').click()
  else
    # If there are no answers on the page allow the next button to be pressed
    $('#member_exam_question_submit').click()

answer_question_with_not_sure = (e) ->
  e.preventDefault()

  # If there are answers on the page then allow submit if one is selected
  if $('.question input[type=radio]').length
    if $('.question input[type=radio]:checked').length
      $('#member_exam_question_not_sure').click()
  else
    # If there are no answers on the page allow the not sure button to be pressed
    $('#member_exam_question_not_sure').click()


# Skips a question
skip_question = (e) ->
  e.preventDefault()
  $('#member_exam_question_skip').click()

# Hide the question explanation and then show it when clicking the link
setup_explanation_toggle = () ->

  # Display the show translations button
  $('#member_exam_question_show_translation').show()

  # Hide the translations
  $('.question-translation').hide()
  $('.answer-translation').hide()

  if $('.question-submitted_explanation form').length
    $('.question-submitted_explanation').hide()
    $('.question-explanation p.explanation').show();
    $('.question-explanation a[href="#explanation"]').click (e) ->
      e.preventDefault()
      $('.question-submitted_explanation').slideToggle()

setup_translation_button_listeners = () ->
  $('#member_exam_question_show_translation').click (e) ->
    e.preventDefault()
    $('.question-translation, .answer-translation, #member_exam_question_hide_translation').show()
    $('.answer-translation').css('display', 'block')
    $(this).hide()

  $('#member_exam_question_hide_translation').click (e) ->
    e.preventDefault()
    $('.question-translation, .answer-translation').hide()
    $('#member_exam_question_show_translation').show()
    $(this).hide()

setup_hotkey_close_button_listener = () ->
  $('.keyboard-tip .close').click ->
    $.cookie('hide_keyboard_tips', 'true');
    hide_hotkey_info()

setup_hotkey_show_button_listener = () ->
  $('.show-keyboard-tip a').click (e) ->
    e.preventDefault()
    $.cookie('hide_keyboard_tips', 'false');
    hide_hotkey_info()

hide_hotkey_info = () ->
  if $.cookie('hide_keyboard_tips') == 'true'
    $('.keyboard-tip').hide()
    $('.show-keyboard-tip').show()
  else
    $('.keyboard-tip').show()
    $('.show-keyboard-tip').hide()
