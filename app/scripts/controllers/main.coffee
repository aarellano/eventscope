app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', 'charts', 'pairScore', 'distScore',($scope, $http, preprocess, charts, pairScore, distScore) ->

  ## VARIABLES THAT POPULATE USER'S CHOICES##
 $scope.datasets = [
    {'name': 'Example'},
    {'name': 'Basketball'},
    {'name': 'Bulls-2012-Season-D2O'},
    {'name': 'Bulls-2012-Season-O2D'}
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
  $scope.metSelection = {'or': true, 'pr':false, 'pe':false, 'fr':false};
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

  $scope.metrics = [ { name:'Occurrence Ratio', id:'or' }, { name:'Peak Ratio', id:'pr' }, { name:'Periodicity', id:'pe' }, {name:'Frequency', id:'fr' } ]

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
        eventTypes.sort()
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

  $scope.round = (number) ->
      Math.round(number * 100) / 100.0

  $scope.sortEventRows = () ->
    for row in $scope.eventRows
        coef0 = 1.0; coef1 = 1.0; coef2 = 1.0; coef3 = 1.0
        row.roundedIntrScore = 0.0
        if $scope.metSelection['or']
          row.roundedIntrScore =  coef0*Math.abs(row.coOccurence[0] - row.coOccurence[1])
        if $scope.metSelection['pr']
          row.roundedIntrScore += coef1*Math.abs(row.peakOccurence[0] - row.peakOccurence[1])
        if $scope.metSelection['pe']
          row.roundedIntrScore += coef2*Math.abs(row.standardDev[0] - row.standardDev[1])
        if $scope.metSelection['fr']
          row.roundedIntrScore += coef3*Math.abs(row.frequency[0] - row.frequency[1])

		# Scale it, to 0 to 1
        row.roundedIntrScore = $scope.round(row.roundedIntrScore / (coef0 + coef1 + coef2 + coef3))
    $scope.eventRows.sort( (a,b) -> return (Math.abs(b.roundedIntrScore) - Math.abs(a.roundedIntrScore)))

  $scope.updateHistograms = () ->
    if $scope.refEventA and $scope.refEventB
      # clear main chart
      $scope.mainChart["config"] = blankMainChartConfig
      binSizeMillis = $scope.binSize*$scope.binSizeUnit.factor
      numBins = Math.round(maxRecordMillis / binSizeMillis)
      # These refEvents are hardcoded to be used as examples.
      refEvents = [$scope.refEventA, $scope.refEventB]
      timeSeries = preprocess.buildTimeSeries(records, eventTypes, refEvents, binSizeMillis, numBins)

      # Drug1 in green, emergecy room in light blue, dark blue is exam
      # Sortable is a list of string event names, sorted by their interesting-ness score

      for item in Object.keys(timeSeries)
        #if ( true ) # TODO TIE TO INTERFACE
        #  pairScore.scaleForNumberOfEvents(timeSeries[item][0].data)
        #  pairScore.scaleForNumberOfEvents(timeSeries[item][0].data)
        a = timeSeries[item][0].data
        b = timeSeries[item][1].data

        timeSeries[item].coOccurence   = [pairScore.CoOccurence2(a), pairScore.CoOccurence2(b)]
        timeSeries[item].standardDev   = [pairScore.standardDeviation2(a), pairScore.standardDeviation2(b)]
        timeSeries[item].peakOccurence = [pairScore.peakOccurence2(a, 100, 3, 0.25), pairScore.peakOccurence2(b, 100, 3, 0.25)]
        timeSeries[item].frequency     = [pairScore.fft2(a), pairScore.fft2(b)]


      # For debugging purposes
      #for item in Object.keys(timeSeries)
      #  console.log(timeSeries[item].coOccurence[0], timeSeries[item].coOccurence[1])
      #  console.log(timeSeries[item].peakOccurence[0], timeSeries[item].peakOccurence[1])
      #  console.log(timeSeries[item].standardDev[0], timeSeries[item].standardDev[1])
      #  console.log(timeSeries[item].frequency[0], timeSeries[item].frequency[1])
      #  console.log("BREAK\n")

      pairScore.normalize(timeSeries) # Normalize all values between 0 and 1
      $scope.eventRows = []
      charts.configureMinicharts(timeSeries, $scope.eventRows)
      $scope.sortEventRows()

    $scope.refChoicesB = exclType($scope.refEventA)
    $scope.refChoicesA = exclType($scope.refEventB)

  # Fetch the default dataset
  $scope.fetchJSON()
]
