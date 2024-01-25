# app Module
#
# @abstract Description
#
'use strict'

appModule = angular.module 'app', [
	'ui.router'
]

appModule.config ($locationProvider) ->
	$locationProvider
		.html5Mode(false)
		.hashPrefix '!'
	return

appModule.config ($stateProvider, $urlRouterProvider) ->
	$urlRouterProvider.otherwise "/"
	$stateProvider.state 'main', 
		url: "/",
		controller: "MainCtrl"
		templateUrl: "views/main.html"
	$stateProvider.state 'main.welcome', 
		url: "/welcome",
		controller: "IndexCtrl"
		templateUrl: "views/welcome.html"

	$stateProvider.state 'main.score', 
		url: "/score",
		controller: "KaraokeCtrl"
		templateUrl: "views/score.html"
	return
