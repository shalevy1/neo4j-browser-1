angular.module('neo4jApp')
  .config ['$routeProvider', ($routeProvider) ->
    $routeProvider
      .when('/', page: 'views')
      .when('/views/:viewId', page: 'views')
      .when('/system', page: 'system')
      .otherwise
        redirectTo: '/'
  ]
