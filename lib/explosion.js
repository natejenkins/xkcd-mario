// Generated by CoffeeScript 1.9.3
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  this.Explosion = (function(superClass) {
    extend(Explosion, superClass);

    function Explosion(position, blast_radius) {
      this.position = position;
      this.blast_radius = blast_radius != null ? blast_radius : 150;
      this.blast_vector = bind(this.blast_vector, this);
      this.kill_victim = bind(this.kill_victim, this);
      this.kill_victims = bind(this.kill_victims, this);
      this.name = "explosion";
      this.img_src = "./stick_figures/explosion_01_strip13.png";
      this.num_frames = 13;
      Explosion.__super__.constructor.call(this, this.name, this.position, this.img_src, this.num_frames);
      this.always_animate = true;
      this.player_speed = 0.0;
      this.gravity_factor = 0;
      this.stop_animate_on_last_frame = true;
      this.die_in(10000);
      this.sound.play();
      this.dont_kill_owner = false;
      this.owner = void 0;
    }

    Explosion.prototype.sound = new Howl({
      src: ['sounds/explosion.mp3'],
      html5: true
    });

    Explosion.prototype.after_sound = new Howl({
      src: ['sounds/after_explosion.mp3'],
      volume: 0.1,
      html5: true
    });

    Explosion.prototype.kill_victims = function() {
      this.kill_victim(stickman);
      return creatures.forEach((function(_this) {
        return function(creature) {
          return _this.kill_victim(creature);
        };
      })(this));
    };

    Explosion.prototype.kill_victim = function(creature) {
      var blast_vector, blast_vector_length, gf, nm, ps, tuv;
      if (!creature) {
        return;
      }
      if ((creature.cur_x_tile === void 0) || (creature.cur_y_tile === void 0)) {
        return;
      }
      if ((Math.abs(creature.cur_x_tile - this.cur_x_tile) > 1) || (Math.abs(creature.cur_y_tile - this.cur_y_tile) > 1)) {
        return;
      }
      if (creature.name === 'coin') {
        return;
      }
      if (creature.name === 'bomb') {
        return;
      }
      if (creature.name === 'explosion') {
        return;
      }
      if (creature.name === 'crater') {
        return;
      }
      if (this.dont_kill_owner && this.owner === creature) {
        return;
      }
      blast_vector = this.blast_vector(creature);
      blast_vector_length = Math.hypot(blast_vector[0], blast_vector[1]);
      if (blast_vector_length < this.blast_radius) {
        if (creature.name === 'pipe') {
          creature.gravity_factor = 1;
          creature.rotation = 80;
          return creature.die_in(1000);
        } else {
          if (creature.is_invincible) {
            return;
          } else {
            creature.damage(5);
            tuv = creature.terminal_upward_velocity;
            gf = creature.gravity_factor;
            ps = creature.player_speed;
            nm = creature.name;
            creature.terminal_upward_velocity = 50;
            creature.jump_speed = 50 * blast_vector[1] / blast_vector_length + 20;
            creature.player_speed = 30 * Math.abs(blast_vector[0]) / blast_vector_length;
            if (blast_vector[0] < 0) {
              creature.set_direction('right');
            } else if (blast_vector[0] > 0) {
              creature.set_direction('left');
            }
            creature.rotation = 80;
            setTimeout((function(_this) {
              return function() {
                creature.rotation = 0;
                creature.terminal_upward_velocity = tuv;
                creature.gravity_factor = gf;
                creature.player_speed = ps;
                return creature.stop();
              };
            })(this), 1000);
          }
          if (creature === stickman) {
            world.keeping_stickman_in_view = false;
            world.flash_overlay((function(tile) {
              if (this.has_overlay && this.overlay_frame_counter < this.overlay_num_frames) {
                this.context.beginPath();
                this.context.fillStyle = 'orange';
                this.context.rect(this.position[0] + tile.left, this.position[1] + tile.top, this.tilesize, this.tilesize);
                this.context.fill();
                return this.overlay_frame_counter += 1;
              } else if (this.has_overlay) {
                return this.has_overlay = false;
              }
            }));
            setTimeout(((function(_this) {
              return function() {
                world.keeping_stickman_in_view = true;
              };
            })(this)), 500);
            setTimeout(((function(_this) {
              return function() {
                creature.rotation = 0;
                creature.stop();
                creature.terminal_upward_velocity = tuv;
                creature.gravity_factor = gf;
                creature.player_speed = ps;
              };
            })(this)), 1000);
            setTimeout(((function(_this) {
              return function() {
                _this.after_sound.play();
              };
            })(this)), 300);
            return 1;
          }
        }
      }
    };

    Explosion.prototype.blast_vector = function(creature) {
      var b_bottom, b_left, b_right, b_top, b_x_middle, b_y_middle, bottom, center_x, center_y, left, ref, ref1, ref2, ref3, ref4, ref5, right, top;
      ref = [creature.position[0] - creature.width, creature.position[1] + creature.height], left = ref[0], top = ref[1];
      ref1 = [creature.position[0], creature.position[1]], right = ref1[0], bottom = ref1[1];
      ref2 = [this.position[0] - this.width, this.position[1] + this.height], b_left = ref2[0], b_top = ref2[1];
      ref3 = [this.position[0], this.position[1]], b_right = ref3[0], b_bottom = ref3[1];
      ref4 = [b_left + (b_right - b_left) / 2, b_bottom + (b_top - b_bottom) / 2], b_x_middle = ref4[0], b_y_middle = ref4[1];
      ref5 = [left + (right - left) / 2, bottom + (top - bottom) / 2], center_x = ref5[0], center_y = ref5[1];
      return [center_x - b_x_middle, center_y - b_y_middle + 20];
    };

    return Explosion;

  })(this.Creature);

}).call(this);