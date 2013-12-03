app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', 'charts', 'pairScore', 'distScore',($scope, $http, preprocess, charts, pairScore, distScore) ->

  ## VARIABLES THAT POPULATE USER'S CHOICES##
 $scope.datasets = [
    {'name': 'Example'},
    {'name': 'Basketball'},
  ]
  #bin size units: keep this sorted by factor!
  $scope.binSizeUnits = [
    #name: <name of time unit>, factor: <factor to represent in milliseconds>
    {'name': 'seconds', 'factor': 1000},
    {'name': 'minutes', 'factor': 60000},
    {'name': 'hours', 'factor': 3600000},
  ]
  $scope.refChoicesA = null
  $scope.refChoicesB = null
  ###########################################################

  ## VARIABLES CONTROLLED BY THE USER IN THE CONTROL PANEL ##
  #size of time bins before/after a reference event
  $scope.binSize = 30
  $scope.binSizeUnit = $scope.binSizeUnits[1]
  $scope.refEventA = null
  $scope.refEventB = null
  $scope.selectedDataset = $scope.datasets[0]
  $scope.metSelection = {'or': true, 'pr':false, 'pe':false, 'fr':false}
  $scope.seriesVisibility = [true, true]
  $scope.refEvtColors = ['rgb(255,154,0)','rgb(0,100,178)']
  ###########################################################

  blankMainChartConfig = {
    subtitle:{
      text:"With the data loaded and reference events chosen, click on event row in left panel to view detailed chart"
    },
    credits: {
      enabled: false
    },
    useHighStocks:true
  }

  $scope.metrics = [ { name:'Occurrence Ratio', id:'or' }, { name:'Peak Ratio', id:'pr' }, { name:'Periodicity', id:'pe' }, {name:'Frequency', id:'fr' } ]

  $scope.eventRows = []
  $scope.mainChart = {'name':null, 'config':blankMainChartConfig}


  selectedChart = []
  eventTypes = []
  eventCounts = {}

  exclType = (toExclude) =>
    types = []
    types.push(evtType) for evtType in eventTypes when evtType != toExclude
    types

  records = []
  #max record range in millisecons
  maxRecordMillis = 0

  $scope.fetchJSON = () ->
    $http.get('datasets/'+$scope.selectedDataset.name+'.json').success(
      (data) ->
        #reset time limits
        maxRecordMillis =
          firstTime: moment(95617602000000)#year 5000
          lastTime: 0
        [eventTypes, eventCounts, maxRecordMillis] = preprocess.firstPass(data, records)
        [$scope.binSize,$scope.binSizeUnit] = preprocess.suggestTimeBin(maxRecordMillis,$scope.binSizeUnits)
        eventTypes.sort()
        $scope.refChoicesA = eventTypes
        $scope.refChoicesB = eventTypes
        # The following three lines are just to have default reference events selected.
        # It makes developing easier, but we may want to remove them for the production version (in that case we need to make refEventA and B = null)
        $scope.refEventA = eventTypes[0]
        $scope.refEventB = eventTypes[1]
        $scope.updateHistograms()
      )

  $scope.updateMainChart = (eventData) ->
    charts.configureMainChart(eventData,$scope.mainChart,$scope.refEvtColors)

  $scope.updateHistograms = () ->
    if $scope.refEventA and $scope.refEventB
      # clear main chart
      $scope.mainChart["config"] = blankMainChartConfig
      binSizeMillis = $scope.binSize*$scope.binSizeUnit.factor
      numBins = Math.round(maxRecordMillis / binSizeMillis)
      # These refEvents are hardcoded to be used as examples.
      refEvents = [$scope.refEventA, $scope.refEventB]
      timeSeries = preprocess.buildTimeSeries(records, eventTypes, refEvents, binSizeMillis, numBins, eventCounts)

      # Drug1 in green, emergecy room in light blue, dark blue is exam
      # Sortable is a list of string event names, sorted by their interesting-ness score

      pairScore.computePairScore(timeSeries)
      $scope.eventRows = []
      charts.configureMinicharts(timeSeries, $scope.eventRows, $scope.refEvtColors)
      charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.metSelection)

    $scope.refChoicesB = exclType($scope.refEventA)
    $scope.refChoicesA = exclType($scope.refEventB)

    $scope.seriesVisibility = [true, true]

  $scope.scoreBgColor = (score,winRef) ->
    if score and winRef != undefined
      colorStr = $scope.refEvtColors[winRef]
      color = ONECOLOR(colorStr)
      maxLight = color.lightness()
      lightenBy = (1.0 - score) * (1.0 - maxLight)
      newColor = color.lighten(lightenBy)
      {'background-color': newColor.hex()}
    else
      {}

  $scope.$watch 'metSelection.or', () ->
    charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.metSelection)

  $scope.$watch 'metSelection.pr', () ->
    charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.metSelection)

  $scope.$watch 'metSelection.pe', () ->
    charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.metSelection)

  $scope.$watch 'metSelection.fr', () ->
    charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.metSelection)

  $scope.updateVisibility = (index) ->
    for row in $scope.eventRows
      row.chartConfig.series[index].visible = !$scope.seriesVisibility[index]

  $scope.capitalize = (string) ->
    if string
      (string.split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

  # Fetch the default dataset
  $scope.fetchJSON()
]
