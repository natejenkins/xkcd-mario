
class @Bowser extends @Creature
  constructor: (@position) ->
    @name = "bowser"
    @img_src = "./stick_figures/bowser.png"
    @num_frames = 121
    super(@name, @position, @img_src, @num_frames)
    @num_animations = 2
    @frame_factor = 1
    @is_squashed = false
    next_fireball = 1000
    @is_moving_left = false
    @is_moving_right = false
    @creature_changes_direction = false
    @fireball_fall_speed = -10
    @fireball_player_speed = 5
    @fireball_gravity_factor = 0.5
    @is_invicible = true

    @jump_speed = 0.0
    @jump_force = 7
    @terminal_jump_speed = 10
    @terminal_velocity = 30
    @terminal_upward_velocity = 20
    @energy = 10

  throw_fireball: =>
    fireball = new Fireball([@position[0], @position[1]+20])
    fireball.fall_speed = @fireball_fall_speed
    fireball.player_speed = @fireball_player_speed
    fireball.direction = @direction
    fireball.gravity_factor = @fireball_gravity_factor
    fireball.die_in 10000
    creatures.push(fireball)
    next_fireball = Math.random()*10000
    setTimeout @throw_fireball, next_fireball


  throw_fireburst: =>
    num_fireballs = 10
    fireballs = []
    i=0
    x_offset = (@direction == 1) and 40 or -100
    while i<10

      fireball = new Fireball([@position[0] + x_offset, @position[1]+20])
      fireball.fall_speed = @fireball_fall_speed + i*Math.random()
      fireball.player_speed = @fireball_player_speed + i
      if @is_moving_right
        fireball.direction = -1
        fireball.is_moving_right = true
        fireball.is_moving_left  = false
      else
        fireball.direction = 1
        fireball.is_moving_left  = true
        fireball.is_moving_right = false
      fireball.gravity_factor = @fireball_gravity_factor
      fireball.die_in 2000
      fireballs.push fireball
      i += 1
    window.creatures = window.creatures.concat fireballs

    if @attack_loop_enabled
      setTimeout @attack_loop, 1000

  air_attack: =>
    d = @position[0] - stickman.position[0]
    if(d > 0)
      @set_direction('right')
    else
      @set_direction('left')
    @player_speed   = 20*(Math.abs(d))/600
    @gravity_factor = 0.5
    @jump()
    setTimeout @dive_bomb, 500

  dive_bomb: =>
    @gravity_factor = 10
    @player_speed = 0
    @collision_callback = ()=>
      explosion = new Explosion([@position[0]+100, @position[1]-100], 150)
      explosion.dont_kill_owner = true
      explosion.owner = @
      window.creatures.push(explosion)
      world.shake(explosion.kill_victims)
      if(@position[0] > stickman.position[0])
        @set_direction('right')
      else
        @set_direction('left')
      @player_speed = 1
      if @attack_loop_enabled
        setTimeout @attack_loop, 1000


  attack_loop: =>
    @attack_loop_enabled = true
    if Math.random() > 0.5
      attack = @air_attack
    else
      attack = @throw_fireburst

    time = Math.random()*2000

    setTimeout attack, time

  die: =>
    @attack_loop_enabled = false
    @is_dead = true
    super
    world.end_scene()

