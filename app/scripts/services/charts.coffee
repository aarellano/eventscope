app.service 'charts', () ->
  this.chartsConfig = (frequenciesSet, eventRows) ->
    for eventType of frequenciesSet
      seriesArray = []
      for refEvent, myvalue of frequenciesSet[eventType]
        unless refEvent == eventType
          seriesArray.push({'name': refEvent, 'data': myvalue})

      # If the lenght == 1 then series are in between the refEvents
      # To extend this to more than two refEvents, the hardcoded '1' should be (# of refEvents - 1)
      if seriesArray.length > 1
        config = {
          options: {
            chart: {
              type: 'areaspline',
              margin: [0, 0, 0, 0],
              spacingTop: 0,
              spacingBottom: 0,
              spacingLeft: 0,
              spacingRight: 0
            },
            plotOptions: {
              series: {
                  stacking: ''
              }
            },
            xAxis: {
              labels:{
                enabled: false
              }
            },
            yAxis: {
              title: {
                text: ''
              },
              labels:{
                enabled: false
              }
            }
            legend:{
              enabled:false
            }
          },
          series: seriesArray,
          title: {
            text: ''
          },
          credits: {
            enabled: false
          },
          loading: false
        }
        eventRows[eventType] = {chartConfig: []}
        eventRows[eventType].chartConfig = config
        eventRows[eventType].eventName = eventType
