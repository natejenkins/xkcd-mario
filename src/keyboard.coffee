$(document).ready ->
  ARROW_DOWN  = 40
  ARROW_RIGHT = 39
  ARROW_LEFT  = 37
  ARROW_UP    = 38
  F_KEY       = 70
  B_KEY       = 66
  SPACE_BAR   = 32
  W_KEY       = 87
  A_KEY       = 65
  S_KEY       = 83
  D_KEY       = 68
  CTRL_KEY    = 17
  SHIFT_KEY   = 16
  window.mouse_clicks = []
  $("#stickman-canvas").click (event) ->
    x = event.pageX - $(this).offset().left
    y = event.pageY - $(this).offset().top
    mouse_clicks.push(world.get_position_in_world([x,y]))
  $("body").keydown (event) ->
    w = event.which
    event.preventDefault()
    switch w
      when ARROW_DOWN, S_KEY
        stickman.duck()
      when ARROW_UP, W_KEY
        stickman.jump()
        setTimeout ()->
          stickman.is_moving_up = false
          stickman.is_trying_to_jump = false
         , 100
      when ARROW_LEFT, A_KEY
        stickman.moveLeft()
      when ARROW_RIGHT, D_KEY
        stickman.moveRight()
      when F_KEY, CTRL_KEY
        stickman.throw_fireball()
      when B_KEY, SHIFT_KEY
        stickman.throw_bomb()
      when SPACE_BAR
        world.toggle_pause()
      else
  $("body").keyup (event) ->
    w = event.which
    event.preventDefault()
    switch w
      when ARROW_DOWN, S_KEY
        stickman.is_moving_down = false
      # when ARROW_UP
      #   stickman.is_moving_up = false
      #   stickman.is_trying_to_jump = false
      when ARROW_LEFT, A_KEY
        stickman.is_moving_left = false
      when ARROW_RIGHT, D_KEY
        stickman.is_moving_right = false
      else
