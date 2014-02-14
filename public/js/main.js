// Generated by CoffeeScript 1.7.1
var FPS, PipeManager, addMainView, background, bigbang, bird, birdView, building, cloud, config, flap, gameover, ground, handleComplete, handleFileLoad, handleKeyDown, handleKeyUp, handleProgress, handleTick, handler, init, intro, lastTime, loadQueue, main, muted, pairs, pipeMan, play, renderBasic, renderDOM, renderShape, scaleMatrix, scaleRatio, stage, startTime, status, theta,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

FPS = 60;

muted = false;

startTime = 0;

lastTime = bigbang = (new Date()).getTime();

config = null;

bird = null;

stage = null;

ground = new createjs.Shape;

building = new createjs.Shape;

cloud = new createjs.Shape;

background = new createjs.Shape;

pairs = [];

birdView = null;

pipeMan = null;

scaleMatrix = null;

scaleRatio = 1;

loadQueue = new createjs.LoadQueue;

handler = {};

status = '';

init = function() {
  var ratio;
  config = {};
  config.pixel = {
    size: 3,
    originalSize: 5
  };
  config.pipe = {
    distance: 56,
    gap: 51,
    width: 26,
    topHeight: 11,
    imgHeight: 140
  };
  config.stage = {
    g: 500,
    groundTileWidth: 12,
    buildingHeight: 33,
    cloudHeight: 13,
    height: config.pipe.gap * 4.5
  };
  config.pixel.size = stage.canvas.height / (config.pipe.gap * 4.5);
  config.pixel.size = Math.floor(config.pixel.size * 2) / 2;
  config.stage.height = stage.canvas.height / config.pixel.size;
  config.stage.width = stage.canvas.width / config.pixel.size;
  console.log([stage.canvas.height, config.pipe.gap * 4.5]);
  console.log(['pixel', config.pixel.size]);
  config.pipe.num = Math.round(config.stage.width / (config.pipe.distance + config.pipe.width));
  config.bird = {
    size: 21,
    height: 16,
    width: 21,
    effectiveRadius: 12 / 2,
    screenX: config.stage.width / 3,
    v: {
      x0: 80,
      y0: -180
    }
  };
  config.stage.gapMax = 2 * config.pipe.gap;
  config.stage.groundY = config.stage.gapMax + (config.stage.height - config.stage.gapMax - config.pipe.gap) / 2 + config.pipe.gap + 2 * config.pipe.topHeight;
  ratio = 1;
  config.stage.g = 650 * ratio;
  config.bird.v.x0 = 60 * ratio;
  config.bird.v.x0 = config.pipe.distance * 1.2 * ratio;
  config.bird.v.y0 = -195;
  bird = {};
  bird.alive = true;
  bird.score = 0;
  bird.pos = {
    x: 0,
    x0: 0,
    y0: config.stage.height / 2,
    y: config.stage.height / 2
  };
  bird.v = {
    x: config.bird.v.x0,
    y: 0
  };
  scaleRatio = config.pixel.size / config.pixel.originalSize;
  scaleMatrix = new createjs.Matrix2D;
  return scaleMatrix.scale(scaleRatio, scaleRatio);
};

main = function() {
  var canvas, manifest;
  canvas = document.getElementById('stage');
  canvas = document.createElement("canvas");
  canvas.height = Math.min($(window).height(), 5500) || 480;
  canvas.width = Math.min($(window).width(), 9000) || 640;
  canvas.height *= 3 / 4;
  canvas.height = Math.max(canvas.height, 720);
  if (canvas.width > canvas.height * 2) {
    canvas.width = Math.round(canvas.height * 2);
  }
  $('#stage').append(canvas);
  $('#stage').height(canvas.height);
  console.log(['window', $(window).height(), $(window).width()]);
  stage = new createjs.Stage(canvas);
  stage.mouseEventsEnabled = true;
  init();
  manifest = [
    {
      src: '/img/floor.jpg',
      id: 'groundTile'
    }, {
      src: '/img/buildings.jpg',
      id: 'buildingTile'
    }, {
      src: '/img/clouds.jpg',
      id: 'cloudTile'
    }, {
      src: '/img/pipe.gif',
      id: 'pipeTile'
    }, {
      src: '/img/birds.gif',
      id: 'birdSeq'
    }, {
      src: '/audio/flap.mp3',
      id: 'flapSound'
    }, {
      src: '/audio/hit.mp3',
      id: 'hitSound'
    }, {
      src: '/audio/fall.mp3',
      id: 'fallSound'
    }, {
      src: '/audio/score.mp3',
      id: 'scoreSound'
    }
  ];
  loadQueue.installPlugin(createjs.Sound);
  loadQueue.on('complete', handleComplete);
  loadQueue.on('fileload', handleFileLoad);
  loadQueue.loadManifest(manifest);
  createjs.Ticker.timingMode = createjs.Ticker.RAF_SYNCHED;
  createjs.Ticker.setFPS(FPS);
  if ((__indexOf.call(document.documentElement, 'ontouchstart') >= 0)) {
    console.log(1);
    canvas.addEventListener('touchstart', function(e) {
      return handleKeyDown();
    }, false);
    canvas.addEventListener('touchend', function(e) {
      return handleKeyUp();
    }, false);
  } else {
    console.log(2);
    document.onkeydown = handleKeyDown;
    document.onkeyup = handleKeyUp;
    if (window.navigator.msPointerEnabled) {
      document.getElementById('body').addEventListener("MSPointerDown", handleKeyDown, false);
      document.getElementById('body').addEventListener("MSPointerUp", handleKeyUp, false);
    } else {
      document.onmousedown = handleKeyDown;
      document.onmouseup = handleKeyUp;
    }
  }
  return renderDOM();
};

handleKeyDown = function() {
  console.log('touch');
  if (handler.touch) {
    handler.touch();
  }
};

handleKeyUp = function() {};

handleProgress = function(event) {};

handleComplete = function(event) {
  addMainView();
};

handleFileLoad = function(event) {
  switch (event.item.type) {
    case createjs.LoadQueue.IMAGE:
      return renderShape(event.item.id, event.result);
    case createjs.LoadQueue.SOUND:
      return createjs.Sound.registerSound(event.result, event.result.id);
  }
};

addMainView = function() {
  var pair, _i, _len;
  createjs.Ticker.addEventListener("tick", handleTick);
  intro();
  console.log('---- main -----');
  renderBasic();
  ground.y = config.stage.groundY * config.pixel.size;
  building.y = (config.stage.groundY - config.stage.buildingHeight) * config.pixel.size;
  cloud.y = (config.stage.groundY - config.stage.buildingHeight - config.stage.cloudHeight) * config.pixel.size + 1;
  stage.addChild(background, building, cloud);
  for (_i = 0, _len = pairs.length; _i < _len; _i++) {
    pair = pairs[_i];
    pair.y = Math.random() * 400;
    stage.addChild(pair);
    pair.x = -1000;
  }
  birdView.y = -100;
  birdView.x = config.bird.screenX * config.pixel.size;
  stage.addChild(birdView);
  stage.addChild(ground);
  stage.update();
};

PipeManager = (function() {
  function PipeManager(nextX, step, freePairs) {
    this.nextX = nextX;
    this.step = step;
    this.freePairs = freePairs;
    this.pipes = [];
  }

  PipeManager.prototype.genPipe = function() {
    var pipe;
    pipe = {
      y: (Math.random()) * config.stage.gapMax + (config.stage.height - config.stage.gapMax - config.pipe.gap) / 2,
      x: this.nextX,
      score: 1,
      pair: this.freePairs.pop()
    };
    pipe.pair.y = pipe.y * config.pixel.size;
    pipe.x1 = pipe.x + config.pipe.width + config.bird.effectiveRadius;
    pipe.x0 = pipe.x - config.bird.effectiveRadius;
    pipe.y0 = pipe.y + config.bird.effectiveRadius;
    pipe.y1 = pipe.y + config.pipe.gap - config.bird.effectiveRadius;
    this.nextX += this.step;
    return pipe;
  };

  PipeManager.prototype.update = function(viewportX) {
    var pipe, _i, _len, _ref;
    while (this.freePairs.length > 0) {
      this.pipes.push(this.genPipe());
    }
    _ref = this.pipes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      pipe = _ref[_i];
      pipe.screenX = pipe.x - viewportX;
      pipe.pair.x = pipe.screenX * config.pixel.size;
    }
    while (this.pipes.length > 0 && this.pipes[0].screenX < -config.pipe.width) {
      this.freePairs.push(this.pipes[0].pair);
      this.pipes.shift();
      break;
    }
  };

  PipeManager.prototype.checkBird = function() {
    var pipe, _i, _len, _ref;
    _ref = this.pipes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      pipe = _ref[_i];
      if (bird.pos.x < pipe.x0 || bird.pos.x > pipe.x1) {
        continue;
      }
      if (bird.pos.y <= pipe.y) {
        if (bird.pos.x <= pipe.x1 && bird.pos.x >= pipe.x0) {
          console.log('hit 1');
          return false;
        }
      }
      if (bird.pos.y >= pipe.y + config.pipe.gap) {
        if (bird.pos.x <= pipe.x1 && bird.pos.x >= pipe.x0) {
          console.log('hit 2');
          return false;
        }
      }
      if (bird.pos.x <= pipe.x + config.pipe.width && bird.pos.x >= pipe.x) {
        if (bird.pos.y < pipe.y0) {
          console.log('hit 3');
          return false;
        }
        if (bird.pos.y > pipe.y1) {
          console.log('hit 4');
          return false;
        }
      }
      if (pipe.score && bird.pos.x > pipe.x) {
        bird.score += pipe.score;
        pipe.score = 0;
      }
    }
    if (bird.pos.y >= config.stage.groundY - config.bird.effectiveRadius) {
      console.log('hit-ground');
      return false;
    }
    return true;
  };

  return PipeManager;

})();

theta = function(dx, dy) {
  var t;
  t = dy / (Math.abs(dx) + Math.abs(dy));
  if (t > 0) {
    return t * 90;
  } else {
    return 360 + t * 15;
  }
};

handleTick = function() {
  var angle, currentTime, groundPosition, oldScore, t, wingState;
  currentTime = (new Date()).getTime();
  switch (status) {
    case 'intro':
      t = (currentTime - bigbang) / 1000;
      groundPosition = -(currentTime - bigbang) / 1000 * (config.bird.v.x0 * config.pixel.size);
      ground.x = groundPosition % (config.stage.groundTileWidth * config.pixel.size);
      wingState = Math.round((currentTime - bigbang) / 150) % 3;
      birdView.gotoAndStop(wingState);
      bird.pos.y = bird.pos.y0 + Math.sin(t * 5) * config.bird.effectiveRadius;
      birdView.y = bird.pos.y * config.pixel.size;
      stage.update();
      break;
    case 'play':
      t = (currentTime - startTime) / 1000;
      console.log(Math.round(1000 / (currentTime - lastTime)) + 'fps');
      lastTime = currentTime;
      bird.pos.y = bird.pos.y0 + bird.v.y * t + 0.5 * config.stage.g * Math.pow(t, 2);
      if (bird.pos.y > config.stage.groundY - config.bird.effectiveRadius) {
        bird.pos.y = config.stage.groundY - config.bird.effectiveRadius;
      }
      bird.pos.x = bird.pos.x0 + bird.v.x * t;
      angle = theta(bird.v.x, bird.v.y + t * config.stage.g);
      if (angle < 180 && angle > 44) {
        wingState = 1;
      } else {
        wingState = Math.round((currentTime - bigbang) / 60) % 3;
      }
      birdView.y = bird.pos.y * config.pixel.size;
      birdView.rotation = angle;
      birdView.gotoAndStop(wingState);
      if (bird.alive) {
        groundPosition = -(currentTime - bigbang) / 1000 * (config.bird.v.x0 * config.pixel.size);
        ground.x = groundPosition % (config.stage.groundTileWidth * config.pixel.size);
        pipeMan.update(bird.pos.x - config.bird.screenX);
        oldScore = bird.score;
        if (!pipeMan.checkBird()) {
          if (!muted) {
            createjs.Sound.play('hitSound');
          }
          bird.alive = false;
          if (bird.pos.y < config.stage.groundY - config.bird.effectiveRadius) {
            if (!muted) {
              createjs.Sound.play('fallSound');
            }
            startTime = (new Date()).getTime();
            bird.v.x = 0;
            bird.pos.y0 = bird.pos.y;
            bird.pos.x0 = bird.pos.x;
            bird.v.y = config.bird.v.y0 / 2;
          } else {
            gameover();
          }
        }
        if (oldScore < bird.score) {
          $('#score').text(bird.score);
          if (!muted) {
            createjs.Sound.play('scoreSound');
          }
        }
      } else if (bird.pos.y >= config.stage.groundY - config.bird.effectiveRadius) {
        if (!muted) {
          createjs.Sound.play('hitSound');
        }
        gameover();
      }
      stage.update();
  }
};

renderBasic = function() {
  background.graphics.beginFill('#4ac3ce');
  background.graphics.drawRect(0, 0, stage.canvas.width, stage.canvas.height);
  background.graphics.endFill();
};

renderDOM = function() {
  var z;
  $('#score').css('width', (config.stage.width * config.pixel.size) + 'px');
  $('#score').css('top', ((config.stage.height - config.stage.groundY) * config.pixel.size) + 'px');
  $('#score').css('font-size', config.bird.size * config.pixel.size);
  $('#score').text('loading..');
  z = config.pixel.size;
  return $('#score').css('text-shadow', "" + z + "px " + z + "px 0 #000");
};

intro = function() {
  $('#score').text(bird.score);
  status = 'intro';
  return handler.touch = function() {
    flap();
    return play();
  };
};

play = function() {
  console.log('play');
  handler.touch = flap;
  startTime = (new Date()).getTime();
  pipeMan = new PipeManager(1 * config.stage.width, config.pipe.distance + config.pipe.width, pairs.slice());
  return status = 'play';
};

gameover = function() {
  return status = 'gameover';
};

flap = function() {
  if (bird.alive && bird.pos.y > config.bird.height / 2) {
    if (!muted) {
      createjs.Sound.play('flapSound');
    }
    handleTick();
    startTime = (new Date()).getTime();
    bird.pos.y0 = bird.pos.y;
    bird.pos.x0 = bird.pos.x;
    return bird.v.y = config.bird.v.y0;
  }
};

renderShape = function(assetId, img) {
  var data, i, pair, pipeDown, pipeUp, spriteSheet, _i, _ref;
  switch (assetId) {
    case 'groundTile':
      ground.graphics.beginFill('#dedb94');
      ground.graphics.drawRect(0, 0, 2 * config.pixel.originalSize * config.stage.width, (config.stage.height - config.stage.groundY) * config.pixel.originalSize);
      ground.graphics.endFill();
      ground.graphics.beginBitmapFill(img, 'repeat', scaleMatrix);
      ground.graphics.drawRect(0, 0, config.pixel.size * config.stage.width + img.width * scaleRatio, img.height * scaleRatio);
      ground.graphics.endFill();
      ground.cache(0, 0, 2 * config.pixel.originalSize * config.stage.width, (config.stage.height - config.stage.groundY) * config.pixel.originalSize);
      break;
    case 'buildingTile':
      building.graphics.beginBitmapFill(img, 'repeat', scaleMatrix);
      building.graphics.drawRect(0, 0, config.pixel.size * config.stage.width, img.height * scaleRatio);
      building.graphics.endFill();
      building.cache(0, 0, config.pixel.size * config.stage.width, img.height * scaleRatio);
      break;
    case 'cloudTile':
      cloud.graphics.beginBitmapFill(img, 'repeat', scaleMatrix);
      cloud.graphics.drawRect(0, 0, config.pixel.size * config.stage.width, img.height * scaleRatio);
      cloud.graphics.endFill();
      cloud.cache(0, 0, config.pixel.size * config.stage.width, img.height * scaleRatio);
      break;
    case 'pipeTile':
      for (i = _i = 0, _ref = config.pipe.num; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        pair = new createjs.Container;
        pipeUp = new createjs.Shape;
        pipeUp.scaleY = pipeUp.scaleX = scaleRatio;
        pipeUp.graphics.beginBitmapFill(img);
        pipeUp.graphics.drawRect(0, 0, img.width, img.height);
        pipeUp.graphics.endFill();
        pipeUp.y = config.pipe.gap * config.pixel.size;
        pipeDown = new createjs.Shape;
        pipeDown.scaleY = -scaleRatio;
        pipeDown.scaleX = scaleRatio;
        pipeDown.graphics.beginBitmapFill(img);
        pipeDown.graphics.drawRect(0, 0, img.width, img.height);
        pipeDown.graphics.endFill();
        pair.addChild(pipeUp, pipeDown);
        pair.cache(0, -img.height * scaleRatio, img.width * scaleRatio, 2 * img.height * scaleRatio + config.pipe.gap * config.pixel.size);
        pairs.push(pair);
      }
      break;
    case 'birdSeq':
      data = {
        images: [img],
        frames: {
          width: config.bird.width * config.pixel.originalSize,
          height: config.bird.height * config.pixel.originalSize,
          regX: config.bird.width * config.pixel.originalSize / 2,
          regY: config.bird.height * config.pixel.originalSize / 2,
          count: 3
        },
        animations: {
          run: [0, 2]
        }
      };
      spriteSheet = new createjs.SpriteSheet(data);
      birdView = new createjs.Sprite(spriteSheet);
      birdView.stop();
      birdView.scaleY = birdView.scaleX = scaleRatio;
  }
};
