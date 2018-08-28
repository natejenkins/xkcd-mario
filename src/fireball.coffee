
class @Fireball extends @Creature
  constructor: (@position) ->
    @name = 'fireball'
    @img_src = "./stick_figures/fireball.png"
    super(@name, @position, @img_src, @num_frames)
    @num_animations = 1
    @num_frames  = 4
    @is_squashed = false
    @always_animate = true
    @creature_changes_direction = false
    @gravity_factor = 1
    @player_speed = 3
    @can_bounce = true
    @fall_speed = 10
    @has_collided = false

    @play_sound(@throw_sound)

  burn_sound: new Howl({
    src: ['sounds/burn.mp3'],
    volume: 0.5,
    html5: true
  })

  throw_sound: new Howl({
    src: ['sounds/throw_fireball.mp3'],
    volume: 0.5,
    html5: true
  })

