app.controller 'MainCtrl', ['$scope', '$http', ($scope, $http) ->
  ### Dataset Variables ###
  $scope.datasets = [
  	{'name': 'example'},
    {'name': 'Basketball'},
    {'name': 'Medical'}
  ]
  $scope.categories = []
  $scope.selectedDataset = $scope.datasets[0];
  $scope.data = [];
  $scope.splitAttribute = false; 
  $scope.groups = [ [], [] ] # group A is empty and group B is empty

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
  
  ### TODO NEED SOME CONTROL TO SPLIT THE DATA ###
  $scope.$watch('splitAttribute', (newValue, oldValue, $scope) -> console.log('split update') );
  
  ### Does hist meet support thresh/similarity ###
  interestingScorePair = ( timeSeries ) -> return 1.0; 
  similarityScorePair  = ( timeSeriesA, timeSeriesB ) -> return 1.0; 

  ### Calculate some pair histograms ###
  reHistPair = (data) ->
    console.log('re-creating histograms')
    m = []
    for elem1 in $scope.categories
      m[elem1] = []
      for elem2 in $scope.categories
        m[elem1][elem2] = { }
        m[elem1][elem2]['td'] = []
    for a in data.events
      for b in data.events
        m[a.event][b.event]['td'].push(b.ts - a.ts)
    for a in data.events
      for b in data.events
        m[a.event][b.event]['is'] = interestingScorePair(m[a.event][b.event]['td'])
    ### Not sure what to do with this now, put it in some histograms? ### 
		  
  $scope.$watch('data', (newValue, oldValue, $scope) -> reHistPair(newValue))  
	

	  
	

]



