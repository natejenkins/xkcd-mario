
class @Square extends @Creature
  constructor: (@position, @contents='coin') ->
    @name = "square"
    @img_src = "./stick_figures/square.png"
    @num_frames = 1
    super(@name, @position, @img_src, @num_frames)
    @gravity_factor = 0.0
    @player_speed = 0.0
    @already_bumped = false
    @creature_changes_direction = false
  coin_sound: new Howl({
    src: ['sounds/coin2.mp3'],
    volume: 0.1,
    html: true
  })
  # from https://www.zapsplat.com/music/cartoon-bounce-then-rising-whistle-1/, standard license
  flower_sound: new Howl({
    src: ['sounds/flower.mp3'],
    volume: 0.1,
    html5: true
  })

  bump: ()=>
    @already_bumped = true
    if @contents is 'coin'
      coin = new Coin([@position[0], @position[1]+20])
      creatures.push(coin)
      @coin_sound.play()
    else if @contents is 'flower'
      flower = new Flower([@position[0], @position[1]+20])
      creatures.push(flower)
      @flower_sound.play()

