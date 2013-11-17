"use strict"
angular.module("multifinderApp.directives", []).directive "highchart", ->
  prependMethod = (obj, method, func) ->
    original = obj[method]
    obj[method] = ->
      args = Array::slice.call(arguments_)
      func.apply this, args
      if original
        original.apply this, args
      else
        return
  deepExtend = (destination, source) ->
    for property of source
      if source[property] and source[property].constructor and source[property].constructor is Object
        destination[property] = destination[property] or {}
        deepExtend destination[property], source[property]
      else
        destination[property] = source[property]
    destination
  seriesId = 0
  ensureIds = (series) ->
    series.forEach (s) ->
      s.id = "series-" + seriesId++  unless angular.isDefined(s.id)


  axisNames = ["xAxis", "yAxis"]
  getMergedOptions = (scope, element, config) ->
    mergedOptions = {}
    defaultOptions =
      chart:
        events: {}

      title: {}
      subtitle: {}
      series: []
      credits: {}
      plotOptions: {}
      navigator:
        enabled: false

    if config.options
      mergedOptions = deepExtend(defaultOptions, config.options)
    else
      mergedOptions = defaultOptions
    mergedOptions.chart.renderTo = element[0]
    axisNames.forEach (axisName) ->
      if config[axisName]
        prependMethod mergedOptions.chart.events, "selection", (e) ->
          thisChart = this
          if e[axisName]
            scope.$apply ->
              scope.config[axisName].currentMin = e[axisName][0].min
              scope.config[axisName].currentMax = e[axisName][0].max

          else

            #handle reset button - zoom out to all
            scope.$apply ->
              scope.config[axisName].currentMin = thisChart[axisName][0].dataMin
              scope.config[axisName].currentMax = thisChart[axisName][0].dataMax


        prependMethod mergedOptions.chart.events, "addSeries", (e) ->
          scope.config[axisName].currentMin = this[axisName][0].min or scope.config[axisName].currentMin
          scope.config[axisName].currentMax = this[axisName][0].max or scope.config[axisName].currentMax

        mergedOptions[axisName] = angular.copy(config[axisName])

    mergedOptions.title = config.title  if config.title
    mergedOptions.subtitle = config.subtitle  if config.subtitle
    mergedOptions.credits = config.credits  if config.credits
    mergedOptions

  updateZoom = (axis, modelAxis) ->
    extremes = axis.getExtremes()
    axis.setExtremes modelAxis.currentMin, modelAxis.currentMax, false  if modelAxis.currentMin isnt extremes.dataMin or modelAxis.currentMax isnt extremes.dataMax

  processExtremes = (chart, axis, axisName) ->
    chart[axisName][0].setExtremes axis.currentMin, axis.currentMax, true  if axis.currentMin or axis.currentMax

  processSeries = (chart, series) ->
    ids = []
    if series
      ensureIds series

      #Find series to add or update
      series.forEach (s) ->
        ids.push s.id
        chartSeries = chart.get(s.id)
        if chartSeries
          chartSeries.update angular.copy(s), false
        else
          chart.addSeries angular.copy(s), false


    #Now remove any missing series
    i = chart.series.length - 1

    while i >= 0
      s = chart.series[i]
      s.remove false  if ids.indexOf(s.options.id) < 0
      i--

  initialiseChart = (scope, element, config) ->
    config or (config = {})
    mergedOptions = getMergedOptions(scope, element, config)
    chart = (if config.useHighStocks then new Highcharts.StockChart(mergedOptions) else new Highcharts.Chart(mergedOptions))
    i = 0

    while i < axisNames.length
      processExtremes chart, config[axisNames[i]], axisNames[i]  if config[axisNames[i]]
      i++
    processSeries chart, config.series
    chart.showLoading()  if config.loading
    chart.redraw()
    chart

  restrict: "EAC"
  replace: true
  template: "<div></div>"
  scope:
    config: "="

  link: (scope, element, attrs) ->
    chart = initialiseChart(scope, element, scope.config)
    scope.$watch "config.series", ((newSeries, oldSeries) ->

      #do nothing when called on registration
      return  if newSeries is oldSeries
      processSeries chart, newSeries
      chart.redraw()
    ), true
    scope.$watch "config.title", ((newTitle) ->
      chart.setTitle newTitle, true
    ), true
    scope.$watch "config.subtitle", ((newSubtitle) ->
      chart.setTitle true, newSubtitle
    ), true
    scope.$watch "config.loading", (loading) ->
      if loading
        chart.showLoading()
      else
        chart.hideLoading()

    scope.$watch "config.credits.enabled", (credits) ->
      if credits
        chart.credits.show()
      else chart.credits.hide()  if chart.credits

    scope.$watch "config.useHighStocks", (useHighStocks) ->
      chart.destroy()
      chart = initialiseChart(scope, element, scope.config)

    axisNames.forEach (axisName) ->
      scope.$watch "config." + axisName, ((newAxes, oldAxes) ->
        return  if newAxes is oldAxes
        if newAxes
          chart[axisName][0].update newAxes
          updateZoom chart[axisName][0], angular.copy(newAxes)
          chart.redraw()
      ), true

    scope.$watch "config.options", ((newOptions, oldOptions, scope) ->

      #do nothing when called on registration
      return  if newOptions is oldOptions
      chart.destroy()
      chart = initialiseChart(scope, element, scope.config)
    ), true
