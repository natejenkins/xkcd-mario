
class @Pipe extends @Creature
  constructor: (@position, @teleport_position) ->
    @name = "pipe"
    @img_src = "./stick_figures/pipe.png"
    @num_frames = 1
    super(@name, @position, @img_src, @num_frames)
    tilenumber = tile_number_abs(@position, @tilesize)
    @player_speed = 0
    callback = ()=>
      setTimeout(@place_in_tile, 500)
    @load_image( callback, tilenumber[0], tilenumber[1])
    @creature_changes_direction = false

  place_in_tile: () =>
    tilenumber = tile_number_abs(@position, @tilesize)
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
      # this is a hack which draws the pipe into the reduced resolution image used for collision detection.  Drawing the top
      # a little bit lower than normal ensures that stickman can tunnel through pipes, which requires a collision detection
      # with the pipe itself.  Basically painting the pipe into this canvas means that stickman will stop at the left or right
      # side of the pipe as if it were solid black region of the tile
      context.rect(x_reduced,y_reduced, canvas.width*@frame_width/@tilesize, -0.9*canvas.height*@frame_height/@tilesize);
      context.fillStyle = 'red'
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
      # $("#images").append(canvas)
    else
      console.info("image_hash not ready")


  creature_changes_direction: false
