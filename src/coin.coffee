
class @Coin extends @Creature
  constructor: (@position, stationary=false) ->
    @name = "coin"
    # from Spring Enterprises Independent https://opengameart.org/content/spincoin
    @img_src = "./stick_figures/coin.png"
    @num_frames = 6
    super(@name, @position, @img_src, @num_frames)
    @always_animate = true
    @creature_changes_direction = false
    if(!stationary)
      @can_bounce = true
      @fall_speed = -1.0
      @player_speed = 4.8
      @gravity_factor = 0.1
    else
      @can_bounce = false
      @fall_speed = 0
      @player_speed = 0
      @gravity_factor = 0

  # from https://www.zapsplat.com/music/fabric-money-pouch-with-coins-in-pick-up-2/
  sound: new Howl({
    src: ['sounds/capture_coin.mp3'],
    volume: 0.5,
    html5: true
  })

  die: ()=>
    @play_sound()
    super()


