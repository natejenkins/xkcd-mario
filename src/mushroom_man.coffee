
class @MushroomMan extends @Creature
  constructor: (@position) ->
    @name = "mushroom_man"
    @img_src = "./stick_figures/enemy_squashed.png"
    @num_frames = 4
    super(@name, @position, @img_src, @num_frames)
    @num_animations = 2
    @is_squashed = false
    @creature_changes_direction = false
    @energy = 1
  # from https://www.zapsplat.com/music/cartoon-bubble-pop-2-4/, standard license
  squished_sound: new Howl({
    src: ['sounds/squish.mp3'],
    volume: 0.1,
    html5: true
  })

  draw: (world_position) =>
    if(@is_moving_right || @is_moving_left || @is_jumping || @is_trying_to_jump)
      @frame_counter++
    @frame_index = Math.floor(@frame_counter/@frame_factor)%@num_frames
    if @is_squashed
      @frame_index = @num_frames + 3
    if @is_moving_right
      flipAxis = @relative_position[0] + @frame_width/2
      @context.translate(flipAxis, 0);
      @context.scale(-1,1)
      @context.translate(-flipAxis, 0);
    @context.drawImage(@image, \
                       @frame_width*@frame_index,0,@frame_width ,@image.height,\
                       @relative_position[0], @relative_position[1] - @image.height, @frame_width,@image.height)
    if @is_on_fire
      window.fire.draw(@relative_position, @fire_frame_counter++)






