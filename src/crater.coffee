
class @Crater extends @Creature
  constructor: (@position, @blast_radius, @offset_by_blast_radius=true) ->
    @name = 'crater'
    @img_src = "./stick_figures/crater.png"
    @num_animations = 1
    @num_frames = 1
    super(@name, @position, @img_src, @num_frames)
    @creature_changes_direction = false
    @gravity_factor = 0.0
    @terminal_velocity = 20
    @player_speed = 0
    @rotation_angle = Math.random()*360

    @img=$('<img src=' + @img_src + ' style="top:0px;left:0px;" z-index: -1; position: absolute;" style="display:none" />')
    @image = @img[0]

    @image.onload = () =>
      @frame_width   = Math.floor(@image.width/(@num_frames*@num_animations))
      @frame_height  = @image.height
      @height = @image.height
      @width = @frame_width
      if @offset_by_blast_radius
        @position = [@position[0] + @width/2, @position[1] - @height/2]



  draw: () =>
    @frame_index = 0
    flipAxis = [@relative_position[0] + @frame_width/2, @relative_position[1] - @frame_height/2]
    @context.translate(flipAxis[0], flipAxis[1]);
    @context.rotate(@rotation_angle)
    @context.translate(-flipAxis[0], -flipAxis[1]);

    @context.drawImage(@image, \
                       @frame_width*@frame_index,0,@frame_width ,@image.height,\
                       @relative_position[0], @relative_position[1] - @image.height, @frame_width,@image.height)
