
class @Creature
  constructor: (@name, @position, @img_src, @num_frames) ->
    @tilesize = world.tilesize
    @old_position = @position.slice()
    @img=$('<img src=' + @img_src + ' style="top:0px;left:0px;" z-index: -1; position: absolute;" style="display:none" />')
    @image = @img[0]

    @image.onload = () =>
      @frame_width   = Math.floor(@image.width/(@num_frames*@num_animations))
      @frame_height  = @image.height
      @height = @image.height
      @width = @frame_width

    @canvas_id = 'stickman-canvas'
    @canvas = document.getElementById(@canvas_id)
    @context = @canvas.getContext("2d")
    @frame_counter = 0
    #frame_factor slows down the animations a bit
    @frame_factor  = 5
    #adding a number of different animations, for the moment just left and right
    @num_animations = 1

    @frame_index   = 0
    @relative_position = [0,0]
    @is_moving_left = false
    @is_moving_right = false
    @is_jumping = false
    @is_trying_to_jump = false
    @is_moving_up = false
    @player_speed = 1
    @direction = 1
    if @direction == 1
      @is_moving_left = true
      @is_moving_right = false
    else
      @is_moving_right = true
      @is_moving_left = false
    @jump_speed = 0.0
    @fall_speed = 0.0
    @jump_force = 7
    @terminal_jump_speed = 7
    @terminal_velocity = 10
    @terminal_upward_velocity = 20
    @collision_count = 0
    @tile_index = [0,0]
    @creature_changes_direction = true
    @gravity_factor = 1.0
    @disable_collisions = false
    @has_friction = false
    @friction_factor = 1.0
    @fire_frame_counter = 0
    @is_on_fire = false
    @gravity = 1.0

  load_image: (callback, x_tile, y_tile) =>
    if x_tile != undefined
      t_number = [x_tile, y_tile]
    else
      t_number = tile_number_abs(@position, @tilesize)
      @t_name = tile_name2(t_number[0], t_number[1])
    world.load_image(t_number[0], t_number[1], (image_hash)=>
      @image_data = image_hash.image_data
      @image_hash = image_hash
      callback and callback()
    )
    setInterval(@possibly_change_direction, 1000);
  update_position: (world) =>
    @old_position = @position.slice()
    [x, y] = @position

    if @is_trying_to_jump
      @jump_speed += @jump_force
      if @jump_speed > @terminal_jump_speed
        @jump_speed = @terminal_jump_speed
        @is_trying_to_jump = false
        @is_jumping = true
        @fall_speed -= @jump_force
    else if @jump_speed > 0
      @fall_speed -= @jump_speed
      @is_jumping = true
      @jump_speed = 0
    @fall_speed += @gravity*@gravity_factor
    if @fall_speed > @terminal_velocity
      @fall_speed = @terminal_velocity
      @is_jumping = true
    @fall_speed = -@terminal_upward_velocity  if @fall_speed < -@terminal_upward_velocity

    y -= @fall_speed
    x += (if @is_moving_left then @player_speed else 0)
    x -= (if @is_moving_right then @player_speed else 0)
    y -= (if @is_moving_down then @player_speed else 0)

    ########################## load new scene if needed
    [x_tile, y_tile] = tile_number_abs([x,y], @tilesize)
    if (x_tile isnt @cur_x_tile) or (y_tile isnt @cur_y_tile)
      @cur_x_tile = x_tile
      @cur_y_tile = y_tile
      @load_image(undefined, @cur_x_tile, @cur_y_tile)

    if !@disable_collisions
      [old_x, old_y] = [x,y]
      [x,y] = @checkCollisions(x,y, world, 0)
      if old_x != x or old_y != y and @has_friction
        @player_speed = @player_speed * @friction_factor
        if Math.abs(@player_speed) < 0.001
          @player_speed = 0

    @position = [x, y]
    @calc_relative_position(world.position)

  checkCollisions: (x, y, world, collision_count, callback=undefined) =>
    [x_rel, y_rel] = getPositionInTileAbs([x, y], @tilesize)
    if collision_count > world.MAX_COLLISION_COUNT
      @change_direction()
      @has_collided = false
      return @old_position
    [x_norm, y_norm] = [x_rel/@tilesize, y_rel/@tilesize]
    if getImagePixelNormCoords(@image_data, x_norm, y_norm, false) is 0
      if !@can_bounce
        @fall_speed = 0
      @is_jumping = false
      @is_moving_up = false
      @has_collided = true
      @checkCollisions x, y + 1, world, collision_count + 1
    else
      if @has_collided
        @has_collided = false
        if @can_bounce
          @fall_speed = -@fall_speed
        if @collision_callback
          @collision_callback()
          @collision_callback = undefined
      [x, y]

  possibly_change_direction: () =>
    return if !@creature_changes_direction
    if Math.random() > 0.5
      @change_direction()

  change_direction: () =>
    @direction = -@direction
    if @direction == 1
      @is_moving_left = true
      @is_moving_right = false
    else
      @is_moving_right = true
      @is_moving_left = false

  set_direction: (direction='left') =>
    if direction is 'left'
      @direction = 1
      @is_moving_left = true
      @is_facing_left = true
      @is_facing_right = false
      @is_moving_right = false
    else
      @direction = -1
      @is_moving_right = true
      @is_facing_right = true
      @is_moving_left = false
      @is_facing_left = false
  stop: =>
    @is_moving_left = false
    @is_moving_right = false

  moveRight: =>
    @is_moving_right = true
    @is_facing_right = true

  moveLeft: =>
    @is_moving_left = true
    @is_facing_right = false

  move_to_position: (position, callback=undefined, tries=0) =>
    @always_animate = true
    scroll_factor = 1
    max_tries = 1000
    d = distance_between_points(position, @position)
    if(tries > max_tries)
      console.warn("max tries exceeded in move_to_position")
      callback and callback()
      return
    if d > 10
      direction_x = (position[0] - @position[0]) > 0 and 1 or -1
      direction_y = (position[1] - @position[1]) > 0 and 1 or -1
      new_position = [@position[0] + direction_x*scroll_factor, @position[1] + direction_y*scroll_factor]
      if direction_x > 0
        @is_facing_left = true
        @is_facing_right = false
      else
        @is_facing_left = false
        @is_facing_right = true
      @position = new_position
      setTimeout ()=>
        @move_to_position(position, callback, tries + 1)
       , 15
    else
      @always_animate = false
      callback and callback()


  jump: =>
    unless @is_moving_up
      @is_moving_up = true
      @is_trying_to_jump = true
      @frame_counter = 0

  duck: =>
    @is_moving_down = true



  calc_relative_position: (world_position) =>
    @relative_position[0] = world_position[0] - @position[0]
    @relative_position[1] = world_position[1] - @position[1]

  die: () =>
    index = creatures.indexOf(@)
    if(index >= 0)
      creatures.splice(index, 1)
  die_in: (milliseconds)=>
    setTimeout @die, milliseconds

  # There is a frame_counter which increments and the modulus of @num_frames by the frame_counter gives
  # the current frame index from 0 to @num_frames-1.
  # The index may stop on the last frame of an animation if @stop_animate_on_last_frame is set.
  # The rest of the @frame_index modifications are to put it in the current animation.  Animations are stored
  # in the image one after another, so any frame + @num_frames will give the same relative offset to the
  # next animation.
  draw: () =>
    if(@is_moving_right || @is_moving_left || @is_jumping || @is_trying_to_jump || @always_animate)
      @frame_counter++
    if (@stop_animate_on_last_frame and (@frame_index == @num_frames - 1))
      # do nothing
    else
      @frame_index = Math.floor(@frame_counter/@frame_factor)%@num_frames
    # if he is jumping, currently we just put him on the last frame of the jumping sequence
    if @is_jumping
      animation_index = 1
      # @frame_index = @num_frames - 1
    else if @is_trying_to_jump
      animation_index = 1
    else if @is_moving_down
      animation_index = 2
    else
      animation_index = 0

    if animation_index > @num_animations - 1
      animation_index = 0

    if @is_moving_right || @is_facing_right
      flipAxis = @relative_position[0] + @frame_width/2
      @context.translate(flipAxis, 0);
      @context.scale(-1,1)
      @context.translate(-flipAxis, 0);

    if @rotation
      flipAxis = [@relative_position[0] + @frame_width/2, @relative_position[1] - @frame_height/2]
      @context.translate(flipAxis[0], flipAxis[1]);
      @context.rotate(@rotation)
      @context.translate(-flipAxis[0], -flipAxis[1]);

    @context.drawImage(@image, \
                       @frame_width*(animation_index*@num_frames + @frame_index),0,@frame_width ,@image.height,\
                       @relative_position[0], @relative_position[1] - @image.height, @frame_width,@image.height)
    if @is_on_fire
      window.fire.draw(@relative_position, @fire_frame_counter++)

  # currently only works for fireballs as this is the fastest calculation
  creature_collision: (other_creature) =>
    [left, top] = [@position[0] - @width, @position[1] + @height]
    [right, bottom] = [@position[0], @position[1]]
    [c_left, c_top] = [other_creature.position[0] - other_creature.width, other_creature.position[1] + other_creature.height]
    [c_right, c_bottom] = [other_creature.position[0], other_creature.position[1]]
    collided = false
    if @point_creature_collision(left, bottom, c_left, c_top, c_right, c_bottom)
      bottom_left = true
      collided = true
    else if @point_creature_collision(right, bottom, c_left, c_top, c_right, c_bottom)
      bottom_right = true
      collided = true
    else if @point_creature_collision(c_left, c_bottom, left, top, right, bottom)
      cbottom_left = true
      collided = true
    else if @point_creature_collision(c_right, c_bottom, left, top, right, bottom)
      cbottom_right = true
      collided = true
    else if @point_creature_collision(left, top, c_left, c_top, c_right, c_bottom)
      top_left = true
      collided = true
    else if @point_creature_collision(right, top, c_left, c_top, c_right, c_bottom)
      top_right = true
      collided = true
    else if @point_creature_collision(c_left, c_top, left, top, right, bottom)
      ctop_left = true
      collided = true
    else if @point_creature_collision(c_right, c_top, left, top, right, bottom)
      ctop_right = true
      collided = true

    if collided and @name == 'fireball'
      if (other_creature.name == 'mushroom_man')
        other_creature.is_on_fire = true
        @play_sound(@burn_sound)
        setTimeout(other_creature.die, 1000)
        setTimeout(@die, 1)
      else if other_creature.name == 'pipe'
        setTimeout(@die, 1)
      else if other_creature.name == 'plant'
        other_creature.is_on_fire = true
        @play_sound(@burn_sound)
        setTimeout(other_creature.die, 1000)
        setTimeout(@die, 1)
      else if other_creature.name == 'bowser'
        if !other_creature.is_invicible
          other_creature.is_on_fire = true
          @play_sound(@burn_sound)
          setTimeout(other_creature.die, 1000)
          setTimeout(@die, 1)
        else
          @change_direction()
  point_creature_collision: (x, y, c_left, c_top, c_right, c_bottom) =>
    if x > c_left and x < c_right and y > c_bottom and y < c_top
      return true
    return false

  damage: (amount)=>
    @energy -= amount
    if @energy < 0
      @die_in 1000

  toJSON: ()=>
    {
      position: @position,
      energy: @energy,
      name: @name,
      blast_radius: @blast_radius,
      teleport_position: @teleport_position,
      is_dud: @is_dud
    }

  play_sound: (sound)=>
    if !sound
      sound = @sound
    if world.sound_on and sound
      sound.play()

