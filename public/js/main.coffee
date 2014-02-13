FPS = 60

muted = false

startTime = 0
bigbang = (new Date()).getTime()

# mainView = new Container
config = null
bird = null

stage = null
ground = new createjs.Shape
building = new createjs.Shape
cloud = new createjs.Shape 
background = new createjs.Shape
pairs = []
birdView = null

pipeMan = null

scaleMatrix = null 
scaleRatio = 1

loadQueue = new createjs.LoadQueue();

status = ''

init = () ->
	config = {}
	config.pixel =
		size : 3
		originalSize : 5
	scaleMatrix = new createjs.Matrix2D()


	scaleRatio = config.pixel.size/config.pixel.originalSize

	# set scale
	ground.scaleY = ground.scaleX = scaleRatio
	building.scaleY = building.scaleX = scaleRatio
	cloud.scaleY = cloud.scaleX = scaleRatio


	scaleMatrix.scale scaleRatio, scaleRatio
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
		# height : config.pipe.gap * 4.5
		# width : (config.pipe.distance + config.pipe.width) * 2
		height : stage.canvas.height/config.pixel.size
		width : stage.canvas.width/config.pixel.size

	config.pipe.num = Math.round(config.stage.width /(config.pipe.distance + config.pipe.width) ) 

	config.bird =
		size : 21
		height : 16
		width : 21
		effectiveRadius : 12/2
		screenX : config.pipe.distance
		v : 
			x0 : 80
			y0 : -180
	config.stage.gapMax = 1.7 * config.pipe.gap
	config.stage.groundY = config.stage.gapMax + (config.stage.height - config.stage.gapMax - config.pipe.gap)/2 + config.pipe.gap + 2 * config.pipe.topHeight

	#config for speed
	ratio = 1
	config.stage.g = 650 * ratio
	config.bird.v.x0 = 60 * ratio
	config.bird.v.x0 = config.pipe.distance *1.5* ratio
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

main = () ->
	# canvas = document.getElementById('flyStage')
	stage = new createjs.Stage('flyStage')
	stage.mouseEventsEnabled = true
	
	init()

	# Set The Flash Plugin for browsers that dont support SoundJS
	# createjs.SoundJS.FlashPlugin.BASE_PATH = "assets/"
	# if !createjs.SoundJS.checkPlugin(true)
	# 	alert "Error!"
	# 	return
	

	manifest = [
				{ src:'/img/floor.jpg', id:'groundTile'},
				{ src:'/img/buildings.jpg', id:'buildingTile'},
				{ src:'/img/clouds.jpg', id:'cloudTile'},
				{ src:'/img/pipe.gif', id:'pipeTile'},
				{ src:'/img/birds.gif', id:'birdSeq'},

				{ src: '/audio/flap.mp3', id :'flapSound'},
				{ src: '/audio/hit.mp3', id :'hitSound'},
				{ src: '/audio/fall.mp3', id :'fallSound'},
				{ src: '/audio/score.mp3', id :'scoreSound'},
			]

	loadQueue.installPlugin(createjs.Sound)
	# loadQueue.onProgress = handleProgress
	loadQueue.on('complete', handleComplete)
	loadQueue.on('fileload', handleFileLoad);
	loadQueue.loadManifest(manifest)

	# /* Ticker */
	
	createjs.Ticker.addEventListener("tick", stage);
	createjs.Ticker.setFPS(FPS)
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
	console.log '---- main -----'
	renderBasic()
	ground.y = config.stage.groundY * config.pixel.size
	building.y = (config.stage.groundY-config.stage.buildingHeight) * config.pixel.size
	cloud.y = (config.stage.groundY-config.stage.buildingHeight-config.stage.cloudHeight) * config.pixel.size
		

	stage.addChild background, building, cloud
	for pair in pairs
		pair.y = Math.random() * 400
		stage.addChild pair
		pair.x = -1000
		# break
	birdView.x = (config.bird.screenX) * config.pixel.size
	stage.addChild birdView
	stage.addChild ground
	stage.update();
	createjs.Ticker.addEventListener("tick", handleTick);
	intro()
	return
class PipeManager
	constructor: (@nextX, @step, @freePairs) ->
		@pipes = []

	genPipe : () ->
		pipe =
			y : Math.random()*config.stage.gapMax + (config.stage.height - config.stage.gapMax - config.pipe.gap)/2
			x : @nextX
			score : 1
			pair : @freePairs.pop()
		# $("##{pipe.pair.id}").css('top',(pipe.y+(config.stage.height-config.stage.gapMax-config.pipe.gap)/2)*config.pixel.size )
		pipe.pair.y = (pipe.y)*config.pixel.size
		@nextX += @step
		return pipe
	update : (viewportX) ->
		while @freePairs.length > 0
			@pipes.push @genPipe()
		for pipe in @pipes
			pipe.screenX = pipe.x - viewportX
			pipe.pair.x = pipe.screenX*config.pixel.size
		while @pipes.length > 0 and @pipes[0].screenX < -config.pipe.width
			@freePairs.push @pipes[0].pair
			@pipes.shift()
			break
		return
	checkBird : () ->
		# console.log "+++++++++++"
		for pipe in @pipes
			# top pipe
			if bird.pos.y <= pipe.y
				if bird.pos.x <= pipe.x + config.pipe.width + config.bird.effectiveRadius and bird.pos.x >= pipe.x - config.bird.effectiveRadius
					console.log 'hit 1'
					return false
			# bottom pipe
			# console.log [bird.pos.y , pipe.y + config.pipe.gap]
			if bird.pos.y >= pipe.y + config.pipe.gap
				if bird.pos.x <= pipe.x + config.pipe.width + config.bird.effectiveRadius and bird.pos.x >= pipe.x - config.bird.effectiveRadius
					console.log 'hit 2'
					return false
			#middle
			if bird.pos.x <= pipe.x + config.pipe.width and bird.pos.x >= pipe.x
				# console.log [bird.pos.x , pipe.x + config.pipe.width , pipe.x]
				# console.log [bird.pos.y , pipe.y + config.bird.effectiveRadius,pipe.y + config.pipe.gap - config.bird.effectiveRadius]
				if bird.pos.y < pipe.y + config.bird.effectiveRadius
					console.log 'hit 3'
					return false 
				if bird.pos.y > pipe.y + config.pipe.gap - config.bird.effectiveRadius					
					console.log 'hit 4'
					return false 
			if bird.pos.x > pipe.x
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
	switch status
		when 'intro'
			currentTime = (new Date()).getTime()
			t = (currentTime - bigbang)/1000

			groundPosition = -(currentTime-bigbang)/1000 * (config.bird.v.x0*config.pixel.size)
			ground.x = Math.floor(groundPosition) % (config.stage.groundTileWidth * config.pixel.size) + groundPosition - Math.floor(groundPosition)

			# buildingState = -(currentTime-bigbang)/1000 * (config.bird.v.x0*config.pixel.size)/4
			# $('#buildings').css 'background-position', buildingState+"px 0px"
			# $('#clouds').css 'background-position', buildingState+"px 0px"

			wingState = Math.round((currentTime-bigbang)/150)%3
			birdView.gotoAndStop(wingState)
			# $('#bird').css 'background-position', "0px #{wingState*config.bird.height*config.pixel.size}px"


			bird.pos.y = bird.pos.y0 + Math.sin(t*5)*config.bird.effectiveRadius
			birdView.y = (bird.pos.y)* config.pixel.size
		when 'play'
			currentTime = (new Date()).getTime()
			t = (currentTime - startTime)/1000

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
				ground.x = Math.floor(groundPosition) % (config.stage.groundTileWidth * config.pixel.size) + groundPosition - Math.floor(groundPosition)
				pipeMan.update(bird.pos.x - config.bird.screenX)

				oldScore = bird.score
				unless pipeMan.checkBird()
					if bird.pos.y < config.stage.groundY - config.bird.effectiveRadius
						createjs.Sound.play('fallSound') unless muted
						createjs.Sound.play('hitSound') unless muted
					startTime = (new Date()).getTime()
					bird.alive = false
					# console.log 'hit'
					bird.v.x = 0
					bird.pos.y0 = bird.pos.y
					bird.pos.x0 = bird.pos.x
					bird.v.y = config.bird.v.y0/2
				if oldScore < bird.score
					# $('#score').text(bird.score);
					createjs.Sound.play('scoreSound') unless muted		


		
	# console.log 'tick'
	return

renderBasic = () ->
	background.graphics.beginFill '#4ac3ce'
	# background.graphics.beginFill 'red'
	background.graphics.drawRect 0, 0, stage.canvas.width, stage.canvas.height
	background.graphics.endFill()
	return
intro = () ->
	status = 'intro'
	stage.on 'mousedown', ()->
		flap()
		play()
	stage.on 'touchstart', ()->
		flap()
		play()
play = () ->
	console.log 'play'
	stage.removeAllEventListeners 'mousedown'
	stage.on 'mousedown', flap
	stage.removeAllEventListeners 'touchstart'
	stage.on 'touchstart', flap
	startTime = (new Date()).getTime()
	pipeMan = new PipeManager 1.5*(config.stage.width), config.pipe.distance+config.pipe.width, pairs.slice()
	status = 'play'

flap = ()->
	if bird.alive and bird.pos.y > config.bird.height/2
		createjs.Sound.play('flapSound') unless muted
		# flapSound.play() unless muted
		# onFrame false
		handleTick()
		startTime = (new Date()).getTime()
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

			ground.graphics.beginBitmapFill img
			ground.graphics.drawRect 0, 0, 2*config.pixel.originalSize * config.stage.width, img.height
			ground.graphics.endFill()

			ground.cache 0, 0, 2*config.pixel.originalSize * config.stage.width, (config.stage.height-config.stage.groundY) * config.pixel.originalSize

		when 'buildingTile'
			building.graphics.beginBitmapFill img
			building.graphics.drawRect 0, 0, 2*config.pixel.originalSize * config.stage.width, img.height
			building.graphics.endFill()

			building.cache 0, 0, 2*config.pixel.originalSize * config.stage.width, img.height

		when 'cloudTile'
			cloud.graphics.beginBitmapFill img
			cloud.graphics.drawRect 0, 0, 2*config.pixel.originalSize * config.stage.width, img.height
			cloud.graphics.endFill()

			cloud.cache 0, 0, 2*config.pixel.originalSize * config.stage.width, img.height

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
				# pairs.scaleY = pairs.scaleX = scaleRatio
				pair.cache 0, -img.height * scaleRatio, img.width * scaleRatio, 2*img.height * scaleRatio +  config.pipe.gap * config.pixel.size
				pairs.push pair
		when 'birdSeq'
			data = 
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




