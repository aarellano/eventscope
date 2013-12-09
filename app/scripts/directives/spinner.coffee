"use strict"
angular.module("multifinderApp.directives").directive "spinner", ($rootScope) ->
  template: "<div ng-show=\"loading\" class=\"spinner-shown\">
              <div class=\"wrapper\">
                <img src=\"/images/wait.png\"/><br>
                <div class=\"process-label\">Loading Dataset</div>
              </div>
            </div>"
  restrict: "C"
  replace: true
  link: (_scope, _element, _attrs) ->
    _scope.loading = false
    $rootScope.$on "startSpinner", ->
      _scope.loading = true

    $rootScope.$on "stopSpinner", ->
      _scope.loading = false
