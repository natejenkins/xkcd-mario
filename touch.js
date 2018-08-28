$(document).ready(function() {
  var buttonUp     = document.querySelector('#button-up');
  var buttonDown   = document.querySelector('#button-down');
  var buttonLeft   = document.querySelector('#button-left');
  var buttonRight  = document.querySelector('#button-right');
  var buttonAction = document.querySelector('#button-action');
  var buttonBomb   = document.querySelector('#button-bomb');
  var canvas       = document.querySelector('#stickman-canvas')
  // var hammerUp     = createTapHammer(buttonUp)
  // var hammerDown   = createPressHammer(buttonDown);
  // var hammerLeft   = createPressHammer(buttonLeft)
  // var hammerRight  = createPressHammer(buttonRight)
  // var hammerAction = createTapHammer(buttonAction)
  // var hammerBomb   = createTapHammer(buttonBomb)

  buttonUp.addEventListener("touchstart",
    function(ev){
      ev.preventDefault()
      stickman.jump()
      setTimeout(function() {
        stickman.is_moving_up = false;
        stickman.is_trying_to_jump = false;
      }, 100)
    }, false);
  buttonUp.addEventListener("touchend",
    function(ev){
      ev.preventDefault()
      stickman.is_moving_up = false;
      stickman.is_trying_to_jump = false;
    }, false);

  buttonAction.addEventListener("touchstart",
    function(ev){
      ev.preventDefault()
      stickman.throw_fireball()
    }, false);
  buttonBomb.addEventListener("touchstart",
    function(ev){
      ev.preventDefault()
      stickman.throw_bomb()
    }, false);

  buttonLeft.addEventListener("touchstart",
    function(ev){
      ev.preventDefault()
      stickman.moveLeft()
    }, false);
  buttonLeft.addEventListener("touchend",
    function(ev){
      ev.preventDefault()
      stickman.is_moving_left = false;
    }, false);
  buttonRight.addEventListener("touchstart",
    function(ev){
      ev.preventDefault()
      stickman.moveRight()
    }, false);
  buttonRight.addEventListener("touchend",
    function(ev){
      ev.preventDefault()
      stickman.is_moving_right = false;
    }, false);
  buttonDown.addEventListener("touchstart",
    function(ev){
      ev.preventDefault()
      stickman.duck()
    }, false);
  buttonDown.addEventListener("touchend",
    function(ev){
      ev.preventDefault()
      stickman.is_moving_down = false;
    }, false);

  canvas.addEventListener("touchstart",
    function(ev){
      ev.preventDefault()
    }, false);
  canvas.addEventListener("touchend",
    function(ev){
      ev.preventDefault()
    }, false);

})
