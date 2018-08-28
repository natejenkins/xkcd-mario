
class @Bomb extends @Creature
  constructor: (@position, @is_dud=false) ->
    @name = 'bomb'
    # from https://opengameart.org/content/bomb-0
    @img_src = "./stick_figures/bomb-wick32.png"
    @num_animations = 1
    @num_frames = 5
    super(@name, @position, @img_src, @num_frames)
    @frame_factor = 15
    @is_squashed = false
    @always_animate = true
    @stop_animate_on_last_frame = true
    @blast_radius = 150
    @creature_changes_direction = false
    @gravity_factor = 0.1
    @terminal_velocity = 20
    @player_speed = 0
    @has_friction = true
    @friction_factor = 0.9
    @is_exploding=false
    if @is_dud
      # @frame_index = @num_frames - 1
      @stop_animate_on_last_frame = true
    @play_sound(@throw_sound)
  throw_sound: new Howl({
    src: ['sounds/throw_bomb.mp3'],
    volume: 0.5,
    html5: true
  })

  explode_in_tilenumber: (tilenumber) =>
    tilename   = tile_name2(tilenumber[0], tilenumber[1])
    image_hash = world.images[tilename]
    if image_hash and image_hash.canvas
      [x_rel, y_rel] = getPositionInTileAbs(@position, @tilesize, tilenumber)
      [x_norm, y_norm] = [x_rel/@tilesize, y_rel/@tilesize]
      canvas  = image_hash.canvas
      [x_reduced, y_reduced] = [x_norm*canvas.width, y_norm*canvas.height]
      context = canvas.getContext("2d")
      context.resetTransform()
      context.beginPath();
      context.arc(x_reduced,y_reduced, canvas.width*@blast_radius/@tilesize,0,2*Math.PI);
      context.fillStyle = 'white'
      context.fill();
      image_data = context.getImageData(0, 0, canvas.width, canvas.height)
      new_data = image_data.data

      data = world.images[image_hash.name].image_data.data
      i=0
      while i < data.length
        data[i] = new_data[i]
        # red
        data[i + 1] = new_data[i+1]
        # green
        data[i + 2] = new_data[i+2]
        # blue
        i += 4


  explode: (silently=false, shake=true)=>
    @has_exploded = true
    @player_speed = 0
    @gravity_factor = 0
    @fall_speed = 0
    index = creatures.indexOf(this)
    if(index >= 0)
      creatures.splice(index, 1)
      creatures.unshift(this)
    tilenumber = tile_number_abs(@position, @tilesize)
    left_tilenumber = tile_number_abs([@position[0]+@blast_radius, @position[1]], @tilesize)
    right_tilenumber = tile_number_abs([@position[0]-@blast_radius, @position[1]], @tilesize)
    top_tilenumber = tile_number_abs([@position[0], @position[1]+@blast_radius], @tilesize)
    bottom_tilenumber = tile_number_abs([@position[0], @position[1]-@blast_radius], @tilesize)
    @explode_in_tilenumber(tilenumber)
    if !silently
      explosion = new Explosion([@position[0]+100, @position[1]-100], @blast_radius)
      window.creatures.push(explosion)
      crater = new Crater(@position, @blast_radius)
      window.creatures.unshift(crater)
      if shake
        world.shake(explosion.kill_victims)
      else
        setTimeout explosion.kill_victims, 100

    if(left_tilenumber[0] != tilenumber[0])
      @explode_in_tilenumber(left_tilenumber)
    if(right_tilenumber[0] != tilenumber[0])
      @explode_in_tilenumber(right_tilenumber)
    if(top_tilenumber[1] != tilenumber[1])
      @explode_in_tilenumber(top_tilenumber)
    if(bottom_tilenumber[1] != tilenumber[1])
      @explode_in_tilenumber(bottom_tilenumber)



  is_in_blast_radius: (creature)=>
    inside_radius = false

    [left, top] = [creature.position[0] - creature.width, creature.position[1] + creature.height]
    [right, bottom] = [creature.position[0], creature.position[1]]
    [b_left, b_top] = [@position[0] - @width, @position[1] + @height]
    [b_right, b_bottom] = [@position[0], @position[1]]
    [b_x_middle, b_y_middle] = [b_left + (b_right - b_left)/2, b_bottom + (b_top - b_bottom)/2]
    # if (Math.pow(bottom-b_y_middle, 2) + Math.pow(left-b_x_middle, 2))<Math.pow(@blast_radius, 2)
      # inside_radius = true
    [center_x, center_y] = [left + (right-left)/2, bottom + (top-bottom)/2]
    blast_vector = [center_x-b_x_middle, center_y-b_y_middle]
    if(Math.hypot(blast_vector[0], blast_vector[1])<@blast_radius)
    # if (Math.pow(blast_vector[0], 2) + Math.pow(, 2))<Math.pow(@blast_radius, 2)
      inside_radius = true
    inside_radius

  explode_in: (milliseconds) =>
    setTimeout @explode, milliseconds

  has_collided: false

  draw: ()=>
    if not @has_exploded
      @draw_rotating()

  draw_rotating: () =>
    if(@is_moving_right || @is_moving_left || @is_jumping || @is_trying_to_jump || @always_animate)
      @frame_counter++
    if (@stop_animate_on_last_frame and (@frame_index == @num_frames - 1))
      # do nothing
    else
      @frame_index = Math.floor(@frame_counter/@frame_factor)%@num_frames


    if @direction > 0 and @player_speed != 0
      flipAxis = [@relative_position[0] + @frame_width/2, @relative_position[1] - @frame_height/2]
      @context.translate(flipAxis[0], flipAxis[1]);
      @context.rotate(-0.1*@player_speed*@frame_counter)
      @context.translate(-flipAxis[0], -flipAxis[1]);
    else if @direction < 0 and @player_speed != 0
      flipAxis = [@relative_position[0] + @frame_width/2, @relative_position[1] - @frame_height/2]
      @context.translate(flipAxis[0], flipAxis[1]);
      @context.rotate(0.1*@player_speed*@frame_counter)
      @context.translate(-flipAxis[0], -flipAxis[1]);

    @context.drawImage(@image, \
                       @frame_width*@frame_index,0,@frame_width ,@image.height,\
                       @relative_position[0], @relative_position[1] - @image.height, @frame_width,@image.height)




  draw_exploded: ()=>
    @context.beginPath();
    @context.arc(@relative_position[0],@relative_position[1],@blast_radius,0,2*Math.PI);
    @context.fillStyle = 'white'
    @context.fill();




