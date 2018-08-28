(function() {

  this.init = function() {
    var scale;
    this.image = $('<img src="test.png" style="top:0px;left:0px;" z-index: -1; position: absolute;" style="display:none" />');
    scale = 0.5;
    $('#images').append(image);
    this.original_width = this.image.width();
    this.original_height = this.image.height();
    image.width(8);
    image.height(8);
    this.canvas = document.createElement("canvas");
    this.canvas.width = original_width * scale;
    this.canvas.height = original_height * scale;
    this.context = this.canvas.getContext("2d");
    this.context.scale(scale, scale);
    this.context.drawImage(image[0], 0, 0);
    return this.image_data = context.getImageData(0, 0, this.original_width * scale, this.original_height * scale);
  };

  this.printColors = function() {
    var b, g, r, str, x, xrange, y, yrange, _i, _j, _k, _l, _len, _len2, _ref, _ref2, _results, _results2;
    xrange = (function() {
      _results = [];
      for (var _i = 0, _ref = image_data.width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this);
    yrange = (function() {
      _results2 = [];
      for (var _j = 0, _ref2 = image_data.height - 1; 0 <= _ref2 ? _j <= _ref2 : _j >= _ref2; 0 <= _ref2 ? _j++ : _j--){ _results2.push(_j); }
      return _results2;
    }).apply(this);
    str = '';
    for (_k = 0, _len = xrange.length; _k < _len; _k++) {
      x = xrange[_k];
      for (_l = 0, _len2 = yrange.length; _l < _len2; _l++) {
        y = yrange[_l];
        r = image_data.data[((y * (image_data.width * 4)) + (x * 4)) + 0];
        g = image_data.data[((y * (image_data.width * 4)) + (x * 4)) + 1];
        b = image_data.data[((y * (image_data.width * 4)) + (x * 4)) + 2];
        str += [r, g, b] + ' ';
      }
      str += "\n";
    }
    return console.info(str);
  };

  jQuery(function() {
    init();
    return printColors();
  });

}).call(this);
