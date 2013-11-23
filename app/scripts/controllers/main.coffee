app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', 'charts', 'pairScore', 'distScore',($scope, $http, preprocess, charts, pairScore, distScore) ->

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
    credits: {
      enabled: false
    },
    useHighStocks:true
  }

  $scope.eventRows = []
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
          firstTime: moment(95617602000000)#year 5000
          lastTime: 0
        [eventTypes, maxRecordMillis] = preprocess.firstPass(data, records)
        [$scope.binSize,$scope.binSizeUnit] = preprocess.suggestTimeBin(maxRecordMillis,$scope.binSizeUnits)
        $scope.refChoicesA = eventTypes
        $scope.refChoicesB = eventTypes
        # The following three lines are just to have default reference events selected.
        # It makes developing easier, but we may want to remove them for the production version (in that case we need to make refEventA and B = null)
        $scope.refEventA = eventTypes[0]
        $scope.refEventB = eventTypes[1]
        $scope.updateHistograms()
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

      # Drug1 in green, emergecy room in light blue, dark blue is exam
      # Sortable is a list of string event names, sorted by their interesting-ness score
      for item in Object.keys(timeSeries)
         a = timeSeries[item][0].data
         b = timeSeries[item][1].data

		 # Not sure how to aggregate the two scores 
         # Not sure how to combine the scores
         # Not sure how to highlight wat is important in the graphs
         timeSeries[item].coOccurence    = pairScore.max(pairScore.CoOccurence2(a), pairScore.CoOccurence2(b))
         #timeSeries[item].standardDev   = pairScore.max(pairScore.standardDeviation2(a), pairScore.standardDeviation2(a))
         #timeSeries[item].peakOccurence = pairScore.max(pairScore.peakOccurence2(a, 100, 3, 0.25), pairScore.peakOccurence2(a, 100, 3, 0.25))
         #timeSeries[item].frequency     = pairScore.max(pairScore.fft2(a), pairScore.fft2(b))
		 
         timeSeries[item].interestingnessScore = timeSeries[item].coOccurence
         timeSeries[item].distinctivenessScore = distScore.score(a, b)


      $scope.eventRows = []
      l = [] 
      charts.configureMinicharts(timeSeries, l)
      l.sort( (a,b) -> 
        return (Math.abs(b.nonRoundedScore) - Math.abs(a.nonRoundedScore)))
      $scope.eventRows = l

    $scope.refChoicesB = exclType($scope.refEventA)
    $scope.refChoicesA = exclType($scope.refEventB)

  # Fetch the default dataset
  $scope.fetchJSON()
]
