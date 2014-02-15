FPS = 50

muted = false

startTime = 0
lastTime = bigbang = 0

# mainView = new Container
config = null
bird = null

stage = null
ground = new createjs.Shape
building = new createjs.Shape
cloud = new createjs.Shape 
background = new createjs.Shape
pairs = []
pairContainer = new createjs.Container
birdView = null

scoreView = null
startButton = new createjs.Shape
scorePanel = new createjs.Shape
scorePanelContainer = new createjs.Container

scoreText = null
scoreTextOutline = null
highscoreText = null
highscoreTextOutline = null
newLabel = new createjs.Container

pipeMan = null



scaleMatrix = null 
scaleRatio = 1

loadQueue = new createjs.LoadQueue;

handler = {}
status = ''

newHighscore = false

init = () ->
	config = {}
	config.pixel =
		size : 3
		originalSize : 5
	config.pipe =
		distance : 56
		gap : 51
		width : 26
		topHeight : 11
		imgHeight : 140
	config.stage =
		g : 500
		groundTileWidth : 12
		buildingHeight : 33
		cloudHeight : 13
		height : config.pipe.gap * 4.5
		# width : (config.pipe.distance + config.pipe.width) * 2
		# height : stage.canvas.height/config.pixel.size
		# width : stage.canvas.width/config.pixel.size
	config.startButton =
		height : 29
		width : 52
	config.scorePanel = 
		height: 285/5
		width: 565/5
	config.pixel.size   = (stage.canvas.height/(config.pipe.gap * 4))
	config.pixel.size   = Math.floor(config.pixel.size)
	config.stage.height = stage.canvas.height/config.pixel.size
	config.stage.width  = stage.canvas.width/config.pixel.size
	config.pipe.num     = Math.round(config.stage.width / (config.pipe.distance + config.pipe.width) ) 
	# config.pipe.num = 1
	config.bird =
		size : 21
		height : 16
		width : 21
		effectiveRadius : 12/2
		# screenX : Math.min(config.pipe.distance + config.pipe.width, config.stage.width/3)
		screenX : (config.stage.width/3)
		v : 
			x0 : 80
			y0 : -180
	config.stage.gapMax  = 1.8 * config.pipe.gap
	config.stage.groundY = config.stage.gapMax + (config.stage.height - config.stage.gapMax - config.pipe.gap)/2 + config.pipe.gap + 2 * config.pipe.topHeight

	#config for speed
	ratio            = 1
	config.stage.g   = 650 * ratio
	config.bird.v.x0 = 60 * ratio
	config.bird.v.x0 = config.pipe.distance * 1.2* ratio
	config.bird.v.y0 = -195
	bird             = {}
	bird.alive       = true
	bird.score       = 0
	bird.pos         =
		x : 0
		x0 : 0
		y0 : config.stage.height/2
		y : config.stage.height/2
	bird.v =
		x : config.bird.v.x0
		y : 0

	scaleRatio = config.pixel.size/config.pixel.originalSize
	scaleMatrix = new createjs.Matrix2D
	scaleMatrix.scale(scaleRatio,scaleRatio)
	# ground.scaleY = ground.scaleX = scaleRatio
	# building.scaleY = building.scaleX = scaleRatio
	# cloud.scaleY = cloud.scaleX = scaleRatio
loadAsset = () ->
	manifest = [
		{ src: '/img/floor.jpg', 	id: 'groundTile'},
		{ src: '/img/buildings.jpg', 	id: 'buildingTile'},
		{ src: '/img/clouds.jpg', 	id: 'cloudTile'},
		{ src: '/img/pipe.gif', 	id: 'pipeTile'},
		{ src: '/img/birds.gif', 	id: 'birdSeq'},
		{ src: '/img/start.gif', 	id: 'startButton'},
		{ src: '/img/score-panel.gif', 	id: 'scorePanel'},
		
		{ src: '/audio/flap.mp3', 	id: 'flapSound'},
		{ src: '/audio/hit.mp3', 	id: 'hitSound'},
		{ src: '/audio/fall.mp3', 	id: 'fallSound'},
		{ src: '/audio/score.mp3', 	id: 'scoreSound'},
	]

	loadQueue.installPlugin(createjs.Sound)
	# loadQueue.onProgress = handleProgress
	loadQueue.on('complete', handleComplete)
	loadQueue.on('fileload', handleFileLoad);
	loadQueue.loadManifest(manifest)
main = () ->
	canvas        = document.getElementById('stage')
	canvas        = document.createElement("canvas");
	canvas.height = Math.min($(window).height(),5500) || 480;
	canvas.width  = Math.min($(window).width(),9000) || 640;
	canvas.height *= 3/4
	canvas.height = Math.max(canvas.height,640)
	# if canvas.width > canvas.height * 2
	# 	canvas.width = Math.round(canvas.height * 2)
	# if canvas.width > 550
	# 	canvas.width = 550
	$('#stage').append(canvas);
	$('#stage').height(canvas.height)


	stage              = new createjs.Stage(canvas)
	stage.mouseEnabled = true
	createjs.Touch.enable stage
	
	init()

	# Set The Flash Plugin for browsers that dont support SoundJS
	# createjs.SoundJS.FlashPlugin.BASE_PATH = "assets/"
	# if !createjs.SoundJS.checkPlugin(true)
	# 	alert "Error!"
	# 	return
	

	loadAsset()
	renderText()
	setupTicker()

	stage.on 'stagemousedown', handleKeyDown
	$(document).on 'keydown', handleKeyDown
	renderDOM()
setupTicker = () ->
	createjs.Ticker.timingMode = createjs.Ticker.RAF;

handleKeyDown = (e) ->
	# e.preventDefault()
	if handler.touch
		handler.touch()
	return
handleKeyUp = () ->
	return
handleProgress = (event) ->
	return
handleComplete = (event) ->
	# renderShape 'groundTile', loadQueue.getResult('groundTile')
	# renderShape 'buildingTile', loadQueue.getResult('buildingTile')
	# renderShape 'cloudTile', loadQueue.getResult('cloudTile')
	# renderShape 'pipeTile', loadQueue.getResult('pipeTile')
	# renderShape 'birdSeq', loadQueue.getResult('birdSeq')
	addMainView()
	return
handleFileLoad = (event) ->
	switch event.item.type
		when createjs.LoadQueue.IMAGE
			renderShape event.item.id, event.result
		when createjs.LoadQueue.SOUND
			createjs.Sound.registerSound(event.result, event.result.id);
		# 	handleLoadComplete()
addMainView = ()->
	createjs.Ticker.addEventListener("tick", handleTick);
	renderBasic()
	ground.y              = config.stage.groundY * config.pixel.size
	building.y            = (config.stage.groundY-config.stage.buildingHeight) * config.pixel.size
	cloud.y               = (config.stage.groundY-config.stage.buildingHeight-config.stage.cloudHeight) * config.pixel.size + 1
	
	scorePanelContainer.y = (config.stage.height - 2*config.scorePanel.height)/2 * config.pixel.size
	scorePanelContainer.x = (config.stage.width - config.scorePanel.width)/2 * config.pixel.size
	
	startButton.y         = (config.stage.height + config.scorePanel.height)/2 * config.pixel.size
	startButton.x         = (config.stage.width - config.startButton.width)/2 * config.pixel.size
	startButton.on 'click', intro



	stage.addChild background, building, cloud
	for pair in pairs
		# pair.y = Math.random() * 400
		pairContainer.addChild pair
		pair.x = -1000
		# break
	stage.addChild pairContainer
	birdView.y = -100;
	birdView.x = (config.bird.screenX) * config.pixel.size
	stage.addChild birdView
	stage.addChild ground


	stage.setChildIndex scoreView, 100

	pipeMan = new PipeManager .5*(config.stage.width), config.pipe.distance+config.pipe.width, pairs.slice()
	intro()
	stage.update();
	return
class PipeManager
	constructor: (@nextX, @step, @freePairs) ->
		@pipes = []
		@nextXsave = nextX
	reset : () ->
		while @pipes.length
			@freePairs.push @pipes.pop().pair
		@nextX = @nextXsave
		return
	genPipe : () ->
		r    = Math.round((Math.random() * 5))/5
		pipe =
			y    : r*config.stage.gapMax + (config.stage.height - config.stage.gapMax - config.pipe.gap)/2
			x    : @nextX
			score: 1
			pair : @freePairs.pop()
		# $("##{pipe.pair.id}").css('top',(pipe.y+(config.stage.height-config.stage.gapMax-config.pipe.gap)/2)*config.pixel.size )
		pipe.pair.y = (pipe.y)*config.pixel.size
		pipe.x1     = pipe.x + config.pipe.width + config.bird.effectiveRadius
		pipe.x0     = pipe.x - config.bird.effectiveRadius
		pipe.y0     = pipe.y + config.bird.effectiveRadius
		pipe.y1     = pipe.y + config.pipe.gap - config.bird.effectiveRadius	
		@nextX      += @step
		return pipe
	update : (viewportX) ->
		reCache = false
		while @freePairs.length > 0
			@pipes.push @genPipe()
			reCache = true
		for pipe in @pipes
			pipe.screenX = pipe.x - viewportX
			if reCache
				pipe.pair.x = Math.round((pipe.screenX - @pipes[0].screenX)*config.pixel.size)
		pairContainer.x =  Math.round(@pipes[0].screenX * config.pixel.size)
		if reCache
			pairContainer.cache 0, 0, @pipes.length * @step * config.pixel.size, config.stage.groundY * config.pixel.size

		while @pipes.length > 0 and @pipes[0].screenX < -config.pipe.width
			@freePairs.push @pipes[0].pair
			@pipes.shift()
			break

		return
	checkBird : () ->
		for pipe in @pipes
			if bird.pos.x < pipe.x0 or bird.pos.x> pipe.x1
				continue
			# top pipe
			if bird.pos.y <= pipe.y
				if bird.pos.x <= pipe.x1 and bird.pos.x >= pipe.x0
					return false
			# bottom pipe
			if bird.pos.y >= pipe.y + config.pipe.gap
				if bird.pos.x <= pipe.x1 and bird.pos.x >= pipe.x0
					return false
			#middle
			if bird.pos.x <= pipe.x + config.pipe.width and bird.pos.x >= pipe.x
				if bird.pos.y < pipe.y0
					return false 
				if bird.pos.y > pipe.y1
					return false 
			if pipe.score and bird.pos.x > pipe.x
				bird.score += pipe.score
				pipe.score = 0
		if bird.pos.y >= config.stage.groundY - config.bird.effectiveRadius
			return false
		return true
theta = (dx,dy)->
	t = dy/(Math.abs(dx)+Math.abs(dy))
	# t = t*4-3
	# if t<0
	# 	t = t/7
	# else
	# 	t = t/1

	t = (t+1) / 2
	t = createjs.Ease.getPowIn(2.4)(t)
	t = t*2-1

	# t = Math.atan2(dy,dx)/(2*Math.PI)
	if t>0
		return t * 90
	else 
		if -t*90 > 15
			return 360 - 15
		else
			return 360 + t * 15

handleTick = () ->
	currentTime = createjs.Ticker.getTime()
	switch status
		when 'intro'
			t = (currentTime - bigbang)/1000

			# groundPosition = -(currentTime-bigbang)/1000 * (config.bird.v.x0*config.pixel.size)
			# ground.x = groundPosition % (config.stage.groundTileWidth * config.pixel.size)

			# buildingState = -(currentTime-bigbang)/1000 * (config.bird.v.x0*config.pixel.size)/4
			# $('#buildings').css 'background-position', buildingState+"px 0px"
			# $('#clouds').css 'background-position', buildingState+"px 0px"

			wingState = Math.round((currentTime-bigbang)/150)%3
			birdView.gotoAndStop(wingState)
			pipeMan.update(bird.pos.x - config.bird.screenX)
			# $('#bird').css 'background-position', "0px #{wingState*config.bird.height*config.pixel.size}px"


			bird.pos.y = bird.pos.y0 + Math.sin(t*5)*config.bird.effectiveRadius
			birdView.y = (bird.pos.y)* config.pixel.size
			stage.update()
		when 'play'
			t = (currentTime - startTime)/1000

			$('#info').text [
				Math.round(createjs.Ticker.getMeasuredFPS())+'FPS'
				# ,Math.round(createjs.Ticker.getMeasuredTickTime(1))
			]
			lastTime = currentTime
			bird.pos.y = bird.pos.y0 + bird.v.y * t + 0.5 * config.stage.g * Math.pow(t, 2)
			if bird.pos.y > config.stage.groundY - config.bird.effectiveRadius
				bird.pos.y = config.stage.groundY - config.bird.effectiveRadius
			bird.pos.x = bird.pos.x0 + bird.v.x * t
			# update bird view
			angle =  theta(bird.v.x, bird.v.y + t *config.stage.g)
			if angle < 180 and angle > 44
				wingState = 1
			else
				wingState = Math.round((currentTime-bigbang)/60)%3

			birdView.y = Math.round(bird.pos.y * config.pixel.size)
			birdView.rotation = Math.round(angle)
			birdView.gotoAndStop(wingState)

			if bird.alive
				groundPosition = -(currentTime-bigbang)/1000 * (config.bird.v.x0*config.pixel.size)
				ground.x = Math.round(groundPosition % (config.stage.groundTileWidth * config.pixel.size))
				pipeMan.update(bird.pos.x - config.bird.screenX)

				oldScore = bird.score
				unless pipeMan.checkBird()
					createjs.Sound.play('hitSound') unless muted
					bird.alive = false
					if bird.pos.y < config.stage.groundY - config.bird.effectiveRadius
						createjs.Sound.play('fallSound') unless muted
						startTime   = createjs.Ticker.getTime()
						bird.v.x    = 0
						bird.pos.y0 = bird.pos.y
						bird.pos.x0 = bird.pos.x
						bird.v.y    = config.bird.v.y0/2
					else
						gameover()
				if oldScore < bird.score
					$('#score').text(bird.score);
					createjs.Sound.play('scoreSound') unless muted
			else if bird.pos.y >= config.stage.groundY - config.bird.effectiveRadius
				createjs.Sound.play('hitSound') unless muted
				gameover()
			stage.update()
		when 'gameover'
			score = Math.floor (currentTime-startTime)/200
			if score <= bird.score
				scoreText.text        = score
				scoreTextOutline.text = score
				stage.update()
			else
				stage.addChild startButton
				status = 'end'
				stage.update()

		
	return

renderBasic = () ->
	background.graphics.beginFill '#4ac3ce'
	# background.graphics.beginFill 'red'
	background.graphics.drawRect 0, 0, stage.canvas.width, stage.canvas.height
	background.graphics.endFill()
	return
renderDOM = () ->
	# $('#start').css 'width',(config.startButton.width * config.pixel.size)+'px'
	# $('#start').css 'height',(config.startButton.height * config.pixel.size)+'px'
	# $('#start').css 'background-size',(config.startButton.width * config.pixel.size)+'px '+(config.startButton.height * config.pixel.size)+'px'


	$('#score').css('width',(config.stage.width * config.pixel.size)+'px')
	$('#score').css('top',((config.stage.height-config.stage.groundY) * config.pixel.size)+'px')
	$('#score').css('font-size',config.bird.size * config.pixel.size)
	$('#score').text 'loading..'
	z = config.pixel.size
	$('#score').css('text-shadow',"
		#{z}px #{z}px 0 #000
	")

reset = () ->
	createjs.Ticker.setPaused(true)
	newHighscore = false
	lastTime     = bigbang = createjs.Ticker.getTime()
	bird.alive   = true
	bird.score   = 0
	bird.pos     =
		x : 0
		x0: 0
		y0: config.stage.height/2
		y : config.stage.height/2
	bird.v =
		x: config.bird.v.x0
		y: 0
	birdView.rotation = 0
	pipeMan.reset()
	createjs.Ticker.setPaused(false)
intro = () ->

	reset()
	$('#score').text bird.score
	$('#score').css 'display', 'inherit'
	stage.removeChild startButton, scorePanelContainer

	handleTick()
	handler.touch = ()->
		flap()
		play()
	status = 'intro'
play = () ->
	bigbang = createjs.Ticker.getTime()
	handler.touch = flap
	# handler.touch = null
	# stage.addEventListener 'stagemousedown', flap
	startTime = createjs.Ticker.getTime()
	status = 'play'
gameover = () ->
	handler.touch = null
	startTime = createjs.Ticker.getTime()
	# scorePanelContainer.removeChild newLabel
	scorePanelContainer.removeChild newLabel
	stage.addChild scorePanelContainer
	$('#score').css 'display', 'none'
	unless $.cookie('hs')
		$.cookie 'hs',0 
	if bird.score > $.cookie('hs')
		$.cookie 'hs', bird.score, { expires: 365 }
		newHighscore = true
		scorePanelContainer.addChild newLabel
	highscoreText.text = $.cookie('hs')
	highscoreTextOutline.text = $.cookie('hs')
	status = 'gameover'
flap = ()->
	if bird.alive and bird.pos.y > config.bird.height/2
		createjs.Sound.play('flapSound') unless muted
		# flapSound.play() unless muted
		# onFrame false
		handleTick()
		startTime = createjs.Ticker.getTime()
		bird.pos.y0 = bird.pos.y
		bird.pos.x0 = bird.pos.x
		bird.v.y = config.bird.v.y0

renderShape = (assetId, img) ->
	switch assetId
		when 'groundTile'
			ground.graphics.beginFill '#dedb94'
			ground.graphics.drawRect 0, 0, 2*config.pixel.originalSize * config.stage.width, (config.stage.height-config.stage.groundY) * config.pixel.originalSize
			ground.graphics.endFill()

			ground.graphics.beginBitmapFill img, 'repeat', scaleMatrix
			ground.graphics.drawRect 0, 0, config.pixel.size * config.stage.width + img.width * scaleRatio, img.height * scaleRatio
			ground.graphics.endFill()

			ground.cache 0, 0, 2*config.pixel.originalSize * config.stage.width, (config.stage.height-config.stage.groundY) * config.pixel.originalSize

		when 'buildingTile'
			building.graphics.beginBitmapFill img, 'repeat', scaleMatrix
			building.graphics.drawRect 0, 0, config.pixel.size * config.stage.width, img.height * scaleRatio
			building.graphics.endFill()

			building.cache 0, 0, config.pixel.size * config.stage.width, img.height * scaleRatio

		when 'cloudTile'
			cloud.graphics.beginBitmapFill img, 'repeat', scaleMatrix
			cloud.graphics.drawRect 0, 0, config.pixel.size * config.stage.width, img.height * scaleRatio
			cloud.graphics.endFill()

			cloud.cache 0, 0, config.pixel.size * config.stage.width, img.height * scaleRatio

		when 'pipeTile'
			for i in [0..config.pipe.num]
				pair = new createjs.Container
				pipeUp = new createjs.Shape
				pipeUp.scaleY = pipeUp.scaleX = scaleRatio
				pipeUp.graphics.beginBitmapFill img
				pipeUp.graphics.drawRect 0, 0, img.width, img.height
				pipeUp.graphics.endFill()
				pipeUp.y = config.pipe.gap * config.pixel.size

				pipeDown = new createjs.Shape
				pipeDown.scaleY = -scaleRatio
				pipeDown.scaleX = scaleRatio
				pipeDown.graphics.beginBitmapFill img
				pipeDown.graphics.drawRect 0, 0, img.width, img.height
				pipeDown.graphics.endFill()
				pair.addChild pipeUp, pipeDown

				pair.cache 0, -img.height * scaleRatio, img.width * scaleRatio, 2*img.height * scaleRatio +  config.pipe.gap * config.pixel.size
				pairs.push pair
		when 'birdSeq'
			data = 
				framerate: 20
				images: [img]
				frames: 
					width : config.bird.width * config.pixel.originalSize
					height : config.bird.height * config.pixel.originalSize
					regX: config.bird.width * config.pixel.originalSize/2
					regY: config.bird.height * config.pixel.originalSize/2
					count : 3
				animations: 
					run:[0,2]
			spriteSheet = new createjs.SpriteSheet data
			birdView = new createjs.Sprite spriteSheet
			birdView.stop()
			birdView.scaleY = birdView.scaleX = scaleRatio
		when 'startButton'
			startButton.graphics.beginBitmapFill img, 'no-repeat', scaleMatrix
			startButton.graphics.drawRect 0, 0, img.width * scaleRatio, img.height * scaleRatio
			startButton.graphics.endFill()
		when 'scorePanel'
			scorePanel.graphics.beginBitmapFill img, 'no-repeat', scaleMatrix
			scorePanel.graphics.drawRect 0, 0, img.width * scaleRatio, img.height * scaleRatio
			scorePanel.graphics.endFill()
			scorePanelContainer.addChild scorePanel
			scoreText = new createjs.Text "0", "#{8*config.pixel.size}px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "white"
			scoreTextOutline = new createjs.Text "0", "#{8*config.pixel.size}px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "black"
			scoreText.textAlign = 'right'
			scoreTextOutline.textAlign = 'right'
			scoreTextOutline.width  = config.pixel.size * 150
			scoreText.x = config.pixel.size *102
			scoreText.y = config.pixel.size *19
			scoreTextOutline.x = config.pixel.size *102
			scoreTextOutline.y = config.pixel.size *19
			scoreTextOutline.outline = 2*config.pixel.size
			# highScoreText = new createjs.Text "200", "20px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "black"
			highscoreText = new createjs.Text "0", "#{8*config.pixel.size}px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "white"
			highscoreTextOutline = new createjs.Text "0", "#{8*config.pixel.size}px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "black"
			highscoreText.textAlign = 'right'
			highscoreTextOutline.textAlign = 'right'
			highscoreTextOutline.width  = config.pixel.size * 150
			highscoreText.x = config.pixel.size *102
			highscoreText.y = config.pixel.size *39
			highscoreTextOutline.x = config.pixel.size *102
			highscoreTextOutline.y = config.pixel.size *39
			highscoreTextOutline.outline = 2*config.pixel.size


			newLabelText = new createjs.Text "NEW", "#{8*config.pixel.size}px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "white"
			newLabelText.x = config.pixel.size *60
			newLabelText.y = config.pixel.size *39
			newLabelOutline = new createjs.Text "NEW", "#{8*config.pixel.size}px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "red"
			newLabelOutline.x = config.pixel.size *60
			newLabelOutline.y = config.pixel.size *39
			newLabelOutline.outline = 2*config.pixel.size
			newLabel.addChild newLabelOutline,newLabelText

			scorePanelContainer.addChild scoreTextOutline
			scorePanelContainer.addChild scoreText
			scorePanelContainer.addChild highscoreTextOutline
			scorePanelContainer.addChild highscoreText
	return
renderText = ()->
	scoreView = new createjs.Text "Loading..", "20px '04B_19__','04B_19__ie', 'Lucida Console', Monaco, monospace", "#ff7700"
	scoreView.x = 100 
	stage.addChild scoreView
	
	# scoreView.textBaseline = "alphabetic"
