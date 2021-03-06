// Generated by CoffeeScript 1.9.3
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  this.Square = (function(superClass) {
    extend(Square, superClass);

    function Square(position, contents) {
      this.position = position;
      this.contents = contents != null ? contents : 'coin';
      this.bump = bind(this.bump, this);
      this.name = "square";
      this.img_src = "./stick_figures/square.png";
      this.num_frames = 1;
      Square.__super__.constructor.call(this, this.name, this.position, this.img_src, this.num_frames);
      this.gravity_factor = 0.0;
      this.player_speed = 0.0;
      this.already_bumped = false;
      this.creature_changes_direction = false;
    }

    Square.prototype.coin_sound = new Howl({
      src: ['sounds/coin2.mp3'],
      volume: 0.1,
      html: true
    });

    Square.prototype.flower_sound = new Howl({
      src: ['sounds/flower.mp3'],
      volume: 0.1,
      html5: true
    });

    Square.prototype.bump = function() {
      var coin, flower;
      this.already_bumped = true;
      if (this.contents === 'coin') {
        coin = new Coin([this.position[0], this.position[1] + 20]);
        creatures.push(coin);
        return this.coin_sound.play();
      } else if (this.contents === 'flower') {
        flower = new Flower([this.position[0], this.position[1] + 20]);
        creatures.push(flower);
        return this.flower_sound.play();
      }
    };

    return Square;

  })(this.Creature);

}).call(this);
