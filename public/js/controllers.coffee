'use strict'

# appModule.controller 'MainCtrl', ($scope,$http,$timeout) ->
# 	return

window.requestAnimateFrame = ((callback) ->
	return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || (callback)->
		window.setTimeout(callback, 1000 / 60);
	)()

class PipeManager
	constructor: (@maxY, @nextX, @step, @freePairs) ->
		@pipes = []

	genPipe : () ->
		console.log 'genPipe'
		pipe =
			y : Math.round Math.random()*@maxY
			x : @nextX
			pair : @freePairs.pop()
		# console.log @freePairs
		console.log pipe.pair
		$("##{pipe.pair.id}").css('top',pipe.y*pixel.size)
		@nextX += @step
		console.log @step
		return pipe
	update : (viewportX) ->
		while @freePairs.length > 0
			@pipes.push @genPipe()
		for pipe in @pipes
			pipe.screenX = pipe.x - viewportX
			$("##{pipe.pair.id}").css('left',pipe.screenX*pixel.size)
			# console.log pipe.screenX
			# console.log $("##{pipe.pair.id}")
		# console.log @pipes[0].screenX,pipe.width
		while @pipes.length > 0 and @pipes[0].screenX < -10
			console.log @pipes
			@freePairs.push @pipes[0].pair
			console.log @freePairs
			@pipes.shift()
			break
		return


pipe =
	distance : 56
	gap : 51
	width : 28
	topHeight : 11
stage =
	g : 600
	height : pipe.gap * 4
	width : (pipe.distance + pipe.width) * 2
bird =
	size : 15
	pos :
		x : 0
		x0 : 0
		y0 : stage.height/2
		y : stage.height/2
	v :
		x : 60
		y : 0
		y0 : 180
	# a : -3
	screenX : pipe.distance
bird.radius = bird.size / 2
pixel =
	size : 3
$('#bird').css('height',(bird.size * pixel.size)+'px')
$('#bird').css('width',(bird.size * pixel.size)+'px')
# $('#bird').css('top',(bird.pos.y * pixel.size - bird.radius)+'px')
$('#bird').css('left',(bird.screenX * pixel.size - bird.radius)+'px')

$('.pipe').css('width',(pipe.width * pixel.size)+'px')
$('.pipe').css('height',(stage.height * pixel.size)+'px')
$('.pipe.up').css('top',(pipe.gap * pixel.size)+'px')
$('.pipe.down').css('top',-1*(stage.height * pixel.size)+'px')
$('#stage').css('height',(stage.height * pixel.size)+'px')
$('#stage').css('width',(stage.width * pixel.size)+'px')
freePairs = $.makeArray($('.pair'))
# init()

startTime = (new Date()).getTime()
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
	bird.pos.y = bird.pos.y0 + bird.v.y * t + 0.5 * stage.g * Math.pow(t, 2)
	# console.log(bird.pos.y)
	bird.pos.x = bird.pos.x0 + bird.v.x * t
	# console.log(t + " y=" + bird.pos.y)
	lastTime = currentTime
	$('#bird').css 'top',(bird.pos.y * pixel.size - bird.radius)+'px'
	# $('#bird').css 'left',(bird.pos.x * pixel.size - bird.radius)+'px'
	angle =  theta(bird.v.x, bird.v.y + t *stage.g)
	# console.log(Math.round angle)
	pipeMan.update(bird.pos.x - bird.screenX)
	# $('#bird').css 'transform','rotate(#{angle}deg)'
	# $('#bird').css '-ms-transform','rotate(#{angle}deg)'
	# $('#bird').css '-webkit-transform','rotate(#{angle}deg)'

	# $('#bird').css 'top',(bird.pos.y * pixel.size - bird.radius)+'px'
	if repeat
		if bird.pos.y> stage.height - bird.radius
			flap()
			bird.pos.y0 = stage.height- bird.radius
		requestAnimateFrame ()->
			onFrame true
			return
	return
flap = ()->
	if bird.pos.y > bird.radius
		onFrame false
		startTime = (new Date()).getTime()
		bird.pos.y0 = bird.pos.y
		bird.pos.x0 = bird.pos.x
		# console.log(startTime + " y=" + bird.pos.y0)
		bird.v.y = -bird.v.y0
$('#stage').click flap
$(document).keydown (event) ->
	# if event.keyCode == 32
		flap()

pipeMan = new PipeManager 2*pipe.gap,2*(stage.width),pipe.distance+pipe.width,freePairs


requestAnimateFrame ()->
	onFrame true
	return
MainCtrl = ($scope,$timeout)-> 
	# init = ->


	return