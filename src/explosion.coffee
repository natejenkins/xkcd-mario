class @Explosion extends @Creature
  constructor: (@position, @blast_radius=150) ->
    @name = "explosion"
    # from https://opengameart.org/content/simple-explosion-bleeds-game-art
    @img_src = "./stick_figures/explosion_01_strip13.png"
    @num_frames = 13
    super(@name, @position, @img_src, @num_frames)
    @always_animate = true
    @player_speed = 0.0
    @gravity_factor = 0
    @stop_animate_on_last_frame = true
    @die_in(10000)

    @sound.play()
    @dont_kill_owner = false
    @owner = undefined

  sound: new Howl({
    src: ['sounds/explosion.mp3'],
    html5: true
  })
  after_sound: new Howl({
    src: ['sounds/after_explosion.mp3'],
    volume: 0.1,
    html5: true
  })

  kill_victims: () =>
    @kill_victim(stickman)
    creatures.forEach (creature) =>
      @kill_victim(creature)

  kill_victim: (creature) =>
    if !creature
      return
    if (creature.cur_x_tile is undefined) or (creature.cur_y_tile is undefined)
      return
    if (Math.abs(creature.cur_x_tile - @cur_x_tile) > 1) or (Math.abs(creature.cur_y_tile - @cur_y_tile) > 1)
      return
    if(creature.name == 'coin')
      return
    if creature.name == 'bomb'
      return
    if creature.name == 'explosion'
      return
    if creature.name == 'crater'
      return
    if @dont_kill_owner and @owner == creature
      return
    blast_vector = @blast_vector(creature)
    blast_vector_length = Math.hypot(blast_vector[0], blast_vector[1])
    if(blast_vector_length<@blast_radius)
      if creature.name == 'pipe'
        creature.gravity_factor = 1
        creature.rotation = 80
        creature.die_in 1000
      else
        if creature.is_invincible
          return
        else
          creature.damage(5)
          # TODO: store these in creature, chance here that multiple bombs cause an exploded speed to get
          # set back as the default
          tuv = creature.terminal_upward_velocity
          gf  = creature.gravity_factor
          ps  = creature.player_speed
          nm  = creature.name
          creature.terminal_upward_velocity=50
          creature.jump_speed = 50*blast_vector[1]/blast_vector_length + 20
          creature.player_speed = 30*Math.abs(blast_vector[0])/blast_vector_length
          if(blast_vector[0] < 0)
            creature.set_direction('right')
          else if blast_vector[0] > 0
            creature.set_direction('left')
          creature.rotation = 80
          setTimeout ()=>
            creature.rotation = 0
            creature.terminal_upward_velocity = tuv
            creature.gravity_factor = gf
            creature.player_speed   = ps
            creature.stop()
           , 1000

          if creature == stickman
            world.keeping_stickman_in_view = false

            # single arrow since we want 'this' to be world and not bomb
            world.flash_overlay ( (tile)->
              if @has_overlay and @overlay_frame_counter < @overlay_num_frames
                @context.beginPath()
                @context.fillStyle='orange'
                @context.rect(@position[0]+tile.left,@position[1]+tile.top,@tilesize, @tilesize)
                @context.fill()
                @overlay_frame_counter += 1
              else if @has_overlay
                @has_overlay = false
            )

            setTimeout (=>
              world.keeping_stickman_in_view = true
              return
            ), 500
            setTimeout (=>
              creature.rotation = 0
              creature.stop()
              creature.terminal_upward_velocity = tuv
              creature.gravity_factor = gf
              creature.player_speed   = ps
              return
            ), 1000
            setTimeout (=>
              @after_sound.play()
              return
            ), 300
            1


  blast_vector: (creature) =>
   [left, top] = [creature.position[0] - creature.width, creature.position[1] + creature.height]
   [right, bottom] = [creature.position[0], creature.position[1]]
   [b_left, b_top] = [@position[0] - @width, @position[1] + @height]
   [b_right, b_bottom] = [@position[0], @position[1]]
   [b_x_middle, b_y_middle] = [b_left + (b_right - b_left)/2, b_bottom + (b_top - b_bottom)/2]
   [center_x, center_y] = [left + (right-left)/2, bottom + (top-bottom)/2]
   # adding in a small offset prefers sending creatures in the air rather than sideways
   [center_x-b_x_middle, center_y-b_y_middle+20]


