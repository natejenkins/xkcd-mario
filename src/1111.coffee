
# gets the blue component of the color in imageData.  Used for collision detection.
# x,y: coords relative to the current tile's origin and a flag indicating whether this region is sky
# instead of actual pixel coords, we can do the sam ething with normalized coords from 0,0 to 1,1
@getImagePixelNormCoords = (imageData, x, y, is_empty_space=false) ->
  return 255  if is_empty_space
  return 255 if imageData is undefined
  blueComponent = imageData.data[Math.floor(y*imageData.height)*imageData.width*4 + Math.floor(x*imageData.width)*4 + 2]
  blueComponent

# gets position in pixels in the current tile, from 0 to tilesize in both directions
@getPositionInTileAbs = (player_position, tilesize, tilenumber=undefined) ->
  x_abs = player_position[0]
  y_abs = player_position[1]
  if tilenumber
    zero = tilenumber
  else
    zero = [Math.floor(-x_abs / tilesize), Math.floor(-y_abs / tilesize)]
  rel = [Math.floor(((-x_abs) / tilesize - zero[0]) * tilesize), Math.floor(((-y_abs) / tilesize - zero[1]) * tilesize)]

@tile_name2 = (x,y, size=[14,48,25,33]) ->
  x-=size[3]
  y-=size[0]
  if y>=0
    y_part = (y+1)+'s'
  else
    y_part = -y+'n'
  if x>=0
    x_part = (x+1)+'e'
  else
    x_part = -x+'w'
  return y_part + x_part

@tile_number_abs = (player_position, tilesize) ->
  x_abs = player_position[0]
  y_abs = player_position[1]
  [Math.floor(-x_abs / tilesize), Math.floor(-y_abs / tilesize)]

@distance_between_points = (p1, p2) ->
  Math.pow(Math.pow(p1[0] - p2[0], 2) + Math.pow(p1[1] - p2[1], 2), 0.5)

@updateWorld = () ->
  if not world.paused
    window.stickman.update_position world
    window.stickman.context.clearRect(0, 0, window.stickman.canvas.width, window.stickman.canvas.height)
    world.keep_stickman_in_view(window.stickman.position, screen_width, screen_height)
    world.load_current_scene()
    world.draw()

    for creature in creatures
      if !creature
        continue
      creature.calc_relative_position world.position
      if creature.relative_position[0] > -2*world.canvas_width and creature.relative_position[0] < 3*world.canvas_width and creature.relative_position[1] > -2*world.canvas_height and creature.relative_position[1] < 3*world.canvas_height
        creature.context.setTransform(1, 0, 0, 1, 0, 0)
        creature.update_position world
        creature.draw()
        window.stickman.creature_collision(creature)
        if creature.name == 'fireball'
          for other_creature in creatures
            if other_creature && (other_creature.name == 'mushroom_man' or other_creature.name == 'bowser' or other_creature.name == 'plant')
              creature.creature_collision(other_creature)
    window.stickman.context.setTransform(1, 0, 0, 1, 0, 0);
    window.stickman.draw()

    requestAnimationFrame(updateWorld)

c = 1
original_tilesize = 1
stickman = 1
tilesize = 1
world = 1

screen_width = 0
screen_height = 0

$( window ).resize () =>
  $container = $("#comic")
  screen_width = $container.width()
  screen_height = $container.height()
  canvas = $container.find('canvas')[0]
  canvas.width = screen_width
  canvas.height = screen_height
  world && world.canvas_width = canvas.width
  world && world.canvas_height = canvas.height


Map = ($container) ->
  @init = ->
    history.pushState null, null, location.href

    window.onpopstate = ->
      history.go 1
      return

    # looks like this is [north_tiles, east_tiles, south_tiles, west_tiles] with padding on
    # both north and south
    size = [14, 48, 25, 33]
    zoom=3.0
    original_tilesize = 2048
    tilesize = Math.floor(original_tilesize * zoom)

    screen_width = $container.width()
    screen_height = $container.height()


    canvas = $container.find('canvas')[0]
    canvas.width = screen_width
    canvas.height = screen_height

    map_size = [(size[1] + size[3]) * tilesize, (size[0] + size[2]) * tilesize]

    scale = 0.25

    normalized_position = [-0.4815, -0.346]

    world = new World(normalized_position, map_size)
    world.original_tilesize = original_tilesize
    world.scale = scale
    world.tilesize = tilesize
    world.borders = false
    world.sound   = true
    world.canvas_width = canvas.width
    world.canvas_height = canvas.height
    world.sound_on = true
    window.world = world

    world.load_current_scene()
    #######################
    stickman = new Stickman(world.unnormalized_map_coords(normalized_position))
    b = new Bowser(world.unnormalized_map_coords(initial_game_state.bowser.position))
    #######################
    # stickman = new Stickman([-243074, -83195])
    # stickman = new Stickman([-100910.28293333332, -155000.936799969])
    # b = new Bowser([-101385.28293333332, -155000.936799969])
    # b.attack_loop()
    ####################
    pipe_position = world.unnormalized_map_coords([-0.482,-0.3473])
    pipe_teleport_position = world.unnormalized_map_coords([-0.5812530462319959,-0.342])
    pipe = new Pipe(pipe_position, [-289673.716, -82115.0192+300])
    plant = new Plant(world.unnormalized_map_coords([-0.48203, -0.3472]))
    # huge_pipe = new Pipe(world.unnormalized_map_coords([-0.4898081490054869,-0.34750240384615383]), world.unnormalized_map_coords([-0.20276789748371055, -0.6468722322381185]), 'pipe.png')
    princess_coords = [-244521.216, -83195]
    princess = new Princess(princess_coords)
    cage     = new Cage(world.unnormalized_map_coords([-0.4911759420010288, -0.3467950253739316]))
    flower_square = new Square(world.unnormalized_map_coords([-0.4830206725823045, -0.3468883547008547]), 'flower')

    creatures = []
    squares = []

    creatures = [b, plant, pipe, princess, cage, flower_square]
    for position in initial_game_state.square_positions
      creatures.push(new Square(world.unnormalized_map_coords(position)))

    pipes = [pipe]
    for position in initial_game_state.pipe_positions
      i = i + 1
      p = new Pipe(world.unnormalized_map_coords(position[0]), world.unnormalized_map_coords(position[1]))
      creatures.push(p)
      pipes.push(p)
    for position in initial_game_state.coin_positions
      creatures.push(new Coin(world.unnormalized_map_coords(position), true))


    for position in initial_game_state.mushroom_men_positions
      creatures.push(new MushroomMan(world.unnormalized_map_coords(position)))

    total_coins = initial_game_state.square_positions.length + initial_game_state.coin_positions.length
    $('#total-coins').text(total_coins)

    window.creatures = creatures
    window.squares = squares
    window.stickman = stickman
    window.fire = new Fire([0,0])
    window.bowser = b
    window.pipes = pipes
    window.world = world
    window.cage = cage
    window.princess = princess
    stickman.load_image ->
      requestAnimationFrame(updateWorld)
      world.pause()
      # setTimeout (=>
      #   world.paused = true
      # ), 1000
  return this

$ ->
  map = new Map($("#comic"))
  map.init()










