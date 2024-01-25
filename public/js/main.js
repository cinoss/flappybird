// Generated by CoffeeScript 1.7.1
var FPS, PipeManager, addMainView, background, bigbang, bird, birdView, building, cloud, config, flap, gameover, ground, handleComplete, handleFileLoad, handleKeyDown, handleKeyUp, handleProgress, handleTick, handler, highscoreText, highscoreTextOutline, init, intro, lastTime, loadAsset, loadQueue, main, muted, newHighscore, newLabel, pairContainer, pairs, pipeMan, play, renderBasic, renderDOM, renderShape, renderText, reset, scaleMatrix, scaleRatio, scorePanel, scorePanelContainer, scoreText, scoreTextOutline, scoreView, setupTicker, stage, startButton, startTime, status, theta;

FPS = 50;

muted = false;

startTime = 0;

lastTime = bigbang = 0;

config = null;

bird = null;

stage = null;

ground = new createjs.Shape;

building = new createjs.Shape;

cloud = new createjs.Shape;

background = new createjs.Shape;

pairs = [];

pairContainer = new createjs.Container;

birdView = null;

scoreView = null;

startButton = new createjs.Shape;

scorePanel = new createjs.Shape;

scorePanelContainer = new createjs.Container;

scoreText = null;

scoreTextOutline = null;

highscoreText = null;

highscoreTextOutline = null;

newLabel = new createjs.Container;

pipeMan = null;

scaleMatrix = null;

scaleRatio = 1;

loadQueue = new createjs.LoadQueue;

handler = {};

status = '';

newHighscore = false;

init = function(canvas) {
  var ratio;
  if (canvas.height > canvas.width * 4 / 3) {
    canvas.height = canvas.width * 4 / 3;
  }
  if (canvas.width > canvas.height * 2) {
    canvas.width = canvas.height * 2;
  }
  if (canvas.height > 640) {
    canvas.height -= 100;
  }
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
  config.startButton = {
    height: 29,
    width: 52
  };
  config.scorePanel = {
    height: 285 / 5,
    width: 565 / 5
  };
  config.pixel.size = canvas.height / (config.pipe.gap * 4.5);
  config.pixel.size = Math.round(config.pixel.size);
  config.stage.height = canvas.height / config.pixel.size;
  config.stage.width = canvas.width / config.pixel.size;
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
  config.stage.gapMax = 1.8 * config.pipe.gap;
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

loadAsset = function() {
  var manifest;
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
      src: '/img/start.gif',
      id: 'startButton'
    }, {
      src: '/img/score-panel.gif',
      id: 'scorePanel'
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
  return loadQueue.loadManifest(manifest);
};

main = function() {
  var canvas;
  canvas = document.getElementById('stage');
  canvas = document.createElement("canvas");
  canvas.height = Math.min($(window).height(), 5500) || 480;
  canvas.width = Math.min($(window).width(), 9000) || 640;
  console.log([canvas.height, canvas.width]);
  init(canvas);
  console.log([canvas.height, canvas.width]);
  console.log(12423523);
  $('#stage').append(canvas);
  $('#stage').height(canvas.height);
  console.log($('#stage').height());
  stage = new createjs.Stage(canvas);
  stage.mouseEnabled = true;
  createjs.Touch.enable(stage);
  loadAsset();
  renderText();
  setupTicker();
  stage.on('stagemousedown', handleKeyDown);
  $(document).on('keydown', handleKeyDown);
  return renderDOM();
};

setupTicker = function() {
  return createjs.Ticker.timingMode = createjs.Ticker.RAF;
};

handleKeyDown = function(e) {
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
  renderBasic();
  ground.y = config.stage.groundY * config.pixel.size;
  building.y = (config.stage.groundY - config.stage.buildingHeight) * config.pixel.size;
  cloud.y = (config.stage.groundY - config.stage.buildingHeight - config.stage.cloudHeight) * config.pixel.size + 1;
  scorePanelContainer.y = (config.stage.height - 2 * config.scorePanel.height) / 2 * config.pixel.size;
  scorePanelContainer.x = (config.stage.width - config.scorePanel.width) / 2 * config.pixel.size;
  startButton.y = (config.stage.height + config.scorePanel.height) / 2 * config.pixel.size;
  startButton.x = (config.stage.width - config.startButton.width) / 2 * config.pixel.size;
  startButton.on('click', intro);
  stage.addChild(background, building, cloud);
  for (_i = 0, _len = pairs.length; _i < _len; _i++) {
    pair = pairs[_i];
    pairContainer.addChild(pair);
    pair.x = -1000;
  }
  stage.addChild(pairContainer);
  birdView.y = -100;
  birdView.x = config.bird.screenX * config.pixel.size;
  stage.addChild(birdView);
  stage.addChild(ground);
  stage.setChildIndex(scoreView, 100);
  pipeMan = new PipeManager(.5 * config.stage.width, config.pipe.distance + config.pipe.width, pairs.slice());
  intro();
  stage.update();
};

PipeManager = (function() {
  function PipeManager(nextX, step, freePairs) {
    this.nextX = nextX;
    this.step = step;
    this.freePairs = freePairs;
    this.pipes = [];
    this.nextXsave = nextX;
  }

  PipeManager.prototype.reset = function() {
    while (this.pipes.length) {
      this.freePairs.push(this.pipes.pop().pair);
    }
    this.nextX = this.nextXsave;
  };

  PipeManager.prototype.genPipe = function() {
    var pipe, r;
    r = Math.round(Math.random() * 5) / 5;
    pipe = {
      y: r * config.stage.gapMax + (config.stage.height - config.stage.gapMax - config.pipe.gap) / 2,
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
    var pipe, reCache, _i, _len, _ref;
    reCache = false;
    while (this.freePairs.length > 0) {
      this.pipes.push(this.genPipe());
      reCache = true;
    }
    _ref = this.pipes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      pipe = _ref[_i];
      pipe.screenX = pipe.x - viewportX;
      if (reCache) {
        pipe.pair.x = Math.round((pipe.screenX - this.pipes[0].screenX) * config.pixel.size);
      }
    }
    pairContainer.x = Math.round(this.pipes[0].screenX * config.pixel.size);
    if (reCache) {
      pairContainer.cache(0, 0, this.pipes.length * this.step * config.pixel.size, config.stage.groundY * config.pixel.size);
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
          return false;
        }
      }
      if (bird.pos.y >= pipe.y + config.pipe.gap) {
        if (bird.pos.x <= pipe.x1 && bird.pos.x >= pipe.x0) {
          return false;
        }
      }
      if (bird.pos.x <= pipe.x + config.pipe.width && bird.pos.x >= pipe.x) {
        if (bird.pos.y < pipe.y0) {
          return false;
        }
        if (bird.pos.y > pipe.y1) {
          return false;
        }
      }
      if (pipe.score && bird.pos.x > pipe.x) {
        bird.score += pipe.score;
        pipe.score = 0;
      }
    }
    if (bird.pos.y >= config.stage.groundY - config.bird.effectiveRadius) {
      return false;
    }
    return true;
  };

  return PipeManager;

})();

theta = function(dx, dy) {
  var t;
  t = dy / (Math.abs(dx) + Math.abs(dy));
  t = (t + 1) / 2;
  t = createjs.Ease.getPowIn(2.4)(t);
  t = t * 2 - 1;
  if (t > 0) {
    return t * 90;
  } else {
    if (-t * 90 > 15) {
      return 360 - 15;
    } else {
      return 360 + t * 15;
    }
  }
};

handleTick = function() {
  var angle, currentTime, groundPosition, oldScore, score, t, wingState;
  currentTime = createjs.Ticker.getTime();
  switch (status) {
    case 'intro':
      t = (currentTime - bigbang) / 1000;
      wingState = Math.round((currentTime - bigbang) / 150) % 3;
      birdView.gotoAndStop(wingState);
      pipeMan.update(bird.pos.x - config.bird.screenX);
      bird.pos.y = bird.pos.y0 + Math.sin(t * 5) * config.bird.effectiveRadius;
      birdView.y = bird.pos.y * config.pixel.size;
      stage.update();
      break;
    case 'play':
      t = (currentTime - startTime) / 1000;
      $('#info').text([Math.round(createjs.Ticker.getMeasuredFPS()) + ' FPS']);
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
      birdView.y = Math.round(bird.pos.y * config.pixel.size);
      birdView.rotation = Math.round(angle);
      birdView.gotoAndStop(wingState);
      if (bird.alive) {
        groundPosition = -(currentTime - bigbang) / 1000 * (config.bird.v.x0 * config.pixel.size);
        ground.x = Math.round(groundPosition % (config.stage.groundTileWidth * config.pixel.size));
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
            startTime = createjs.Ticker.getTime();
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
      break;
    case 'gameover':
      score = Math.floor((currentTime - startTime) / 200);
      if (score <= bird.score) {
        scoreText.text = score;
        scoreTextOutline.text = score;
        stage.update();
      } else {
        stage.addChild(startButton);
        status = 'end';
        stage.update();
      }
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

reset = function() {
  createjs.Ticker.setPaused(true);
  newHighscore = false;
  lastTime = bigbang = createjs.Ticker.getTime();
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
  birdView.rotation = 0;
  pipeMan.reset();
  return createjs.Ticker.setPaused(false);
};

intro = function() {
  reset();
  $('#score').text(bird.score);
  $('#score').css('display', 'inherit');
  stage.removeChild(startButton, scorePanelContainer);
  handleTick();
  handler.touch = function() {
    flap();
    return play();
  };
  return status = 'intro';
};

play = function() {
  bigbang = createjs.Ticker.getTime();
  handler.touch = flap;
  startTime = createjs.Ticker.getTime();
  return status = 'play';
};

gameover = function() {
  handler.touch = null;
  startTime = createjs.Ticker.getTime();
  scorePanelContainer.removeChild(newLabel);
  stage.addChild(scorePanelContainer);
  $('#score').css('display', 'none');
  if (!$.cookie('hs')) {
    $.cookie('hs', 0);
  }
  if (bird.score > $.cookie('hs')) {
    $.cookie('hs', bird.score, {
      expires: 365
    });
    newHighscore = true;
    scorePanelContainer.addChild(newLabel);
  }
  highscoreText.text = $.cookie('hs');
  highscoreTextOutline.text = $.cookie('hs');
  return status = 'gameover';
};

flap = function() {
  if (bird.alive && bird.pos.y > config.bird.height / 2) {
    if (!muted) {
      createjs.Sound.play('flapSound');
    }
    handleTick();
    startTime = createjs.Ticker.getTime();
    bird.pos.y0 = bird.pos.y;
    bird.pos.x0 = bird.pos.x;
    return bird.v.y = config.bird.v.y0;
  }
};

renderShape = function(assetId, img) {
  var data, i, newLabelOutline, newLabelText, pair, pipeDown, pipeUp, spriteSheet, _i, _ref;
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
        framerate: 20,
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
      break;
    case 'startButton':
      startButton.graphics.beginBitmapFill(img, 'no-repeat', scaleMatrix);
      startButton.graphics.drawRect(0, 0, img.width * scaleRatio, img.height * scaleRatio);
      startButton.graphics.endFill();
      break;
    case 'scorePanel':
      scorePanel.graphics.beginBitmapFill(img, 'no-repeat', scaleMatrix);
      scorePanel.graphics.drawRect(0, 0, img.width * scaleRatio, img.height * scaleRatio);
      scorePanel.graphics.endFill();
      scorePanelContainer.addChild(scorePanel);
      scoreText = new createjs.Text("0", "" + (8 * config.pixel.size) + "px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "white");
      scoreTextOutline = new createjs.Text("0", "" + (8 * config.pixel.size) + "px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "black");
      scoreText.textAlign = 'right';
      scoreTextOutline.textAlign = 'right';
      scoreTextOutline.width = config.pixel.size * 150;
      scoreText.x = config.pixel.size * 102;
      scoreText.y = config.pixel.size * 19;
      scoreTextOutline.x = config.pixel.size * 102;
      scoreTextOutline.y = config.pixel.size * 19;
      scoreTextOutline.outline = 2 * config.pixel.size;
      highscoreText = new createjs.Text("0", "" + (8 * config.pixel.size) + "px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "white");
      highscoreTextOutline = new createjs.Text("0", "" + (8 * config.pixel.size) + "px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "black");
      highscoreText.textAlign = 'right';
      highscoreTextOutline.textAlign = 'right';
      highscoreTextOutline.width = config.pixel.size * 150;
      highscoreText.x = config.pixel.size * 102;
      highscoreText.y = config.pixel.size * 39;
      highscoreTextOutline.x = config.pixel.size * 102;
      highscoreTextOutline.y = config.pixel.size * 39;
      highscoreTextOutline.outline = 2 * config.pixel.size;
      newLabelText = new createjs.Text("NEW", "" + (8 * config.pixel.size) + "px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "white");
      newLabelText.x = config.pixel.size * 60;
      newLabelText.y = config.pixel.size * 39;
      newLabelOutline = new createjs.Text("NEW", "" + (8 * config.pixel.size) + "px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "red");
      newLabelOutline.x = config.pixel.size * 60;
      newLabelOutline.y = config.pixel.size * 39;
      newLabelOutline.outline = 2 * config.pixel.size;
      newLabel.addChild(newLabelOutline, newLabelText);
      scorePanelContainer.addChild(scoreTextOutline);
      scorePanelContainer.addChild(scoreText);
      scorePanelContainer.addChild(highscoreTextOutline);
      scorePanelContainer.addChild(highscoreText);
  }
};

renderText = function() {
  scoreView = new createjs.Text("Loading..", "20px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "#ff7700");
  scoreView.x = 100;
  return stage.addChild(scoreView);
};
