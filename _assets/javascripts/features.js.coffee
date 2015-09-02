$ ->
  $menu = $('.menu--sticky')
  $icons = $menu.find('.feature__icon')

  menuHeight = $menu.outerHeight()
  inactiveCls = 'feature__icon--inactive'
  activeCls = 'feature__icon--active'

  $icons.click (e) ->
    e.preventDefault()
    anchor = $(this).attr('href')
    $('html, body').animate
      scrollTop: $(anchor).offset().top - menuHeight
    , 500
    window.location.hash = anchor

  $('.menu__placeholder').waypoint
    handler: (direction) ->
      $placeholder = $(this.element)
      cls = 'menu--stuck'

      if direction == 'down'
        $menu.addClass cls
        $icons.addClass inactiveCls
        height = menuHeight
      else
        $menu.removeClass cls
        $icons.removeClass inactiveCls
        $icons.removeClass activeCls
        height = 0
      $placeholder.height height

  $('.feature__title').waypoint
    handler: () ->
      $title = $(this.element)

      $icons.addClass(inactiveCls).removeClass activeCls
      $icons.filter("[href=##{$title.attr('id')}]").removeClass(inactiveCls).addClass activeCls
    offset: menuHeight