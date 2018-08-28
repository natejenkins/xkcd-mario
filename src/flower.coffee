class @Flower extends @Creature
  constructor: (@position, @gravity_factor=1) ->
    @name = "flower"
    @creature_changes_direction = false
    @always_animate = true
    # from Lanea Zimmerman "Sharm" with contributions from https://opengameart.org/users/madmarcel https://opengameart.org/content/lpc-flower-grow-cycle
    @img_src = "./stick_figures/flower.png"
    @num_frames = 6
    @canvas_id = 'stickman-canvas'
    super(@name, @position, @img_src, @num_frames)
    @player_speed = 0.0
    @stop_animate_on_last_frame = true
    @fall_speed = 0
    @player_speed = 0
    @gravity_factor = 0

