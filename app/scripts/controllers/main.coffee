app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', 'ChartDataBuilder', ($scope, $http, preprocess, ChartDataBuilder) ->

  ## VARIABLES THAT POPULATE USER'S CHOICES##
 $scope.datasets = [
    {'name': 'Example'},
    {'name': 'Basketball'},
    {'name': 'BasketballPartial'}
  ]
  $scope.binSizeUnits = [
    #name: <name of time unit>, factor: <factor to represent in milliseconds>
    {'name': 'hours', 'factor': 3600000},
    {'name': 'minutes', 'factor': 60000},
    {'name': 'seconds', 'factor': 1000}
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
  $scope.selectedTimeUnit = 'minutes'
  ###########################################################

  $scope.eventRows = {}

  eventTypes = []

  exclType = (toExclude) =>
    types = []
    types.push(evtType) for evtType in eventTypes when evtType != toExclude
    types

  records = []
  timeLimits = {}

  $scope.fetchJSON = () ->
    $http.get('datasets/'+$scope.selectedDataset.name+'.json').success(
      (data) ->
        #reset time limits
        timeLimits =
          firstTime: moment() # this doesn't work if we have events from the future
          lastTime: 0
        eventTypes = preprocess.firstPass(data, records, timeLimits)
        $scope.refEventA = null
        $scope.refEventB = null
        $scope.refChoicesA = eventTypes
        $scope.refChoicesB = eventTypes
      )

  $scope.updateHistograms = () ->
    if $scope.refEventA and $scope.refEventB
      binSizeMillis = $scope.binSize*$scope.binSizeUnit.factor
      numBins = Math.round((timeLimits.lastTime - timeLimits.firstTime) / binSizeMillis)
      # These refEvents are hardcoded to be used as examples.
      refEvents = [$scope.refEventA, $scope.refEventB]
      timeSeries = preprocess.buildTimeSeries(records, eventTypes, refEvents, binSizeMillis, numBins)
      # Passing around variables to get return values is a very bad practice (but I'm too tired to fix it now)
      ChartDataBuilder.chartsConfig(timeSeries, $scope.eventRows)
    $scope.refChoicesB = exclType($scope.refEventA)
    $scope.refChoicesA = exclType($scope.refEventB)

  # Fetch the default dataset
  $scope.fetchJSON()
]
