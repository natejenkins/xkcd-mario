class @World
  constructor: (normalized_position, @map_size) ->
    @position = [normalized_position[0]*@map_size[0], normalized_position[1]*@map_size[1]]
    @images = {}
    @scale = 0.25
    @canvas_id = 'stickman-canvas'
    @canvas = document.getElementById(@canvas_id)
    @context = @canvas.getContext("2d")
    @keeping_stickman_in_view = true

  # poorly named variable which is used in collision detection to help a player walk up a slope.
  # If stickman's feet are touching black, it moves stickman up one pixel and checks again, up to
  # MAX_COLLISION_COUNT times.  If he is high enough to be on top of the ground inside of having his feet
  # inside it, the new position is accepted.  If not, his position is reset to the position he was in just
  # before the collision.
  MAX_COLLISION_COUNT: 25

  image_data: undefined
  original_tilesize: undefined
  scale: undefined
  bool_empty_space: false

  centre: [0,0]
  centre_last: [-1,-1]
  t_name: undefined
  t_number: undefined
  scene: undefined
  map_size: undefined
  cur_tile_name: ''
  cur_x_tile: 1
  cur_y_tile: 1
  theme_song: new Howl({
    src: ['sounds/theme_song.mp3'],
    volume: 0.1,
    html5: true
  })

  pause: () =>
    @paused = true

  resume: () =>
    @paused = false
    requestAnimationFrame(updateWorld)
    if @sound_on and !@theme_song.is_playing
      @theme_song.play()
      @theme_song.is_playing = true

  toggle_pause: () =>
    if @paused
      @resume()
    else
      @pause()

  save: () =>
    stickman_json = stickman.toJSON()
    creatures_json = creatures.map (creature)=>
      creature.toJSON()
    tile_animations_json = {}
    Object.keys(tile_animations).map((key)=>
      tile_animations_json[key] = {
        triggered: tile_animations[key].triggered
      }


    )
    # TODO: store images
    # images_json = world.images.toJSON()

    localforage.setItem('stickman', stickman_json)
    localforage.setItem('creatures', creatures_json)
    localforage.setItem('tile_animations', tile_animations_json)
    # localforage.setItem('images', images_json)


  load: () =>
    p1 = localforage.getItem('stickman')
    p2 = localforage.getItem('creatures')
    p3 = localforage.getItem('tile_animations')
    p4 = localforage.getItem('images')

    cnames = {
      'mushroom_man': MushroomMan
    }

    return Promise.all([p1, p2, p3, p4]).then( (values)=>
      stickman_json = values[0]
      creatures_json = values[1]
      tile_animations_json = values[2]
      Object.keys(tile_animations_json).map((key)=>
        tile_animations[key].triggered = tile_animations_json[key].triggered
      )
      window.creatures = creatures_json.map( (c)=>
        if c.name == 'explosion'
          return undefined
        type = cnames[c.name]
        if !type
          type = window[c.name[0].toUpperCase() + c.name.substr(1)]
        creature = new type(c.position)
        if c.name == 'bowser'
          window.bowser = creature
        if c.name == 'bomb'
          creature = new type(c.position, c.is_dud)
          if !c.is_dud
            creature.has_exploded = true
            # TODO: store the images in localStorage instead of replaying the explosion here
            tilenumber = tile_number_abs(creature.position, creature.tilesize)
            callback = ()=>
              setTimeout ()=>
                creature.explode(true)
               , 100
            creature.load_image( callback, tilenumber[0], tilenumber[1])

        if c.name == 'crater'
          creature = new type(c.position, c.blast_radius, false)
        if c.name == 'pipe'
          creature.teleport_position = c.teleport_position
        creature
      ).filter((c)=>c) # removes any undefined elements
      old_stickman = window.stickman
      window.stickman = new Stickman(stickman_json.position)
      if stickman_json.has_bomb
        stickman.enable_bomb()
      if stickman_json.has_fire
        stickman.enable_fire()
      window.stickman.score    = stickman_json.score
      window.stickman.coins_collected = stickman_json.coins_collected

    )
    .catch( (err)=>
      console.warn(err)
    )

  unnormalized_map_coords: (normalized_position) =>
    [normalized_position[0]*@map_size[0], normalized_position[1]*@map_size[1]]
  normalized_map_coords: (unnormalized_position) =>
    [unnormalized_position[0]*1.0/@map_size[0], unnormalized_position[1]*1.0/@map_size[1]]



  # Ported from 1110.js.  Handles which tiles are loaded in memory.  Will store a maximum of 9 tiles,
  # the current center tile and his neighbors including corners.  Can be less if tiles are either
  # ground or sky, as neither requires a tile image to render.
  load_current_scene: () =>
    @centre_last=@centre

    # gives the x,y coord of current origin position as [x_tile_number, y_tile_number] */
    @centre = [Math.floor(-@position[0]/@tilesize),Math.floor(-@position[1]/@tilesize)]

    xrange = [-1,0,1]
    yrange = [-1,0,1]

    for y in yrange
      for x in xrange
        name=tile_name2(@centre[0]+x,@centre[1]+y)
        tile = @images[name]

        if not tile
          @load_tile(@centre[0] + x, @centre[1] + y)

  keep_stickman_in_view: (player_position, screen_width, screen_height) =>
    if !@keeping_stickman_in_view
      return

    BORDER_LEFT   = screen_width/2 - screen_width/6
    BORDER_RIGHT  = screen_width/2 + screen_width/6
    BORDER_TOP    = screen_height/2 - screen_height/6
    BORDER_BOTTOM = screen_height/2 + screen_height/6
    x = @position[0] - player_position[0]
    y = @position[1] - player_position[1]

    if x > BORDER_RIGHT
      @position[0] -= (x - BORDER_RIGHT)
      x = BORDER_RIGHT
    else if x < BORDER_LEFT
      @position[0] -= (x - BORDER_LEFT)
      x = BORDER_LEFT
    if y > BORDER_BOTTOM
      @position[1] -= (y - BORDER_BOTTOM)
      y = BORDER_BOTTOM
    else if y < BORDER_TOP
      @position[1] -= (y - BORDER_TOP)
      y = BORDER_TOP
    return 0

  scroll_to_position: (position, callback=undefined, scroll_factor=0.2, num_scrolls=0, max_num_scrolls=200) =>
    d = distance_between_points(position, @position)
    if d > 10 and num_scrolls < max_num_scrolls
      new_position = [@position[0] + (position[0] - @position[0])*scroll_factor, @position[1] + (position[1] - @position[1])*scroll_factor]
      @position = new_position
      setTimeout ()=>
        @scroll_to_position(position, callback, scroll_factor, num_scrolls+1, max_num_scrolls)
       , 15
    else
      if(num_scrolls > max_num_scrolls)
        console.info("exceed max scrolls")
      callback and callback()

  shake: (callback=undefined)=>
    [px, py] = @position
    @keeping_stickman_in_view = false
    r = 100
    scroll_factor = 1
    promise = new Promise((resolve, reject) =>
      @scroll_to_position([
        px - r
        py - r
      ],
      ->
        resolve 'scroll finished'
        return
      scroll_factor)
    )
    .then((res) =>
      promise = new Promise((resolve, reject) =>
        @scroll_to_position([
          px + r
          py + r
        ],
        ->
          resolve 'scroll finished'
          return
        scroll_factor)
      )
      return promise
    )
    .then((res) =>
      promise = new Promise((resolve, reject) =>
        @scroll_to_position([
          px - r
          py - 0
        ]
        ->
          resolve 'scroll finished'
          return
        scroll_factor)
      )
      return promise
    )
    .then((res) =>
      promise = new Promise((resolve, reject) =>
        @scroll_to_position([
          px - r
          py - r
        ]
        ->
          resolve 'scroll finished'
          return
        scroll_factor)
      )
      return promise
    )
    .then((res) =>
      promise = new Promise((resolve, reject) =>
        @scroll_to_position([
          px - r
          py + r
        ]
        ->
          resolve 'scroll finished'
          return
        scroll_factor)
      )
      return promise
    )
    .then((res) =>
      @keeping_stickman_in_view = true
      callback and callback()
    )

  flash_overlay: (overlay=undefined, num_frames=10) =>
    @has_overlay = true
    @overlay_frame_counter = 0
    @overlay_num_frames = num_frames
    if overlay
      @overlay = overlay
    else
      @overlay = ( (tile) =>
        console.warn("provide overlay function")
        @has_overlay = false
      )


  # returns a position from -1 to 1 in both directions
  get_position_in_world: (position_on_screen) =>
    abs_coords = [@position[0] - position_on_screen[0], @position[1] - position_on_screen[1]]
    @normalized_map_coords(abs_coords)

  load_image: (x_tile, y_tile, callback) =>
    name=tile_name2(x_tile,y_tile)
    tile = @images[name]
    if not (tile and tile.image_data)
      @load_tile(x_tile, y_tile, callback)
    else
      callback and callback(tile)

  load_tile: (x, y, callback) =>
    name = tile_name2(x,y)
    left = x * @tilesize
    top  = y * @tilesize
    @images[name] = {
      name: name
      left: left
      top: top
    }


    img = new Image();
    img.onload = () =>
      if !(@images[name] and @images[name].canvas)
        @scene_canvas = document.createElement("canvas")
        @scene_canvas.width = img.width * @scale
        @scene_canvas.height = img.height * @scale
        @scene_context = @scene_canvas.getContext("2d")
        @scene_context.scale @scale, @scale
        @scene_context.drawImage img, 0, 0
        @image_data = @scene_context.getImageData(0, 0, img.width * @scale, img.height * @scale)
        @images[name] = {
          name: name
          dom: img
          left: left
          top: top,
          image_data: @image_data,
          canvas: @scene_canvas
        }
      callback and callback(@images[name])
    img.onerror = (e) =>
      console.info("ERROR LOADING IMAGE")
      @scene_canvas = document.createElement("canvas")
      @scene_canvas.width = 2048 * @scale
      @scene_canvas.height = 2048 * @scale
      @scene_context = @scene_canvas.getContext("2d")
      @scene_context.rect(0,0,@scene_canvas.width, @scene_canvas.height)
      @scene_context.fillStyle = 'red'
      @scene_context.fill();
      @image_data = @scene_context.getImageData(0, 0, @scene_canvas.width, @scene_canvas.height)
      @images[name] = {
        name: name
        left: left
        top: top,
        image_data: @image_data,
        canvas: @scene_canvas
      }
      # This is useful to keep around for debugging
      callback and callback(@images[name])

    if file_hash[name]
      img.src='./xkcd_grab/'+name+'.png'
    else
      if name.match(/\dn/)
        img.src='./xkcd_grab/'+'white.png'
      else
        img.src='./xkcd_grab/'+'black.png'


  draw: () =>
    @context.setTransform(1, 0, 0, 1, 0, 0);

    xrange = [-1,0,1]
    yrange = [-1,0,1]

    for y in yrange
      for x in xrange
        name=tile_name2(@centre[0]+x,@centre[1]+y)
        tile = @images[name]
        if(tile)
          if(tile.dom)
            @context.drawImage(tile.dom, @position[0]+tile.left, @position[1]+tile.top, @tilesize, @tilesize);
            if @borders
              @context.beginPath()
              @context.strokeStyle='green'
              @context.rect(@position[0]+tile.left,@position[1]+tile.top,@tilesize, @tilesize)
              @context.stroke();
            if @has_overlay
              @overlay(tile)

  end_scene: ()=>
    @keeping_stickman_in_view = false
    old_position = @position
    bomb = undefined
    promise = new Promise((resolve, reject) =>
      @scroll_to_position [
        -244000
        -82869
      ], (->
        resolve 'scroll finished'
        return), 0.2, 0, 500
      return
    )
    -244000

    promise
    .then((res) =>
      # hack to get animation going
      cage.is_moving_left = true
      promise = new Promise((resolve, reject) ->
        setTimeout (->
          cage.die()
          creatures.unshift(cage)
          princess.player_speed = 1
          princess.is_moving_right = true
          stickman.change_score 1000
          resolve 'scene finished'),
          2000
      )
      return promise
    )
    .then((res) =>
      promise = new Promise((resolve, reject) ->
        setTimeout (->
          resolve 'delay finished'),
          5000
      )
      return promise
    )
    .then((res) =>
      promise = new Promise((resolve, reject) =>
        @scroll_to_position old_position, (->
          resolve 'last scroll finished'
          return), 0.2, 0, 500
        return
      )
    )
    .then((res) ->
      world.keeping_stickman_in_view = true
    )

