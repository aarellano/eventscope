app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', ($scope, $http, preprocess) ->

  ## VARIABLES CONTROLLED BY THE USER IN THE CONTROL PANEL ##
  $scope.datasets = [
  	{'name': 'Example'},
    {'name': 'Basketball'}
  ]

  $scope.num_bins = 20
  $scope.selectedDataset = $scope.datasets[0]

  ###########################################################

  records = []
  time_limits =
    first_time: moment() # this doesn't work if we have events from the future
    last_time: 0

  $scope.fetchJSON = () ->
    console.log $scope.selectedDataset.name
    $http.get('datasets/'+$scope.selectedDataset.name+'.json').success(
      (data) ->
        $scope.event_types = preprocess.firstPass(data, records, time_limits)

        bin_size = Math.round((time_limits.last_time - time_limits.first_time) / $scope.num_bins)

        # These ref_events are hardcoded to be used as examples.
        $scope.ref_events = [records[0][0], records[0][1]]

        # This call to build_histograms should be bound to selecting ref_events. This is just an example.
        preprocess.build_histograms(records, $scope.event_types, $scope.ref_events, bin_size, $scope.num_bins)
      )

  # Fetch the default dataset
  $scope.fetchJSON()

  # This is just an example to show something on the selected pattern area
  $http.get("datasets/basicAreaChart.json").success (data) ->
    $scope.basicAreaChart = data
]
