app.service 'charts', () ->
  this.configureMinicharts = (seriesSet, eventRows) ->
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
        #series-specific options
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
  this.configureMainChart = (eventData,chart) ->
    chart.config = {
      options:{
        chart:{
          type: 'areaspline'
        },
        tooltip:{
          formatter:()->
              return "#{this.x}<br/>#{this.points[0].y}<br/>#{this.points[1].y}"
          dateTimeLabelFormats:{
             millisecond: '%H:%M:%S.%L',
             second: '%H:%M:%S',
             minute: '%H:%M',
             hour: '%H:%M',
             day: '%e/%m',
             week: '%e/%m',
             month: '%e/%m/%y',
             year: '%m/%Y'
          }
        },
        xAxis: {
          labels:{


            dateTimeFormats:{
              millisecond: '%H:%M:%S.%L',
              second: '%H:%M:%S',
              minute: '%H:%M',
              hour: '%H:%M',
              day: '%e/%m',
              week: '%e/%m',
              month: '%e/%m/%y',
              year: '%m/%Y'
            }
          },
          range: undefined
        },
      },
      title:{
        text:eventData.name
      },
      rangeSelector : {
        selected : 1
      },
      navigator:{
        enabled:true
      },
      credits: {
        enabled: false
      },


      series:eventData.series,
      useHighStocks:true
    }


