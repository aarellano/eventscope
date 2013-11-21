app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', 'charts', ($scope, $http, preprocess, charts) ->

  ## VARIABLES THAT POPULATE USER'S CHOICES##
 $scope.datasets = [
    {'name': 'Example'},
    {'name': 'Basketball'}
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
  ###########################################################

  blankMainChartConfig = {
    subtitle:{
      text:"With the data loaded and reference events chosen, click on event row in left panel to view detailed chart"
    },
    useHighStocks:true
  }

  $scope.eventRows = {}
  $scope.mainChart = {'name':null, 'config':blankMainChartConfig}

  selectedChart = []
  eventTypes = []

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
          firstTime: moment() # this doesn't work if we have events from the future
          lastTime: 0
        [eventTypes, maxRecordMillis] = preprocess.firstPass(data, records)
        [$scope.binSize,$scope.binSizeUnit] = preprocess.suggestTimeBin(maxRecordMillis,$scope.binSizeUnits)
        $scope.refEventA = null
        $scope.refEventB = null
        $scope.refChoicesA = eventTypes
        $scope.refChoicesB = eventTypes
      )

  $scope.updateMainChart = (eventData) ->
    charts.configureMainChart(eventData,$scope.mainChart)

  $scope.updateHistograms = () ->
    if $scope.refEventA and $scope.refEventB
      binSizeMillis = $scope.binSize*$scope.binSizeUnit.factor
      numBins = Math.round(maxRecordMillis / binSizeMillis)
      # These refEvents are hardcoded to be used as examples.
      refEvents = [$scope.refEventA, $scope.refEventB]
      timeSeries = preprocess.buildTimeSeries(records, eventTypes, refEvents, binSizeMillis, numBins)
      # Passing around variables to get return values is a very bad practice (but I'm too tired to fix it now)
      charts.configureMinicharts(timeSeries, $scope.eventRows, $scope.updateMainChart)
    $scope.refChoicesB = exclType($scope.refEventA)
    $scope.refChoicesA = exclType($scope.refEventB)

  # Fetch the default dataset
  $scope.fetchJSON()
]
