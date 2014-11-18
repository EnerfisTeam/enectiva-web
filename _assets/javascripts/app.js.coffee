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
      old = $ctaOpener.text()
      $ctaOpener.text($ctaOpener.attr('alt'))
      $ctaOpener.attr('alt', old)

  $forms = $('#ContactForm, #Cta form')
  if $forms.length
    $('.error-message').hide()

    $forms.each (i, form) ->
      $form = $(form)
      $requiredFields = $form.find('input.required')
      $submit = $form.find('input[type=submit]')
      prefix = $form.data('prefix')
      if prefix
        prefix = "#{prefix}_"
      else
        prefix = ''

      requireField = ($input) ->
        $error = $input.siblings('.error-message')
        if $input.val().trim() == ''
          $input.addClass('error')
          $error.show()
          false
        else
          $input.removeClass('error')
          $error.hide()
          true

      $requiredFields.blur () ->
        requireField($(this))

      $form.submit (e) ->
        e.preventDefault()
        allValid = true
        $requiredFields.each () ->
          allValid = false unless requireField($(this))
          true

        return unless allValid

        normalSubmitText = $submit.text()
        alternativeSubmitText = contactFormI18n.submit_alt
        $submit
          .attr('disabled', 'disabled')
          .val(alternativeSubmitText)

        $.post 'http://enectiva.cz' + $form.attr('action') + '.json', $form.serialize(), (data) ->
          $submit.removeAttr('disabled').val(normalSubmitText)
          if data.errors
            $.each data.errors, (field, errs) ->
              $field = $form.find("input##{prefix}contact_form_#{field}")
              $.each errs, (i, err) ->
                $field.after($('<div class="errorMessage">').text(err).show())
          else
            $form.after('<div class="notice">' + contactFormI18n.submitted + '</div>')
            remove = $form.data('remove')
            if remove
              $form.parents("##{remove}").remove()
            else
              $form.remove()

    $ContactForm = $('#ContactForm')
    if $ContactForm.length
      if $ContactForm.find('.alternatives input:checked').length == 0
        if window.location.hash != ''
          toCheck = $ContactForm.
            find(".alternatives input[value=#{window.location.hash.split('#')[1]}]")
        else
          toCheck = $ContactForm.find('.alternatives input:first')
        toCheck.attr('checked', 'checked')

    $contactFormName = $('#contact_form_name')
    $contactFormName.change ()->
      if $(this).val().trim() != ''
        $ContactForm.find('.contact__extra').addClass('contact__extra--shown')
        $contactFormName.unbind('change')


  $('.swipebox').swipebox();

  $feats = $('.feature')

#  if $feats.length > 0

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
