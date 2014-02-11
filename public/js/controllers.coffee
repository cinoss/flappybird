'use strict'

# appModule.controller 'MainCtrl', ($scope,$http,$timeout) ->
# 	return

window.requestAnimateFrame = ((callback) ->
	return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || (callback)->
		window.setTimeout(callback, 1000 / 60);
	)()
config = {}
config.pixel =
	size : 3
config.pipe =
	distance : 56
	gap : 51
	width : 26
	topHeight : 11
	imgHeight : 140
config.stage =
	g : 500
	height : config.pipe.gap * 4
	width : (config.pipe.distance + config.pipe.width) * 2
	# width : 1024/config.pixel
config.bird =
	size : 21
	height : 16
	width : 21
	effectiveRadius : 12/2
	screenX : config.pipe.distance
bird =
	alive : true
	score : 0
	pos :
		x : 0
		x0 : 0
		y0 : config.stage.height/2
		y : config.stage.height/2
	v :
		x : 80
		y : 0
		y0 : -160
# config.bird.height/2 = config.bird.height / 2
$('#bird').css('height',(config.bird.height * config.pixel.size)+'px')
$('#bird').css('width',(config.bird.width * config.pixel.size)+'px')
# $('#bird').css('background-size','url(img/birds.png)')
$('#bird').css('top',((bird.pos.y  - config.bird.height/2)* config.pixel.size)+'px')
$('#bird').css('left',((config.bird.screenX - config.bird.width/2) * config.pixel.size)+'px')

$('.pipe').css('width',(config.pipe.width * config.pixel.size)+'px')
$('.pipe').css('height',(config.stage.height * config.pixel.size)+'px')
$('.pipe.up').css('top',(config.pipe.gap * config.pixel.size)+'px')
$('.pipe.up').css('background-position',"0px #{-config.pipe.imgHeight*config.pixel.size}px" )
# console.log config.pipe.imgHeight*config.pixel.size
$('.pipe.down').css('background-position',"0px #{(config.stage.height-config.pipe.imgHeight)*config.pixel.size}px" )
$('.pipe.down').css('top',-1*(config.stage.height * config.pixel.size)+'px')
$('#stage').css('height',(config.stage.height * config.pixel.size)+'px')
$('#stage').css('width',(config.stage.width * config.pixel.size)+'px')
freePairs = $.makeArray($('.pair'))
# init()

class PipeManager
	constructor: (@maxY, @nextX, @step, @freePairs) ->
		@pipes = []

	genPipe : () ->
		pipe =
			y : Math.round Math.random()*@maxY + (config.stage.height - @maxY - config.pipe.gap)/2
			x : @nextX
			score : 1
			pair : @freePairs.pop()
		# $("##{pipe.pair.id}").css('top',(pipe.y+(config.stage.height-@maxY-config.pipe.gap)/2)*config.pixel.size )
		$("##{pipe.pair.id}").css('top',(pipe.y)*config.pixel.size )
		@nextX += @step
		return pipe
	update : (viewportX) ->
		while @freePairs.length > 0
			@pipes.push @genPipe()
		for pipe in @pipes
			pipe.screenX = pipe.x - viewportX
			$("##{pipe.pair.id}").css('left',pipe.screenX*config.pixel.size)
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
		return true


bigbang = startTime = (new Date()).getTime()
theta = (dx,dy)->
	t = dy/(Math.abs(dx)+Math.abs(dy))
	# t = Math.atan2(dy,dx)/(2*Math.PI)
	if t>0
		return t * 90
	else 
		return 360 + t * 90
onFrame = (repeat)->
	currentTime = (new Date()).getTime()
	t = (currentTime - startTime)/1000
	bird.pos.y = bird.pos.y0 + bird.v.y * t + 0.5 * config.stage.g * Math.pow(t, 2)
	bird.pos.x = bird.pos.x0 + bird.v.x * t
	# console.log(t + " y=" + bird.pos.y)
	lastTime = currentTime
	$('#bird').css 'top',((bird.pos.y  - config.bird.height/2)* config.pixel.size)+'px'
	angle =  theta(bird.v.x, bird.v.y + t *config.stage.g)
	# console.log(Math.round angle)
	pipeMan.update(bird.pos.x - config.bird.screenX)
	if bird.alive and not pipeMan.checkBird()
		bird.alive = false
		# console.log 'hit'
		bird.v.x = 0
		# bird.pos.y0 = bird.pos.y
		bird.pos.x0 = bird.pos.x
		# bird.v.y += - (bird.v.y0/100)
	# $('#bird').css 'transform',"rotate(#{angle}deg)"
	# $('#bird').css '-ms-transform',"rotate(#{angle}deg)"
	# $('#bird').css '-webkit-transform',"rotate(#{angle}deg)"
	if angle < 180 and angle > 44
		state = 2
	else
		state = Math.round((currentTime-bigbang)/60)%3

	$('#bird').css 'background-position', "0px #{state*config.bird.height*config.pixel.size}px"

	# $('#bird').css 'top',((bird.pos.y  - config.bird.height/2)* config.pixel.size)+'px'
	if repeat
		if bird.pos.y> config.stage.height - config.bird.height/2
			flap()
			bird.pos.y0 = config.stage.height- config.bird.height/2
		requestAnimateFrame ()->
			onFrame true
			return
	return
flap = ()->
	if bird.alive and bird.pos.y > config.bird.height/2
		onFrame false
		startTime = (new Date()).getTime()
		bird.pos.y0 = bird.pos.y
		bird.pos.x0 = bird.pos.x
		# console.log(startTime + " y=" + bird.pos.y0)
		bird.v.y = bird.v.y0
$('#stage').mousedown flap
$(document).keydown (event) ->
	# if event.keyCode == 32
		flap()

pipeMan = new PipeManager 1.2*config.pipe.gap,1.5*(config.stage.width),config.pipe.distance+config.pipe.width,freePairs


requestAnimateFrame ()->
	onFrame true
	return
MainCtrl = ($scope,$timeout)-> 
	# init = ->


	return