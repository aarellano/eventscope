app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', 'ChartDataBuilder', ($scope, $http, preprocess, ChartDataBuilder) ->

  ## VARIABLES CONTROLLED BY THE USER IN THE CONTROL PANEL ##
  $scope.datasets = [
  	{'name': 'Example'},
    {'name': 'Basketball'},
    {'name': 'BasketballPartial'}
  ]

  #number of time bins before/after a reference event
  $scope.numBins = 20
  $scope.refEventA = null
  $scope.refEventB = null
  $scope.selectedDataset = $scope.datasets[0]
  ###########################################################
  $scope.refChoicesA = null
  $scope.refChoicesB = null
  $scope.eventRows = {}
  eventTypes = []

  exclType = (toExclude) =>
    types = []
    for evtType in eventTypes
      if toExclude != evtType
        types.push(evtType)
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
      binSize = (timeLimits.lastTime - timeLimits.firstTime) / $scope.numBins
      # These refEvents are hardcoded to be used as examples.
      refEvents = [$scope.refEventA, $scope.refEventB]
      timeSeries = preprocess.buildTimeSeries(records, eventTypes, refEvents, binSize, $scope.numBins)
      # Passing around variables to get return values is a very bad practice (but I'm too tired to fix it now)
      ChartDataBuilder.chartsConfig(timeSeries, $scope.eventRows)
    $scope.refChoicesB = exclType($scope.refEventA)
    $scope.refChoicesA = exclType($scope.refEventB)

  # Fetch the default dataset
  $scope.fetchJSON()
]
