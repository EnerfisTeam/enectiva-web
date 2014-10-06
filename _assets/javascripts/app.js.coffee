FEAT_SLIDE_DELAY = 300

$ ->
  $ContactForm = $('#ContactForm')
  if $ContactForm.length
    $requiredFields = $ContactForm.find('input.required')
    $submit = $ContactForm.find('input[type=submit]')

    requireField = ($input) ->
      $error = $input.siblings('.errorMessage')
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

    $ContactForm.submit (e) ->
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
      $.post 'http://enectiva.cz' + $ContactForm.attr('action') + '.json', $ContactForm.serialize(), (data) ->
        $submit.removeAttr('disabled').val(normalSubmitText)
        if data.errors
          $.each data.errors, (field, errs) ->
            $field = $ContactForm.find('input#contact_form_' + field)
            $.each errs, (i, err) ->
              $field.after($('<div class="errorMessage">').text(err).show())
        else
          $ContactForm.after('<div class="notice">' + contactFormI18n.submitted + '</div>')
          $ContactForm.remove()
      $ContactForm

  $feats = $('div.feature')

  if $feats.length > 0

    $('a[rel]').prettyPhoto({ social_tools: false; })

    # bind opening events
    close_feats = ()->
      $feats.filter('.active').each ()->
        $feat = $(this)
        $feat.find('div.inner').slideUp FEAT_SLIDE_DELAY, 'linear', ()->
          $feat.removeClass('active')

    open_feat = ($feat)->
      close_feats()
      if $feat.hasClass('active')
        return
      $feat.find('div.inner').slideDown FEAT_SLIDE_DELAY, 'linear', ()->
        $feat.addClass('active')

    $feats.find('h4').click (e)->
      $feat = $(this).parentsUntil('body', 'div.feature')
      open_feat $feat
