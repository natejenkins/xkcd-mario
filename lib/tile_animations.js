// Generated by CoffeeScript 1.9.3
(function() {
  this.tile_animations = {};

  this.tile_animations["1n15e"] = {
    animate: function() {
      var explosion, position;
      console.info("animating");
      position = [-289105, -82195];
      explosion = new Explosion(position);
      creatures.push(explosion);
      this.explosion = explosion;
      return setTimeout((function() {
        var bomb;
        bomb = new Bomb([position[0] - 120, position[1] + 60], true);
        bomb.player_speed = 5;
        bomb.fall_speed = -10;
        bomb.terminal_velocity = 30;
        bomb.gravity_factor = 1;
        creatures.push(bomb);
        return this.bomb = bomb;
      }), 100);
    },
    trigger_position: [-289673.716, -82115.0192]
  };

  this.tile_animations["1n7e"] = {
    animate: function() {
      var bomb, old_position, promise;
      world.keeping_stickman_in_view = false;
      old_position = world.position;
      bomb = void 0;
      promise = new Promise(function(resolve, reject) {
        world.scroll_to_position([-244000, -82869], function() {
          resolve('scroll finished');
        });
      });
      return promise.then(function(res) {
        promise = new Promise(function(resolve, reject) {
          return setTimeout((function() {
            return resolve('Princess in view');
          }), 1000);
        });
        return promise;
      }).then(function(res) {
        promise = new Promise(function(resolve, reject) {
          return world.scroll_to_position([-243000, -82869], function() {
            resolve('scroll finished');
          });
        });
        return promise;
      }).then(function(res) {
        promise = new Promise(function(resolve, reject) {
          return bowser.move_to_position([-243830.216, -83195.5984], function() {
            resolve('bowser moved!');
          });
        });
        return promise;
      }).then(function(res) {
        bowser.gravity_factor = 0.5;
        bowser.jump();
        promise = new Promise(function(resolve, reject) {
          return bowser.move_to_position([-243776, -83134.5], function() {
            bowser.throw_fireburst();
            bomb = new Bomb([bowser.position[0] + 20, bowser.position[1] + 20]);
            creatures.push(bomb);
            return resolve('bowser moved to pipe!');
          });
        });
        return promise;
      }).then(function(res) {
        promise = new Promise(function(resolve, reject) {
          return setTimeout((function() {
            return resolve('Princess in view');
          }), 200);
        });
        return promise;
      }).then(function(res) {
        promise = new Promise(function(resolve, reject) {
          bowser.gravity = 0;
          bowser.disable_collisions = true;
          bowser.move_to_position([-243765, -83250], function() {
            bowser.is_move_left = false;
            bowser.is_moving_right = false;
            resolve('bowser moved down!');
          });
        });
        return promise;
      }).then(function(res) {
        bowser.position = [-101385.28293333332, -155000.936799969];
        bowser.disable_collisions = false;
        bowser.is_invincible = false;
        bowser.gravity = 1;
        bowser.gravity_factor = 1;
        bowser.set_direction('left');
        promise = new Promise(function(resolve, reject) {
          return setTimeout((function() {
            bomb.explode(false, false);
            return resolve('bowser is in his lair');
          }), 2000);
        });
        return promise;
      }).then(function(res) {
        promise = new Promise(function(resolve, reject) {
          return setTimeout((function() {
            return resolve('after explosion');
          }), 1000);
        });
        return promise;
      }).then(function(res) {
        promise = new Promise(function(resolve, reject) {
          world.scroll_to_position(old_position, (function() {
            resolve('it worked');
          }));
        });
        return promise;
      }).then(function(res) {
        setTimeout(function() {
          console.info('keeping stickman');
          return world.keeping_stickman_in_view = true;
        });
        return setTimeout((function() {
          return bowser.attack_loop();
        }), 100);
      });
    },
    trigger_position: [-243260.216, -83123.5984],
    triggered: false
  };

}).call(this);