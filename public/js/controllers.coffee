'use strict'

# appModule.controller 'MainCtrl', ($scope,$http,$timeout) ->
# 	return

window.requestAnimateFrame = ((callback) ->
	return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || (callback)->
		window.setTimeout(callback, 1000 / 60);
	)()
MainCtrl = ($scope,$timeout)-> 
	# init = ->
	pipe =
		distance : 56
		gap : 51
		width : 28
		topHeight : 11
	stage =
		g : 250
		height : pipe.gap * 4
		width : (pipe.distance + pipe.width) * 2
	bird =
		size : 20
		pos :
			x : 0
			y0 : stage.height/2
			y : stage.height/2
		v :
			x : 10
			y : 0
			y0 : 120
		# a : -3
		screenX : pipe.distance
	bird.radius = bird.size / 2
	pixel =
		size : 2
	$('#bird').css('height',(bird.size * pixel.size)+'px')
	$('#bird').css('width',(bird.size * pixel.size)+'px')
	$('#bird').css('top',(bird.pos.y * pixel.size - bird.radius)+'px')
	$('#bird').css('left',(bird.screenX * pixel.size - bird.radius)+'px')

	$('.pipe').css('width',(pipe.width * pixel.size)+'px')
	$('.pipe').css('height',(stage.height * pixel.size)+'px')
	$('.pipe.up').css('top',(pipe.gap * pixel.size)+'px')
	$('.pipe.down').css('top',-1*(stage.height * pixel.size)+'px')
	$('#stage').css('height',(stage.height * pixel.size)+'px')
	$('#stage').css('width',(stage.width * pixel.size)+'px')
	freePairs = $('.pair')
	# console.log(requestAnimationFrame)
	# init()
	startTime = (new Date()).getTime()
	onFrame = ($scope,repeat)->
		currentTime = (new Date()).getTime()
		t = (currentTime - startTime)/1000
		bird.pos.y = bird.pos.y0 + bird.v.y * t + 0.5 * stage.g * Math.pow(t, 2)
		# console.log(t + " y=" + bird.pos.y)
		lastTime = currentTime
		$('#bird').css 'top',(bird.pos.y * pixel.size - bird.radius)+'px'
		if repeat
			if bird.pos.y> stage.height - bird.radius
				flap()
			requestAnimateFrame ()->
				onFrame $scope,true
				return
		return
	flap = ()->
		if bird.pos.y > 0
			onFrame $scope,false
			startTime = (new Date()).getTime()
			bird.pos.y0 = bird.pos.y
			console.log(startTime + " y=" + bird.pos.y0)
			bird.v.y = -bird.v.y0
	$('#stage').click flap
	$(document).keydown (event) ->

		# if event.keyCode == 32
			flap()

	onFrame $scope,true

	return