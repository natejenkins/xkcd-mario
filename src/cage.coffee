
class @Cage extends @Creature
  constructor: (@position) ->
    @name = "cage"
    @img_src = "./stick_figures/cage_tiled.png"
    @num_frames = 10
    super(@name, @position, @img_src, @num_frames)
    @player_speed = 0
    @creature_changes_direction = false
    @is_moving_left = false
    @is_moving_right = false
    @stop_animate_on_last_frame = true