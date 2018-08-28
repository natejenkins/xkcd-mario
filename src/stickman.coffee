@name = 'bomb'
# from https://opengameart.org/content/bomb-0
@img_src = "./stick_figures/bomb-wick32.png"
@num_animations = 1
@num_frames = 5
@canvas_id = 'stickman-canvas'


class @Stickman extends @Creature
  constructor: (@position) ->
    @name = 'stickman'
    @img_src = "./stick_figures/stickman5.png"
    @num_frames = 4
    @canvas_id = 'stickman-canvas'
    super(@name, @position, @img_src, @num_frames)
    @num_animations = 3
    # @has_fire = true
    # @has_bomb = true
    @coins_collected = 0
    @score = 0
    @new_score = 0
    @creature_changes_direction = false
    @is_moving_left = false
    @is_moving_right = false

    @player_speed = 7
    @jump_speed = 0.0
    @jump_force = 7
    @terminal_jump_speed = 10
    @terminal_velocity = 30
    @terminal_upward_velocity = 20

    @tiles_visited = {}
    @fire_frame_counter = 0
    @is_on_fire = false
    @should_load_tile_animations = true

  die: =>
    # console.info 'you just died'
    1


  checkCollisions: (x, y, world, collision_count) =>
    [x_rel, y_rel] = getPositionInTileAbs([x, y], @tilesize)
    return @old_position  if collision_count > world.MAX_COLLISION_COUNT
    [x_norm, y_norm] = [x_rel/@tilesize, y_rel/@tilesize]
    [x_norm_right, y_norm_top] = [(x_rel + @frame_width)/@tilesize, (y_rel - 32)/@tilesize]
    if getImagePixelNormCoords(@image_data, x_norm, y_norm, false) is 0
      @fall_speed = 0
      @is_jumping = false
      @is_moving_up = false
      @checkCollisions x, y + 1, world, collision_count + 1, @tilesize
    else if @is_jumping and getImagePixelNormCoords(@image_data, x_norm, y_norm_top, @bool_empty_space) is 0
      @checkCollisions x, y - 1, world, collision_count + 1, @tilesize
    else
      [x, y]

  throw_object: (object)=>
      object.player_speed = object.player_speed + @player_speed*(@is_moving_left or @is_moving_right)
      if stickman.is_facing_right or stickman.is_moving_right
        object.direction = -1
        object.is_moving_right = true
        object.is_moving_left  = false
      else
        object.direction = 1
        object.is_moving_left  = true
        object.is_moving_right = false
      creatures.push(object)

  throw_fireball: =>
    if @has_fire
      x_offset = @is_facing_right and -20 or 20
      fireball = new Fireball([@position[0]+x_offset, @position[1]+20])
      @throw_object(fireball)
      fireball.die_in 5000


  throw_bomb: =>
    if @has_bomb
      x_offset = @is_facing_right and -10 or 30
      bomb = new Bomb([@position[0]+x_offset, @position[1]+20])
      @throw_object(bomb)
      bomb.explode_in 1000

  creature_collision: (creature) =>
    [left, top] = [@position[0] - @width, @position[1] + @height]
    [right, bottom] = [@position[0], @position[1]]
    [c_left, c_top] = [creature.position[0] - creature.width, creature.position[1] + creature.height]
    [c_right, c_bottom] = [creature.position[0], creature.position[1]]
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

    if collided and creature.name == 'square'
      if top_left or top_right or cbottom_right or cbottom_left
        @position[1] = c_bottom - @height
        if not creature.already_bumped
          creature.bump()
      else if bottom_right or bottom_left or ctop_left or ctop_right
        stickman.is_jumping = false
        @position[1] = c_top
        @fall_speed = 0.0
    if collided and (creature.name == 'pipe' or creature.name == 'cage')
      if top_left or top_right or cbottom_right or cbottom_left
        if (top - c_bottom) < (c_bottom - bottom)
          @position[1] = c_bottom - @height
      else if bottom_right or bottom_left or ctop_left or ctop_right
        if(bottom_right or bottom_left)
          if(c_top-bottom)<(top-c_top)
            stickman.is_jumping = false
            if stickman.is_moving_down
              @position = creature.teleport_position
            else
              @position[1] = c_top
              @fall_speed = 0.0
        else
          stickman.is_jumping = false
          if stickman.is_moving_down
            @position = creature.teleport_position
          else
            @position[1] = c_top
            @fall_speed = 0.0
    if collided and creature.name == 'coin'
      # the timeout is needed because this is modifying the creatures array during a loop
      setTimeout creature.die, 1
      @coins_collected += 1
      $('#coins-collected').text(@coins_collected)
    if collided and creature.name == 'flower'
      # the timeout is needed because this is modifying the creatures array during a loop
      setTimeout creature.die, 1
      @enable_fire()
    if collided and creature.name == 'fireball'
      # the timeout is needed because this is modifying the creatures array during a loop
      @is_on_fire = true
      creature.play_sound(creature.burn_sound)
      @change_score(-50)
      setTimeout creature.die, 1
      setTimeout (=>
        @is_on_fire = false
      ), 1000
    if collided and creature.name == 'plant'
      # the timeout is needed because this is modifying the creatures array during a loop
      if bottom_right or bottom_left or ctop_left or ctop_right
        @change_score(-50)
        stickman.jump()
    if collided and creature.name == 'bomb' and creature.is_dud == true
      # the timeout is needed because this is modifying the creatures array during a loop
      setTimeout creature.die, 1
      @enable_bomb()
    if collided and creature.name == 'mushroom_man'
      if top_left or top_right or cbottom_right or cbottom_left
        @change_score(-200)
        @position[1] = c_top + 10
        @fall_speed = -10.0
      else if bottom_right or bottom_left or ctop_left or ctop_right
        stickman.is_jumping = true
        @position[1] = c_top + 10
        creature.is_squashed = true
        creature.play_sound(creature.squished_sound)
        @fall_speed = -10.0
        setTimeout creature.die, 500
        @change_score(100)
    if collided and creature.name == 'turtle'
      if top_left or top_right or cbottom_right or cbottom_left
        @die()
      else if bottom_right or bottom_left or ctop_left or ctop_right
        stickman.is_jumping = true
        @position[1] = c_top + 10
        @fall_speed = -10.0
        creature.is_squashed = true
    if collided and creature.name == 'plant'
       @die()
    if collided and creature.name == 'fireball'
       @die()

  update_position: (world) ->
    super(world)

    @update_score()

    # check for any animations
    if @should_load_tile_animations
      tilename = tile_name2(@cur_x_tile, @cur_y_tile)
      @current_animation = tile_animations[tilename]

    if @current_animation and !@current_animation.triggered
      # console.info "animation not yet triggered"
      if distance_between_points(stickman.position, @current_animation.trigger_position) < 200
        console.info "triggering animation"
        @current_animation.triggered = true
        @current_animation.animate()

  enable_fire: () =>
    $("#button-action").css("color", "Tomato")
    @has_fire = true

  enable_bomb: () =>
    $("#button-bomb").css("color", "Tomato")
    @has_bomb = true

  toJSON: () =>
    creature_json = super
    stickman_json = {
      score: @score,
      has_fire: @has_fire,
      has_bomb: @has_bomb,
      coins_collected: @coins_collected
    }
    Object.assign({}, creature_json, stickman_json)

  change_score: (amount) =>
    @new_score = @new_score + amount

  update_score: () =>
    if @new_score > @score
      @score += 1
      $('#score').text(@score)
      $('#score').css('color', 'green')
      if @new_score == @score
        $('#score').css('color', '#333')
    else if @new_score < @score
      @score -= 1
      $('#score').text(@score)
      $('#score').css('color', 'red')
      if @new_score == @score
        $('#score').css('color', '#333')


