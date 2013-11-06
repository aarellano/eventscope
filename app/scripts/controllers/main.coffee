app.controller 'MainCtrl', ['$scope', '$http', ($scope, $http) ->
  $scope.categories = [
    {'name': 'Opponent Offense'},
    {'name': 'CHICAGO Offense'},
    {'name': 'Defensive Rebound'},
    {'name': 'Offensive Rebound'},
    {'name': 'Made Shot - 2'},
    {'name': 'Made Shot - 3'},
    {'name': 'Missed Shot - 2'},
    {'name': 'Missed Shot - 3'},
    {'name': 'Steal'},
    {'name': 'Timeout'},
    {'name': 'Turnover'},
    {'name': 'Foul'},
    {'name': 'Block'},
    {'name': 'Missed Free Throw'},
    {'name': 'Made Free Throw'},
    {'name': 'End of Period'},
    {'name': 'Jump Ball'},
    {'name': 'Dead Ball'}
  ]
  
  ### Dataset Variables ###
  $scope.datasets = [
  	{'name': 'example'},
    {'name': 'Basketball'},
    {'name': 'Medical'}
  ]
  $scope.selectedDataset = $scope.datasets[0];
  $scope.data = false;

  ### Do/handle HTTP Get request ###
  cb = (data) -> console.log(data.glossary.title); $scope.data = data;
  fetchJSON = (fileName) -> $http.get('datasets/'+fileName+'.json').success( cb );
  
  ### React to selectDataset selection changes ###
  $scope.$watch('selectedDataset', (newValue, oldValue, $scope) -> console.log(oldValue.name + '->' +newValue.name); fetchJSON(newValue.name); return newValue; )
  
]



