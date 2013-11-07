app.controller 'MainCtrl', ['$scope', '$http', ($scope, $http) ->
  ### Dataset Variables ###
  $scope.datasets = [
  	{'name': 'example'},
    {'name': 'Basketball'},
    {'name': 'Medical'}
  ]
  $scope.categories = []
  $scope.selectedDataset = $scope.datasets[0];
  $scope.data = false;

  ### Do/handle HTTP Get request ###
  cb = (data) -> $scope.data = data;
  fetchJSON = (fileName) -> $http.get('datasets/'+fileName+'.json').success( cb );
  
  ### React to selectDataset selection changes ###
  $scope.$watch('selectedDataset', (newValue, oldValue, $scope) -> fetchJSON(newValue.name); return newValue; )
  
  ### Edit scope.categories ###
  updateCategories = (json) -> 
    $scope.categories = []
    for p in json.events
      $scope.categories.push(p.event) if $scope.categories.indexOf(p.event) == -1
	

  ### Update categories for each dataset ###
  $scope.$watch('data', (newValue, oldValue, $scope) -> updateCategories(newValue) );
  
]



