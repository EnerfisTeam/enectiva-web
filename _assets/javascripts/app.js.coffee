FEAT_SLIDE_DELAY = 300

$ ->
  newlsetterHiddenClass = 'newsletter__submit--hidden'
  $subscribeSubmit = $('#SignupSubmit').addClass(newlsetterHiddenClass)
  $subscribeEmail = $('#mce-EMAIL')
  $subscribeEmail.keyup (e)->
    if $(e.target).val().trim() == ''
      $subscribeSubmit.addClass(newlsetterHiddenClass)
    else
      $subscribeSubmit.removeClass(newlsetterHiddenClass)

  $cta = $('#Cta')
  $cta.addClass('quick-contact--js')

  $body = $('body')
  $header = $('.header')
  adjustShowingOfCta = () ->
    max = -4.5
    min = 0
    offset = ($body.height() - $header.height()) / 3
    scroll = window.scrollY
    if scroll <= 0
      margin = max
    else if scroll >= offset
      margin = min
    else
      margin = ((offset - scroll) / offset) * max
    $cta.css('right', "#{margin}em")

  scrolled = false

  $(window).scroll () ->
    scrolled = true

  setInterval(() ->
    if scrolled
      scrolled = false
      adjustShowingOfCta()
  , 150)

  $ctaOpener = $cta.find('#CtaOpener')
  $ctaOpener.click (e)->
    if $body.width() >= 800
      e.preventDefault()
      $cta.toggleClass('quick-contact--opened')

#  $ContactForm = $('#ContactForm')
#  if $ContactForm.length
#    $requiredFields = $ContactForm.find('input.required')
#    $submit = $ContactForm.find('input[type=submit]')
#
#    requireField = ($input) ->
#      $error = $input.siblings('.errorMessage')
#      if $input.val().trim() == ''
#        $input.addClass('error')
#        $error.show()
#        false
#      else
#        $input.removeClass('error')
#        $error.hide()
#        true
#
#    $requiredFields.blur () ->
#      requireField($(this))
#
#    $ContactForm.submit (e) ->
#      e.preventDefault()
#      allValid = true
#      $requiredFields.each () ->
#        allValid = false unless requireField($(this))
#        true
#
#      return unless allValid
#
#      normalSubmitText = $submit.text()
#      alternativeSubmitText = contactFormI18n.submit_alt
#      $submit
#        .attr('disabled', 'disabled')
#        .val(alternativeSubmitText)
#      $.post 'http://enectiva.cz' + $ContactForm.attr('action') + '.json', $ContactForm.serialize(), (data) ->
#        $submit.removeAttr('disabled').val(normalSubmitText)
#        if data.errors
#          $.each data.errors, (field, errs) ->
#            $field = $ContactForm.find('input#contact_form_' + field)
#            $.each errs, (i, err) ->
#              $field.after($('<div class="errorMessage">').text(err).show())
#        else
#          $ContactForm.after('<div class="notice">' + contactFormI18n.submitted + '</div>')
#          $ContactForm.remove()
#      $ContactForm

#  $('.swipebox').swipebox();
#
#  $feats = $('div.feature')
#
#  if $feats.length > 0
#
#    # bind opening events
#    close_feats = ()->
#      $feats.filter('.active').each ()->
#        $feat = $(this)
#        $feat.find('div.inner').slideUp FEAT_SLIDE_DELAY, 'linear', ()->
#          $feat.removeClass('active')
#
#    open_feat = ($feat)->
#      close_feats()
#      if $feat.hasClass('active')
#        return
#      $feat.find('div.inner').slideDown FEAT_SLIDE_DELAY, 'linear', ()->
#        $feat.addClass('active')
#
#    $feats.find('h4, h2').click (e)->
#      $feat = $(this).parentsUntil('body', 'div.feature')
#      open_feat $feat
#
#    if document.location.hash.length > 0
#      $("##{document.location.hash.slice(1)}").click()
