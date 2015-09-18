$ ->

  do () ->
    $menu = $('.menu--sticky')
    $icons = $menu.find('.feature__icon')
    menuHeight = $menu.outerHeight()

    $icons.click (e) ->
      e.preventDefault()
      anchor = $(this).attr('href')
      $('html, body').animate
        scrollTop: $(anchor).offset().top - menuHeight
      , 500
      window.location.hash = anchor

    if document.location.hash
      $icon = $icons.filter("[href=#{document.location.hash}]")
      if $icon.length
        $icon.click()

    activeCls = 'feature__icon--active'
    stuckMenuCls = 'menu--stuck'

    $('.menu__placeholder').waypoint
      handler: (direction) ->
        $placeholder = $(this.element)

        if direction == 'down'
          $menu.addClass stuckMenuCls
          height = menuHeight
        else
          $menu.removeClass stuckMenuCls
          $icons.removeClass activeCls
          height = 0
        $placeholder.height height

    $features = $('.feature')

    structure = []
    $features.each (i, e) ->
      $e = $(e)
      s = {
        topEdge: e.offsetTop
        height: $e.height()
        name: $e.find('.feature__title').attr('id')
      }
      s.bottomEdge = s.topEdge + s.height
      structure[i] = s

    $w = $(window)
    viewportHeight = $w.height()
    lastActive = null

    debounce = (fn, delay) ->
      timer = null
      ->
        context = this
        args = arguments
        clearTimeout timer
        timer = setTimeout((->
          fn.apply context, args
          return
        ), delay)
        return

    # Debounce scroll - some browsers trigger scroll all the time + it gives
    # better behaviour when using programmatic scroll
    $w.scroll debounce () ->
      # If the menu is not stuck, reset last active
      unless $menu.hasClass(stuckMenuCls)
        lastActive = null
        return

      # Get top and bottom position of content viewport (accounting for sticky menu)
      topEdge = $w.scrollTop() + menuHeight
      bottomEdge = topEdge + viewportHeight - menuHeight

      # Calculate % visible of each feature
      visibility = []
      $.each structure, (_, e) ->
        visibility.push (Math.min(e.bottomEdge, bottomEdge) - Math.max(e.topEdge, topEdge)) / e.height

      # Get active feature as the one with highest visibility, prefer earlier
      active = structure[visibility.indexOf(Math.max.apply(Math, visibility))].name

      # If active item changed, toggle classes
      if active != lastActive
        $icons.removeClass activeCls
        $icons.filter("[href=##{active}]").addClass activeCls
        lastActive = active
    , 50
    $w.scroll()

  do () ->
    cls = 'feature__step-number'
    activeCls = "#{cls}--active"
    $('.feature').each (i, e) ->
      $feature = $(e)

      $steps = $feature.find(".#{cls}")
      $feature.find(".feature__plan .#{cls}").add($feature.find('.feature__steps li')).hover (e) ->
        $target = $(e.target)
        $step = if $target.is(".#{cls}")
          $target
        else
          $target.find(".#{cls}")

        $steps.filter("[data-i=#{$step.data('i')}]").addClass(activeCls)
      , () ->
        $steps.removeClass(activeCls)
