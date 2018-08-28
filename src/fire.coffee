
class @Fire extends @Creature
  constructor: (@position) ->
    @name  = 'fire'
    @img_src = "./stick_figures/flame_frames.png"
    @num_animations = 1
    @num_frames = 4
    super(@name, @position, @img_src, @num_frames)
    @num_animations = 1
    @num_frames  = 4
    @is_squashed = false
    @always_animate = true
    @creature_changes_direction = false
    @gravity_factor = 0
    @player_speed = 0
    @has_collided = false

  draw: (relative_position, frame_counter) =>
    frame_index = Math.floor(frame_counter/@frame_factor)%@num_frames
    @context.drawImage(@image, \
                       @frame_width*frame_index,0,@frame_width ,@image.height,\
                       relative_position[0], relative_position[1] - @image.height, @frame_width,@image.height)




