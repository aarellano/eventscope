app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', ($scope, $http, preprocess) ->
  # Dataset Variables
  $scope.datasets = [
  	{'name': 'Example'},
    {'name': 'Basketball'}
  ]

  $scope.records = []
  $scope.selectedDataset = $scope.datasets[0]

  # Do/handle HTTP Get request
  $scope.fetchJSON = () ->
    console.log $scope.selectedDataset.name
    $http.get('datasets/'+$scope.selectedDataset.name+'.json').success(
      (data) -> $scope.categories = preprocess.firstPass(data, $scope.records)
      )

  # This is just an example to show something on the selected pattern area
  $http.get("datasets/basicAreaChart.json").success (data) ->
    $scope.basicAreaChart = data

]
