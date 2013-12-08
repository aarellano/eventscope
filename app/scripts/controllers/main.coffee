app.controller 'MainCtrl', ['$scope', '$http', 'preprocess', 'charts', 'pairScore', 'distScore',($scope, $http, preprocess, charts, pairScore, distScore) ->

  ## VARIABLES THAT POPULATE USER'S CHOICES##
 $scope.datasets = [
    {'name': 'Example'},
    {'name': 'Basketball'},
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
  $scope.refEvtColors = ['rgb(255,154,0)','rgb(0,100,178)']
  ###########################################################

  ## VARIABLES CONTROLLED BY THE USER IN THE CONTROL PANEL ##
  #size of time bins before/after a reference event
  $scope.options =
    refEventA: null
    refEventB: null
    binSize: 30
    binSizeUnit: $scope.binSizeUnits[1]
    selectedDataset: $scope.datasets[0]
    metSelection: {'or': true, 'pr':false, 'std':false, 'fr':false}
    seriesVisibility: [true, true]
    selectedRow: null
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

  $scope.metrics = [ { name:'Occurrence Ratio', id:'or' }, { name:'Peak Ratio', id:'pr' }, { name:'Standard Dev.', id:'std' }, {name:'Frequency', id:'fr' } ]

  $scope.eventRows = []
  $scope.mainChart = {'name':null, 'config':blankMainChartConfig}


  selectedChart = []
  eventTypes = []
  eventCounts = {}

  exclType = (toExclude) =>
    types = []
    types.push(evtType) for evtType in eventTypes when evtType != toExclude
    types

  records = []
  #max record range in millisecons
  maxRecordMillis = 0

  $scope.fetchJSON = () ->
    $http.get('datasets/'+$scope.options.selectedDataset.name+'.json').success(
      (data) ->
        #reset time limits
        maxRecordMillis =
          firstTime: moment(95617602000000)#year 5000
          lastTime: 0
        [eventTypes, eventCounts, maxRecordMillis] = preprocess.firstPass(data, records)
        [$scope.options.binSize,$scope.options.binSizeUnit] = preprocess.suggestTimeBin(maxRecordMillis,$scope.binSizeUnits)
        eventTypes.sort()
        $scope.refChoicesA = eventTypes
        $scope.refChoicesB = eventTypes
        # The following three lines are just to have default reference events selected.
        # It makes developing easier, but we may want to remove them for the production version (in that case we need to make refEventA and B = null)
        $scope.options.refEventA = eventTypes[0]
        $scope.options.refEventB = eventTypes[1]
        $scope.updateHistograms()
      )

  $scope.updateSelectedRow = (eventData) ->
    $scope.options.selectedRow = eventData
    updateMainChart()

  updateMainChart = () ->
    if $scope.options.selectedRow is null
      $scope.options.selectedRow = {'name':$scope.eventRows[0].eventName, 'series':$scope.eventRows[0].chartConfig.series}
    charts.configureMainChart($scope.options.selectedRow,$scope.mainChart,$scope.refEvtColors)

  $scope.updateHistograms = () ->
    if $scope.options.refEventA and $scope.options.refEventB
      # clear main chart
      $scope.mainChart["config"] = blankMainChartConfig
      binSizeMillis = $scope.options.binSize * $scope.options.binSizeUnit.factor
      numBins = Math.round(maxRecordMillis / binSizeMillis)
      # These refEvents are hardcoded to be used as examples.
      refEvents = [$scope.options.refEventA, $scope.options.refEventB]
      timeSeries = preprocess.buildTimeSeries(records, eventTypes, refEvents, binSizeMillis, numBins, eventCounts)

      # Drug1 in green, emergecy room in light blue, dark blue is exam
      # Sortable is a list of string event names, sorted by their interesting-ness score

      pairScore.computePairScore(timeSeries)
      $scope.eventRows = []
      charts.configureMinicharts(timeSeries, $scope.eventRows, $scope.refEvtColors)
      charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.options.metSelection)

    $scope.refChoicesB = exclType($scope.options.refEventA)
    $scope.refChoicesA = exclType($scope.options.refEventB)

    $scope.options.seriesVisibility = [true, true]
    updateMainChart()

  $scope.scoreBgColor = (score,winRef) ->
    if score and winRef != undefined
      colorStr = $scope.refEvtColors[winRef]
      color = ONECOLOR(colorStr)
      maxLight = color.lightness()
      lightenBy = (1.0 - score) * (1.0 - maxLight)
      newColor = color.lighten(lightenBy)
      {'background-color': newColor.hex()}
    else
      {}

  $scope.checkActiveRow = (eventData) ->
    if $scope.options.selectedRow.name == eventData.name
      "active-row"

  $scope.$watch 'options.metSelection.or', () ->
    charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.options.metSelection)

  $scope.$watch 'options.metSelection.pr', () ->
    charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.options.metSelection)

  $scope.$watch 'options.metSelection.std', () ->
    charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.options.metSelection)

  $scope.$watch 'options.metSelection.fr', () ->
    charts.sortEventRows([1.0,1.0,1.0,1.0],$scope.eventRows,$scope.options.metSelection)

  $scope.updateVisibility = (index) ->
    for row in $scope.eventRows
      row.chartConfig.series[index].visible = !$scope.options.seriesVisibility[index]

  $scope.capitalize = (string) ->
    if string
      (string.split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

  # Fetch the default dataset
  $scope.fetchJSON()

  $scope.tooltips =
    ocurrences:
      title: "Before or after"
      desc: "The occurrence metric determines whether the reference event are unevenly distributed before and after the non-reference event. If reference events occur before and after the non-reference event in roughly the same number, a low score will be returned."
    peaks:
      title: "Peaks before or after"
      desc: "Similar to occurences metrics, this metric determines whether most peaks occur either before or after the non-reference event. Peaks are defined as points in the referene event distribution that are substantially greater than near-by points. "
    std_dev:
      title: "Non-Normal Distributions"
      desc: "Identifies non-reference event distributions that are not normally distributed. "
    frequency:
      title: "Long Period"
      desc: "Periodic behavior of reference events is determined. The period is the inverse of the frequency. Reference events with long periods score highly. Reference events with low periods have a low score. "
    show_hide:
      desc: "Toggle to hide/show histograms"

]
