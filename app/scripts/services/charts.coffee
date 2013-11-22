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
            if this.x < 0 then sign = '-' else sign = ''
            absMs = Math.abs(this.x)

            msInSeconds = 1000
            msInMinutes = msInSeconds * 60
            msInHours = msInMinutes * 60
            msInDays = msInHours * 24

            days = absMs / msInDays
            remainder = absMs % msInDays
            hours = remainder / msInHours
            remainder %= msInHours
            minutes = remainder / msInMinutes
            remainder %= msInMinutes
            seconds = remainder / msInSeconds
            milliseconds = remainder % msInSeconds

            relTimeStr = sign
            if days > 1 then relTimeStr += "#{days} days " else if days == 1 then relTimeStr += "1 day "
            if hours > 10 then relTimeStr += "#{hours}:" else if hours > 0 then relTimeStr += "0#{hours}:"
            if minutes > 10 then relTimeStr += "#{minutes}:" else relTimeStr += "0#{minutes}:"
            if seconds > 10 then relTimeStr += "#{seconds}." else relTimeStr += "0#{seconds}."
            if milliseconds > 100
              relTimeStr += milliseconds 
            else if milliseconds > 10 
              relTimeStr += "0#{milliseconds}"
            else
              relTimeStr += "00#{milliseconds}"

            return "#{relTimeStr}<br/>#{this.points[0].series.name}:#{this.points[0].y}<br/>#{this.points[1].series.name}:#{this.points[1].y}"
          
        },
        xAxis: {
          labels:{
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


