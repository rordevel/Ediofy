jQuery ($) ->
  toolbar()

$voteInstructions = $votingUl = $currentScore = $voteUpCount = $voteDownCount = $voteButtons = null

toolbar = ->

  if ($toolbar = $('#toolbar')).length
    $buttons = $toolbar.find('li.dropdown-button').each (index, button) ->
      $button = $(button)
      $content = $button.find '.dropdown'
      $close = $content.find 'span.close'
      $activator = $button.find('.nav-item').not('.disabled').click (e) ->
        $buttons.not($button).removeClass 'active'
        $button.toggleClass 'active'
        prepareDropdown $content
      $close.click ->
        $button.removeClass 'active'
    setupVoting $toolbar
    reportToggle()

reportToggle = ->
  if ($dropdown = $('#report-dropdown')).length
    type = $dropdown.find('form').attr('id').replace 'new_', ''
    $input = $dropdown.find("##{type}_comments_input")
    $radio = $dropdown.find("##{type}_reason_other")
    $dropdown.find("input").change ->
      $input.toggle $radio.is(':checked')
    .change()

setupVoting = ($toolbar) ->
  $voteInstructions = $toolbar.find 'li.display .instructions'
  $votingUl = $toolbar.find 'ul.voting'
  $currentScore = $toolbar.find 'li.display .current .value'
  $voteUpCount = $toolbar.find 'li.vote.up .value'
  $voteDownCount = $toolbar.find 'li.vote.down .value'
  $voteButtons = $toolbar.find('li.vote')
    .hover ->
      $voteInstructions.addClass $(this).data 'vote'
    , ->
      $voteInstructions.removeClass 'up down'
    .click voteClick

voteClick = (e) ->
  $voteInstructions.removeClass 'up down'
  $currentScore.addClass 'loading'
  direction = if $(this).data('vote') is 'up' then 'up' else 'down'
  action = if $(this).hasClass 'voted' then 'no' else direction
  if action isnt 'no'
    $votingUl.addClass 'voted'
    if action is 'up'
      voteUp direction
    else
      voteDown direction
  else
    $votingUl.removeClass 'voted'
    voteRemove direction
  sendVote action

voteUp = (direction) ->
  if $voteButtons.filter('.down').hasClass 'voted'
    voteRemove 'down'
  $voteButtons.filter('.up').addClass 'voted'
  $voteUpCount.text parseInt($voteUpCount.text()) + 1

voteDown = (direction) ->
  if $voteButtons.filter('.up').hasClass 'voted'
    voteRemove 'up'
  $voteButtons.filter('.down').addClass 'voted'
  $voteDownCount.text parseInt($voteDownCount.text()) + 1

voteRemove = (direction) ->
  $voteButtons.removeClass 'voted'
  if direction is 'up'
    $voteUpCount.text parseInt($voteUpCount.text()) - 1
  else
    $voteDownCount.text parseInt($voteDownCount.text()) - 1

sendVote = (action) ->
  uri = $votingUl.data action
  $.post uri

prepareDropdown = ($dropdown) ->
  if ($tags = $dropdown.find('ol.tags')).length
    $tags.isotope 'reLayout'
