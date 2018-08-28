
class @Plant extends @Creature
  constructor: (@position) ->
    @name = "plant"
    @img_src = "./stick_figures/plant.png"
    @num_frames = 3
    super(@name, @position, @img_src, @num_frames)
    @frame_factor = 7
    setInterval @jump, 5000
    @gravity_factor = 0.1
    @player_speed = 0.0
    @creature_changes_direction = false
    @disable_collisions = true
    @minimum_y_position = @position[1]

  jump: =>
    @fall_speed = -5

  draw: (world_position) =>
    @frame_counter++
    super(world_position)

  update_position: (world) =>
    super(world)
    if @position[1] < @minimum_y_position
      @position[1] = @minimum_y_position
    @calc_relative_position(world.position)






