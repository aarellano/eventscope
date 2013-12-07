window.app = angular.module('multifinderApp', ['multifinderApp.directives', '$strap.directives', 'ui.bootstrap'])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .otherwise
        redirectTo: '/'
