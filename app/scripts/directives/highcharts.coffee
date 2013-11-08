'use strict'

angular.module('multifinderApp.directives', []).directive "chart", ->
  restrict: "E"
  template: "<div></div>"
  scope:
    chartData: "=value"

  transclude: true
  replace: true
  link: (scope, element, attrs) ->
    chartsDefaults = chart:
      renderTo: element[0]
      type: attrs.type or null
      height: attrs.height or null
      width: attrs.width or null

    
    #Update when charts data changes
    scope.$watch (->
      scope.chartData
    ), (value) ->
      return  unless value
      
      # We need deep copy in order to NOT override original chart object.
      # This allows us to override chart data member and still the keep
      # our original renderTo will be the same
      deepCopy = true
      newSettings = {}
      $.extend deepCopy, newSettings, chartsDefaults, scope.chartData
      chart = new Highcharts.Chart(newSettings)
