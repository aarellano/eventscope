app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', ($scope, $http, preprocess) ->
  ### Dataset Variables ###
  $scope.datasets = [
  	{'name': 'example'},
    {'name': 'Basketball'},
    {'name': 'Medical'}
  ]
  refEvts = {}

  $scope.categories = []
  $scope.selectedDataset = $scope.datasets[0]
  $scope.data = []
  $scope.records = []
  $scope.splitAttribute = false
  $scope.groups = [ [], [] ] # group A is empty and group B is empty

  ### React to selectDataset selection changes ###
  $scope.$watch('selectedDataset', (newValue, oldValue, $scope) ->
    fetchJSON(newValue.name);
    return newValue; )

  ### Do/handle HTTP Get request ###
  fetchJSON = (fileName) ->
    $http.get('datasets/'+fileName+'.json').success(
      (data) -> $scope.data = data
      )

  ### Update categories for each dataset ###
  $scope.$watch('data', (newValue, oldValue, $scope) ->
    console.log("data trigger")
    $scope.categories = preprocess.firstPass(newValue,$scope.records)
    )

  ### TODO NEED SOME CONTROL TO SPLIT THE DATA ###
  $scope.$watch('splitAttribute', (newValue, oldValue, $scope) -> console.log('split update') );

  ### Does hist meet support thresh/similarity ###
  #interestingScorePair = ( timeSeries ) -> return 1.0;
  #similarityScorePair  = ( timeSeriesA, timeSeriesB ) -> return 1.0;

  ### Calculate some pair histograms ###

  ###
    reHistPair = (data) ->
        console.log('re-creating histograms')
        m = []
        for elem1 in $scope.categories
          m[elem1] = []
          for elem2 in $scope.categories
            m[elem1][elem2] = { }
            m[elem1][elem2]['td'] = []
        if data.events
          for a in data.events
            for b in data.events
              m[a.event][b.event]['td'].push(b.ts - a.ts)
          for a in data.events
            for b in data.events
              m[a.event][b.event]['is'] = interestingScorePair(m[a.event][b.event]['td'])###

  ### Not sure what to do with this now, put it in some histograms? ###

  #$scope.$watch('data', (newValue, oldValue, $scope) -> reHistPair(newValue))



  $http.get("datasets/basicAreaChart.json").success (data) ->
    $scope.basicAreaChart = data

  $scope.setRefEvt = (category) ->
    if refEvts[category]
      #remove event from selection
      delete refEvts[category]
      console.log "deselected #{category}"
    else
      if Object.keys(refEvts).length >= 2
        console.log "replaced #{Object.keys(refEvts)[1]} with #{category}"
        #adding would cause overflow - replace one of the selected events
        delete refEvts[Object.keys(refEvts)[1]]
      else
        console.log "selected #{category}"
      #add event to selection
      refEvts[category] = true
]





