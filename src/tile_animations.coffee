@tile_animations = {}
@tile_animations["1n15e"] = {
  animate: ()->
    console.info("animating")
    position = [-289105, -82195]
    explosion = new Explosion(position)
    creatures.push(explosion)
    @explosion = explosion
    setTimeout (->
      bomb = new Bomb([position[0]-120, position[1]+60], true)
      bomb.player_speed = 5
      bomb.fall_speed = -10
      bomb.terminal_velocity = 30
      bomb.gravity_factor = 1
      creatures.push(bomb)
      @bomb = bomb
    ), 100
    # stickman.position = [-288973.716, -82283.672]
  trigger_position: [-289673.716, -82115.0192]
}


@tile_animations["1n7e"] = {
  animate: ()->
    world.keeping_stickman_in_view = false
    old_position = world.position
    bomb = undefined
    promise = new Promise((resolve, reject) ->
      world.scroll_to_position [
        -244000
        -82869
      ], ->
        resolve 'scroll finished'
        return
      return
    )

    promise
    .then((res) ->
      promise = new Promise((resolve, reject) ->
        setTimeout (->
          return resolve 'Princess in view'),
          1000
      )
      return promise

    )
    .then((res) ->
      promise = new Promise((resolve, reject) ->
        world.scroll_to_position [
          -243000
          -82869
        ], ->
          resolve 'scroll finished'
          return
      )
      return promise
    )
    .then((res) ->
      promise = new Promise((resolve, reject) ->
        bowser.move_to_position [
          -243830.216
          -83195.5984
        ], ->
          resolve 'bowser moved!'
          return
      )
      return promise
    )
    .then((res) ->
      bowser.gravity_factor = 0.5
      bowser.jump()
      promise = new Promise((resolve, reject) ->
        bowser.move_to_position [
          -243776
          -83134.5
        ], ->
          bowser.throw_fireburst()
          bomb = new Bomb([bowser.position[0]+20, bowser.position[1]+20])
          creatures.push(bomb)
          return resolve 'bowser moved to pipe!'
      )
      return promise
    )
    .then((res) ->
      promise = new Promise((resolve, reject) ->
        setTimeout (->
          return resolve 'Princess in view'),
          200
      )
      return promise

    )
    .then((res) ->
      promise = new Promise((resolve, reject) ->
        bowser.gravity = 0
        bowser.disable_collisions = true
        bowser.move_to_position [
          -243765
          -83250
        ], ->
          bowser.is_move_left = false
          bowser.is_moving_right = false
          resolve 'bowser moved down!'
          return
        return
      )
      return promise
    )
    .then((res) ->
      bowser.position = [-101385.28293333332, -155000.936799969]
      bowser.disable_collisions = false
      bowser.is_invincible = false
      bowser.gravity = 1
      bowser.gravity_factor = 1
      bowser.set_direction('left')
      promise = new Promise((resolve, reject) ->
        setTimeout (->
          bomb.explode(false, false)
          return resolve 'bowser is in his lair'),
          2000
      )
      return promise

    )
    .then((res) ->
      promise = new Promise((resolve, reject) ->
        setTimeout (->
          return resolve 'after explosion'),
          1000
      )
      return promise

    )
    .then((res) ->
      promise = new Promise((resolve, reject) ->
        world.scroll_to_position old_position, (->
          resolve 'it worked'
          return)
        return
      )
      return promise
    )
    .then((res) ->
      setTimeout  ()->
        console.info 'keeping stickman'
        world.keeping_stickman_in_view = true
      setTimeout (->
        # [x_tile, y_tile] = tile_number_abs(bowser.position, bowser.tilesize)
        # bowser.load_image(undefined, x_tile, y_tile)
        bowser.attack_loop()
      ), 100
    )
  trigger_position: [-243260.216, -83123.5984],
  triggered: false
}

