// Generated by CoffeeScript 1.9.3
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Creature = (function() {
    function Creature(name, position1, img_src, num_frames) {
      this.name = name;
      this.position = position1;
      this.img_src = img_src;
      this.num_frames = num_frames;
      this.play_sound = bind(this.play_sound, this);
      this.toJSON = bind(this.toJSON, this);
      this.damage = bind(this.damage, this);
      this.point_creature_collision = bind(this.point_creature_collision, this);
      this.creature_collision = bind(this.creature_collision, this);
      this.draw = bind(this.draw, this);
      this.die_in = bind(this.die_in, this);
      this.die = bind(this.die, this);
      this.calc_relative_position = bind(this.calc_relative_position, this);
      this.duck = bind(this.duck, this);
      this.jump = bind(this.jump, this);
      this.move_to_position = bind(this.move_to_position, this);
      this.moveLeft = bind(this.moveLeft, this);
      this.moveRight = bind(this.moveRight, this);
      this.stop = bind(this.stop, this);
      this.set_direction = bind(this.set_direction, this);
      this.change_direction = bind(this.change_direction, this);
      this.possibly_change_direction = bind(this.possibly_change_direction, this);
      this.checkCollisions = bind(this.checkCollisions, this);
      this.update_position = bind(this.update_position, this);
      this.load_image = bind(this.load_image, this);
      this.tilesize = world.tilesize;
      this.old_position = this.position.slice();
      this.img = $('<img src=' + this.img_src + ' style="top:0px;left:0px;" z-index: -1; position: absolute;" style="display:none" />');
      this.image = this.img[0];
      this.image.onload = (function(_this) {
        return function() {
          _this.frame_width = Math.floor(_this.image.width / (_this.num_frames * _this.num_animations));
          _this.frame_height = _this.image.height;
          _this.height = _this.image.height;
          return _this.width = _this.frame_width;
        };
      })(this);
      this.canvas_id = 'stickman-canvas';
      this.canvas = document.getElementById(this.canvas_id);
      this.context = this.canvas.getContext("2d");
      this.frame_counter = 0;
      this.frame_factor = 5;
      this.num_animations = 1;
      this.frame_index = 0;
      this.relative_position = [0, 0];
      this.is_moving_left = false;
      this.is_moving_right = false;
      this.is_jumping = false;
      this.is_trying_to_jump = false;
      this.is_moving_up = false;
      this.player_speed = 1;
      this.direction = 1;
      if (this.direction === 1) {
        this.is_moving_left = true;
        this.is_moving_right = false;
      } else {
        this.is_moving_right = true;
        this.is_moving_left = false;
      }
      this.jump_speed = 0.0;
      this.fall_speed = 0.0;
      this.jump_force = 7;
      this.terminal_jump_speed = 7;
      this.terminal_velocity = 10;
      this.terminal_upward_velocity = 20;
      this.collision_count = 0;
      this.tile_index = [0, 0];
      this.creature_changes_direction = true;
      this.gravity_factor = 1.0;
      this.disable_collisions = false;
      this.has_friction = false;
      this.friction_factor = 1.0;
      this.fire_frame_counter = 0;
      this.is_on_fire = false;
      this.gravity = 1.0;
    }

    Creature.prototype.load_image = function(callback, x_tile, y_tile) {
      var t_number;
      if (x_tile !== void 0) {
        t_number = [x_tile, y_tile];
      } else {
        t_number = tile_number_abs(this.position, this.tilesize);
        this.t_name = tile_name2(t_number[0], t_number[1]);
      }
      world.load_image(t_number[0], t_number[1], (function(_this) {
        return function(image_hash) {
          _this.image_data = image_hash.image_data;
          _this.image_hash = image_hash;
          return callback && callback();
        };
      })(this));
      return setInterval(this.possibly_change_direction, 1000);
    };

    Creature.prototype.update_position = function(world) {
      var old_x, old_y, ref, ref1, ref2, ref3, x, x_tile, y, y_tile;
      this.old_position = this.position.slice();
      ref = this.position, x = ref[0], y = ref[1];
      if (this.is_trying_to_jump) {
        this.jump_speed += this.jump_force;
        if (this.jump_speed > this.terminal_jump_speed) {
          this.jump_speed = this.terminal_jump_speed;
          this.is_trying_to_jump = false;
          this.is_jumping = true;
          this.fall_speed -= this.jump_force;
        }
      } else if (this.jump_speed > 0) {
        this.fall_speed -= this.jump_speed;
        this.is_jumping = true;
        this.jump_speed = 0;
      }
      this.fall_speed += this.gravity * this.gravity_factor;
      if (this.fall_speed > this.terminal_velocity) {
        this.fall_speed = this.terminal_velocity;
        this.is_jumping = true;
      }
      if (this.fall_speed < -this.terminal_upward_velocity) {
        this.fall_speed = -this.terminal_upward_velocity;
      }
      y -= this.fall_speed;
      x += (this.is_moving_left ? this.player_speed : 0);
      x -= (this.is_moving_right ? this.player_speed : 0);
      y -= (this.is_moving_down ? this.player_speed : 0);
      ref1 = tile_number_abs([x, y], this.tilesize), x_tile = ref1[0], y_tile = ref1[1];
      if ((x_tile !== this.cur_x_tile) || (y_tile !== this.cur_y_tile)) {
        this.cur_x_tile = x_tile;
        this.cur_y_tile = y_tile;
        this.load_image(void 0, this.cur_x_tile, this.cur_y_tile);
      }
      if (!this.disable_collisions) {
        ref2 = [x, y], old_x = ref2[0], old_y = ref2[1];
        ref3 = this.checkCollisions(x, y, world, 0), x = ref3[0], y = ref3[1];
        if (old_x !== x || old_y !== y && this.has_friction) {
          this.player_speed = this.player_speed * this.friction_factor;
          if (Math.abs(this.player_speed) < 0.001) {
            this.player_speed = 0;
          }
        }
      }
      this.position = [x, y];
      return this.calc_relative_position(world.position);
    };

    Creature.prototype.checkCollisions = function(x, y, world, collision_count, callback) {
      var ref, ref1, x_norm, x_rel, y_norm, y_rel;
      if (callback == null) {
        callback = void 0;
      }
      ref = getPositionInTileAbs([x, y], this.tilesize), x_rel = ref[0], y_rel = ref[1];
      if (collision_count > world.MAX_COLLISION_COUNT) {
        this.change_direction();
        this.has_collided = false;
        return this.old_position;
      }
      ref1 = [x_rel / this.tilesize, y_rel / this.tilesize], x_norm = ref1[0], y_norm = ref1[1];
      if (getImagePixelNormCoords(this.image_data, x_norm, y_norm, false) === 0) {
        if (!this.can_bounce) {
          this.fall_speed = 0;
        }
        this.is_jumping = false;
        this.is_moving_up = false;
        this.has_collided = true;
        return this.checkCollisions(x, y + 1, world, collision_count + 1);
      } else {
        if (this.has_collided) {
          this.has_collided = false;
          if (this.can_bounce) {
            this.fall_speed = -this.fall_speed;
          }
          if (this.collision_callback) {
            this.collision_callback();
            this.collision_callback = void 0;
          }
        }
        return [x, y];
      }
    };

    Creature.prototype.possibly_change_direction = function() {
      if (!this.creature_changes_direction) {
        return;
      }
      if (Math.random() > 0.5) {
        return this.change_direction();
      }
    };

    Creature.prototype.change_direction = function() {
      this.direction = -this.direction;
      if (this.direction === 1) {
        this.is_moving_left = true;
        return this.is_moving_right = false;
      } else {
        this.is_moving_right = true;
        return this.is_moving_left = false;
      }
    };

    Creature.prototype.set_direction = function(direction) {
      if (direction == null) {
        direction = 'left';
      }
      if (direction === 'left') {
        this.direction = 1;
        this.is_moving_left = true;
        this.is_facing_left = true;
        this.is_facing_right = false;
        return this.is_moving_right = false;
      } else {
        this.direction = -1;
        this.is_moving_right = true;
        this.is_facing_right = true;
        this.is_moving_left = false;
        return this.is_facing_left = false;
      }
    };

    Creature.prototype.stop = function() {
      this.is_moving_left = false;
      return this.is_moving_right = false;
    };

    Creature.prototype.moveRight = function() {
      this.is_moving_right = true;
      return this.is_facing_right = true;
    };

    Creature.prototype.moveLeft = function() {
      this.is_moving_left = true;
      return this.is_facing_right = false;
    };

    Creature.prototype.move_to_position = function(position, callback, tries) {
      var d, direction_x, direction_y, max_tries, new_position, scroll_factor;
      if (callback == null) {
        callback = void 0;
      }
      if (tries == null) {
        tries = 0;
      }
      this.always_animate = true;
      scroll_factor = 1;
      max_tries = 1000;
      d = distance_between_points(position, this.position);
      if (tries > max_tries) {
        console.warn("max tries exceeded in move_to_position");
        callback && callback();
        return;
      }
      if (d > 10) {
        direction_x = (position[0] - this.position[0]) > 0 && 1 || -1;
        direction_y = (position[1] - this.position[1]) > 0 && 1 || -1;
        new_position = [this.position[0] + direction_x * scroll_factor, this.position[1] + direction_y * scroll_factor];
        if (direction_x > 0) {
          this.is_facing_left = true;
          this.is_facing_right = false;
        } else {
          this.is_facing_left = false;
          this.is_facing_right = true;
        }
        this.position = new_position;
        return setTimeout((function(_this) {
          return function() {
            return _this.move_to_position(position, callback, tries + 1);
          };
        })(this), 15);
      } else {
        this.always_animate = false;
        return callback && callback();
      }
    };

    Creature.prototype.jump = function() {
      if (!this.is_moving_up) {
        this.is_moving_up = true;
        this.is_trying_to_jump = true;
        return this.frame_counter = 0;
      }
    };

    Creature.prototype.duck = function() {
      return this.is_moving_down = true;
    };

    Creature.prototype.calc_relative_position = function(world_position) {
      this.relative_position[0] = world_position[0] - this.position[0];
      return this.relative_position[1] = world_position[1] - this.position[1];
    };

    Creature.prototype.die = function() {
      var index;
      index = creatures.indexOf(this);
      if (index >= 0) {
        return creatures.splice(index, 1);
      }
    };

    Creature.prototype.die_in = function(milliseconds) {
      return setTimeout(this.die, milliseconds);
    };

    Creature.prototype.draw = function() {
      var animation_index, flipAxis;
      if (this.is_moving_right || this.is_moving_left || this.is_jumping || this.is_trying_to_jump || this.always_animate) {
        this.frame_counter++;
      }
      if (this.stop_animate_on_last_frame && (this.frame_index === this.num_frames - 1)) {

      } else {
        this.frame_index = Math.floor(this.frame_counter / this.frame_factor) % this.num_frames;
      }
      if (this.is_jumping) {
        animation_index = 1;
      } else if (this.is_trying_to_jump) {
        animation_index = 1;
      } else if (this.is_moving_down) {
        animation_index = 2;
      } else {
        animation_index = 0;
      }
      if (animation_index > this.num_animations - 1) {
        animation_index = 0;
      }
      if (this.is_moving_right || this.is_facing_right) {
        flipAxis = this.relative_position[0] + this.frame_width / 2;
        this.context.translate(flipAxis, 0);
        this.context.scale(-1, 1);
        this.context.translate(-flipAxis, 0);
      }
      if (this.rotation) {
        flipAxis = [this.relative_position[0] + this.frame_width / 2, this.relative_position[1] - this.frame_height / 2];
        this.context.translate(flipAxis[0], flipAxis[1]);
        this.context.rotate(this.rotation);
        this.context.translate(-flipAxis[0], -flipAxis[1]);
      }
      this.context.drawImage(this.image, this.frame_width * (animation_index * this.num_frames + this.frame_index), 0, this.frame_width, this.image.height, this.relative_position[0], this.relative_position[1] - this.image.height, this.frame_width, this.image.height);
      if (this.is_on_fire) {
        return window.fire.draw(this.relative_position, this.fire_frame_counter++);
      }
    };

    Creature.prototype.creature_collision = function(other_creature) {
      var bottom, bottom_left, bottom_right, c_bottom, c_left, c_right, c_top, cbottom_left, cbottom_right, collided, ctop_left, ctop_right, left, ref, ref1, ref2, ref3, right, top, top_left, top_right;
      ref = [this.position[0] - this.width, this.position[1] + this.height], left = ref[0], top = ref[1];
      ref1 = [this.position[0], this.position[1]], right = ref1[0], bottom = ref1[1];
      ref2 = [other_creature.position[0] - other_creature.width, other_creature.position[1] + other_creature.height], c_left = ref2[0], c_top = ref2[1];
      ref3 = [other_creature.position[0], other_creature.position[1]], c_right = ref3[0], c_bottom = ref3[1];
      collided = false;
      if (this.point_creature_collision(left, bottom, c_left, c_top, c_right, c_bottom)) {
        bottom_left = true;
        collided = true;
      } else if (this.point_creature_collision(right, bottom, c_left, c_top, c_right, c_bottom)) {
        bottom_right = true;
        collided = true;
      } else if (this.point_creature_collision(c_left, c_bottom, left, top, right, bottom)) {
        cbottom_left = true;
        collided = true;
      } else if (this.point_creature_collision(c_right, c_bottom, left, top, right, bottom)) {
        cbottom_right = true;
        collided = true;
      } else if (this.point_creature_collision(left, top, c_left, c_top, c_right, c_bottom)) {
        top_left = true;
        collided = true;
      } else if (this.point_creature_collision(right, top, c_left, c_top, c_right, c_bottom)) {
        top_right = true;
        collided = true;
      } else if (this.point_creature_collision(c_left, c_top, left, top, right, bottom)) {
        ctop_left = true;
        collided = true;
      } else if (this.point_creature_collision(c_right, c_top, left, top, right, bottom)) {
        ctop_right = true;
        collided = true;
      }
      if (collided && this.name === 'fireball') {
        if (other_creature.name === 'mushroom_man') {
          other_creature.is_on_fire = true;
          this.play_sound(this.burn_sound);
          setTimeout(other_creature.die, 1000);
          return setTimeout(this.die, 1);
        } else if (other_creature.name === 'pipe') {
          return setTimeout(this.die, 1);
        } else if (other_creature.name === 'plant') {
          other_creature.is_on_fire = true;
          this.play_sound(this.burn_sound);
          setTimeout(other_creature.die, 1000);
          return setTimeout(this.die, 1);
        } else if (other_creature.name === 'bowser') {
          if (!other_creature.is_invicible) {
            other_creature.is_on_fire = true;
            this.play_sound(this.burn_sound);
            setTimeout(other_creature.die, 1000);
            return setTimeout(this.die, 1);
          } else {
            return this.change_direction();
          }
        }
      }
    };

    Creature.prototype.point_creature_collision = function(x, y, c_left, c_top, c_right, c_bottom) {
      if (x > c_left && x < c_right && y > c_bottom && y < c_top) {
        return true;
      }
      return false;
    };

    Creature.prototype.damage = function(amount) {
      this.energy -= amount;
      if (this.energy < 0) {
        return this.die_in(1000);
      }
    };

    Creature.prototype.toJSON = function() {
      return {
        position: this.position,
        energy: this.energy,
        name: this.name,
        blast_radius: this.blast_radius,
        teleport_position: this.teleport_position,
        is_dud: this.is_dud
      };
    };

    Creature.prototype.play_sound = function(sound) {
      if (!sound) {
        sound = this.sound;
      }
      if (world.sound_on && sound) {
        return sound.play();
      }
    };

    return Creature;

  })();

}).call(this);
