'use strict'

app = angular.module('neo4jApp', [])

app
  .config ['$routeProvider', ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .otherwise
        redirectTo: '/'
  ]

app.config([
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-stream'] = true
    $httpProvider.defaults.headers.common['Content-Type'] = 'application/json'
])
