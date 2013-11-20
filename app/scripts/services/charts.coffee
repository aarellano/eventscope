app.service 'charts', () ->
  this.draw = (seriesSet, eventRows) ->
    seriesLoaded = 0
    eventTypes = Object.keys(seriesSet)
    #assumes every event type has two series
    seriesToLoad = eventTypes.length*2
    for eventType in eventTypes
      seriesArray = seriesSet[eventType]
      logLoad = (e) ->
        seriesLoaded++
        if(seriesLoaded == seriesToLoad)
          $(window).delay(100).trigger('resize')
      config = {
        options: {
          chart: {
            type: 'areaspline',
            margin: [0, 0, 0, 0],
            spacingTop: 0,
            spacingBottom: 0,
            spacingLeft: 0,
            spacingRight: 0,
            height:100,
            events:{
              load: logLoad
            }
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
      eventRows[eventType] = {
        chartConfig: config,
        eventName: eventType
      }


