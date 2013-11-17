app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', 'ChartDataBuilder', ($scope, $http, preprocess, ChartDataBuilder) ->

  ## VARIABLES CONTROLLED BY THE USER IN THE CONTROL PANEL ##
  $scope.datasets = [
  	{'name': 'Example'},
    {'name': 'Basketball'}
  ]

  $scope.numBins = 20
  $scope.selectedDataset = $scope.datasets[0]
  $scope.refEventA =
  $scope.refEventB =

  ###########################################################
  $scope.eventRows = {}
  $scope.eventTypes = []

  records = []
  timeLimits =
    firstTime: moment() # this doesn't work if we have events from the future
    lastTime: 0

  $scope.fetchJSON = () ->
    $http.get('datasets/'+$scope.selectedDataset.name+'.json').success(
      (data) ->
        $scope.eventTypes = preprocess.firstPass(data, records, timeLimits)
        $scope.updateHistograms()
      )

  $scope.updateHistograms = () ->
    binSize = Math.round((timeLimits.lastTime - timeLimits.firstTime) / $scope.numBins) * 2

    # These refEvents are hardcoded to be used as examples.
    $scope.refEvents = [records[0][0], records[0][1]]

    timeSeries = preprocess.buildTimeSeries(records, $scope.eventTypes, $scope.refEvents, binSize, $scope.numBins)

    # Passing around variables to get return values is a very bad practice (but I'm too tired to fix it now)
    ChartDataBuilder.chartsConfig(timeSeries, $scope.eventRows)

  # Fetch the default dataset
  $scope.fetchJSON()
]
