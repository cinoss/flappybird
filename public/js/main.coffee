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

pipeMan = null

scaleMatrix = null 
scaleRatio = 1

loadQueue = new createjs.LoadQueue;

handler = {}
status = ''

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

	config.pixel.size = (stage.canvas.height/(config.pipe.gap * 4))
	config.pixel.size = Math.floor(config.pixel.size * 2)/2
	config.stage.height = stage.canvas.height/config.pixel.size
	config.stage.width = stage.canvas.width/config.pixel.size
	console.log [stage.canvas.height,(config.pipe.gap * 4.5)]
	console.log ['pixel',config.pixel.size]
	config.pipe.num = Math.round(config.stage.width / (config.pipe.distance + config.pipe.width) ) 
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
	config.stage.gapMax = 1.7 * config.pipe.gap
	config.stage.groundY = config.stage.gapMax + (config.stage.height - config.stage.gapMax - config.pipe.gap)/2 + config.pipe.gap + 2 * config.pipe.topHeight

	#config for speed
	ratio = 1
	config.stage.g = 650 * ratio
	config.bird.v.x0 = 60 * ratio
	config.bird.v.x0 = config.pipe.distance * 1.2* ratio
	config.bird.v.y0 = -195
	bird = {}
	bird.alive = true
	bird.score = 0
	bird.pos =
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

main = () ->
	canvas = document.getElementById('stage')
	canvas = document.createElement("canvas");
	canvas.height = Math.min($(window).height(),5500) || 480;
	canvas.width = Math.min($(window).width(),9000) || 640;
	canvas.height *= 3/4
	canvas.height = Math.max(canvas.height,640)
	# if canvas.width > canvas.height * 2
	# 	canvas.width = Math.round(canvas.height * 2)
	# if canvas.width > 550
	# 	canvas.width = 550
	$('#stage').append(canvas);
	$('#stage').height(canvas.height)

	console.log ['window',$(window).height(),$(window).width()]

	stage = new createjs.Stage(canvas)
	stage.mouseEventsEnabled = true
	
	init()

	# Set The Flash Plugin for browsers that dont support SoundJS
	# createjs.SoundJS.FlashPlugin.BASE_PATH = "assets/"
	# if !createjs.SoundJS.checkPlugin(true)
	# 	alert "Error!"
	# 	return
	

	manifest = [
		{ src: '/img/floor.jpg', 	id: 'groundTile'},
		{ src: '/img/buildings.jpg', 	id: 'buildingTile'},
		{ src: '/img/clouds.jpg', 	id: 'cloudTile'},
		{ src: '/img/pipe.gif', 	id: 'pipeTile'},
		{ src: '/img/birds.gif', 	id: 'birdSeq'},

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

	setupTicker()

	if ('ontouchstart' in document.documentElement) 
		console.log 1
		# console.log document.documentElement.ontouchstart
		canvas.addEventListener 'touchstart', (e) ->
			handleKeyDown()
		, false

		canvas.addEventListener 'touchend', (e) ->
			handleKeyUp();
		, false
	else 
		console.log 2
		document.onkeydown = handleKeyDown;
		document.onkeyup = handleKeyUp;

		if (window.navigator.msPointerEnabled) 
			# console.log 3
			document.getElementById('body').addEventListener "MSPointerDown", handleKeyDown, false
			document.getElementById('body').addEventListener "MSPointerUp", handleKeyUp, false
		else 
			# console.log 4
			document.onmousedown = handleKeyDown
			document.onmouseup = handleKeyUp
	renderDOM()
setupTicker = () ->
	# /* Ticker */
	
	# createjs.Ticker.addEventListener("tick", stage);
	createjs.Ticker.timingMode = createjs.Ticker.RAF;
	# createjs.Ticker.setFPS(FPS)
	# createjs.Ticker.maxDelta = 20

handleKeyDown = () ->
	# console.log 'touch'
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
	# console.log 1
	# renderShape 'birdSeq', loadQueue.getResult('birdSeq')
	# console.log 2
	addMainView()
	return
handleFileLoad = (event) ->
	# console.log [event, event.item.type]
	switch event.item.type
		when createjs.LoadQueue.IMAGE
			renderShape event.item.id, event.result
		when createjs.LoadQueue.SOUND
			createjs.Sound.registerSound(event.result, event.result.id);
		# 	handleLoadComplete()
addMainView = ()->
	createjs.Ticker.addEventListener("tick", handleTick);
	intro()
	console.log '---- main -----'
	renderBasic()
	ground.y = config.stage.groundY * config.pixel.size
	building.y = (config.stage.groundY-config.stage.buildingHeight) * config.pixel.size
	cloud.y = (config.stage.groundY-config.stage.buildingHeight-config.stage.cloudHeight) * config.pixel.size + 1
	

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
	pipeMan = new PipeManager .5*(config.stage.width), config.pipe.distance+config.pipe.width, pairs.slice()
	stage.update();
	return
class PipeManager
	constructor: (@nextX, @step, @freePairs) ->
		@pipes = []
	reset : () ->
		return
	genPipe : () ->
		pipe =
			y : (Math.random())*config.stage.gapMax + (config.stage.height - config.stage.gapMax - config.pipe.gap)/2
			x : @nextX
			score : 1
			pair : @freePairs.pop()
		# $("##{pipe.pair.id}").css('top',(pipe.y+(config.stage.height-config.stage.gapMax-config.pipe.gap)/2)*config.pixel.size )
		pipe.pair.y = (pipe.y)*config.pixel.size
		pipe.x1 = pipe.x + config.pipe.width + config.bird.effectiveRadius
		pipe.x0 = pipe.x - config.bird.effectiveRadius
		pipe.y0 = pipe.y + config.bird.effectiveRadius
		pipe.y1 = pipe.y + config.pipe.gap - config.bird.effectiveRadius	
		@nextX += @step
		return pipe
	update : (viewportX) ->
		reCache = false
		while @freePairs.length > 0
			@pipes.push @genPipe()
			reCache = true
		for pipe in @pipes
			pipe.screenX = pipe.x - viewportX
			if reCache
				pipe.pair.x = (pipe.screenX - @pipes[0].screenX)*config.pixel.size
		pairContainer.x =  @pipes[0].screenX * config.pixel.size
		if reCache
			pairContainer.cache 0, 0, @pipes.length * @step * config.pixel.size, config.stage.groundY * config.pixel.size

		while @pipes.length > 0 and @pipes[0].screenX < -config.pipe.width
			@freePairs.push @pipes[0].pair
			@pipes.shift()
			break

		return
	checkBird : () ->
		# console.log "+++++++++++"
		for pipe in @pipes
			if bird.pos.x < pipe.x0 or bird.pos.x> pipe.x1
				continue
			# top pipe
			if bird.pos.y <= pipe.y
				if bird.pos.x <= pipe.x1 and bird.pos.x >= pipe.x0
					console.log 'hit 1'
					return false
			# bottom pipe
			if bird.pos.y >= pipe.y + config.pipe.gap
				if bird.pos.x <= pipe.x1 and bird.pos.x >= pipe.x0
					console.log 'hit 2'
					return false
			#middle
			if bird.pos.x <= pipe.x + config.pipe.width and bird.pos.x >= pipe.x
				if bird.pos.y < pipe.y0
					console.log 'hit 3'
					return false 
				if bird.pos.y > pipe.y1
					console.log 'hit 4'
					return false 
			if pipe.score and bird.pos.x > pipe.x
				bird.score += pipe.score
				pipe.score = 0
		if bird.pos.y >= config.stage.groundY - config.bird.effectiveRadius
			console.log 'hit-ground'
			return false
		return true
theta = (dx,dy)->
	t = dy/(Math.abs(dx)+Math.abs(dy))
	# t = Math.atan2(dy,dx)/(2*Math.PI)
	if t>0
		return t * 90
	else 
		return 360 + t * 15

handleTick = () ->
	currentTime = createjs.Ticker.getTime()
	switch status
		when 'intro'
			t = (currentTime - bigbang)/1000

			# console.log currentTime-bigbang
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
			# console.log Math.round(1000/(currentTime-lastTime))+'fps'
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

			birdView.y = (bird.pos.y)* config.pixel.size
			birdView.rotation = angle
			birdView.gotoAndStop(wingState)

			if bird.alive
				groundPosition = -(currentTime-bigbang)/1000 * (config.bird.v.x0*config.pixel.size)
				ground.x = (groundPosition % (config.stage.groundTileWidth * config.pixel.size))
				pipeMan.update(bird.pos.x - config.bird.screenX)

				oldScore = bird.score
				unless pipeMan.checkBird()
					createjs.Sound.play('hitSound') unless muted
					bird.alive = false
					if bird.pos.y < config.stage.groundY - config.bird.effectiveRadius
						createjs.Sound.play('fallSound') unless muted
						startTime = createjs.Ticker.getTime()
						# console.log 'hit'
						bird.v.x = 0
						bird.pos.y0 = bird.pos.y
						bird.pos.x0 = bird.pos.x
						bird.v.y = config.bird.v.y0/2
					else
						gameover()
				if oldScore < bird.score
					$('#score').text(bird.score);
					createjs.Sound.play('scoreSound') unless muted
			else if bird.pos.y >= config.stage.groundY - config.bird.effectiveRadius
				createjs.Sound.play('hitSound') unless muted
				gameover()
			stage.update()

		
	# console.log ['calc time',createjs.Ticker.getTime()-currentTime]
	# console.log 'tick'
	return

renderBasic = () ->
	background.graphics.beginFill '#4ac3ce'
	# background.graphics.beginFill 'red'
	background.graphics.drawRect 0, 0, stage.canvas.width, stage.canvas.height
	background.graphics.endFill()
	return
renderDOM = () ->
	$('#score').css('width',(config.stage.width * config.pixel.size)+'px')
	$('#score').css('top',((config.stage.height-config.stage.groundY) * config.pixel.size)+'px')
	$('#score').css('font-size',config.bird.size * config.pixel.size)
	$('#score').text 'loading..'
	z = config.pixel.size
	$('#score').css('text-shadow',"
		#{z}px #{z}px 0 #000
	")
intro = () ->
	$('#score').text bird.score
	lastTime = bigbang = createjs.Ticker.getTime()
	status = 'intro'
	handler.touch = ()->
		flap()
		play()
play = () ->
	console.log 'play'
	bigbang = createjs.Ticker.getTime()
	handler.touch = flap
	# handler.touch = null
	# stage.addEventListener 'stagemousedown', flap
	startTime = createjs.Ticker.getTime()
	pipeMan.reset()
	status = 'play'
gameover = () ->
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
		# console.log(startTime + " y=" + bird.pos.y0)
		bird.v.y = config.bird.v.y0

renderShape = (assetId, img) ->
	# console.log assetId
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
	return




