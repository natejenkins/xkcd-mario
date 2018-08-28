
class @Princess extends @Creature
  constructor: (@position) ->
    @name = "princess"
    @img_src = "./stick_figures/stickman_princess.png"
    @num_frames = 4
    super(@name, @position, @img_src, @num_frames)
    @num_animations = 2
    @frame_factor = 7
    @player_speed = 0.0
    @creature_changes_direction = false
    @is_moving_left = false
    @is_moving_right = false






