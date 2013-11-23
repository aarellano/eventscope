app.service 'charts', () ->
  this.configureMinicharts = (seriesSet, eventRows) ->
    seriesLoaded = 0

    logLoad = (e) ->
      seriesLoaded++
      if(seriesLoaded == seriesToLoad)
        $(window).delay(100).trigger('resize')

    
    eventTypes = Object.keys(seriesSet)
    #assumes every event type has two series
    seriesToLoad = eventTypes.length*2
    for eventType in eventTypes
      seriesArray = seriesSet[eventType]
      pbRange = findPlotbandRange(seriesArray)
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
            plotLines: [{
              value:0,
              color: 'red',
              width: 3,
              zIndex: 3
            }],
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
      roundedScore = Math.round(seriesArray.interestingnessScore * 100) / 100.0
      roundedDist  = Math.round(seriesArray.distinctivenessScore * 100) / 100.0
      obj = { chartConfig: config, eventName: eventType, score: roundedScore, distScore: roundedDist, nonRoundedScore: seriesArray.interestingnessScore}
      eventRows.push( obj )
	  
  this.configureMainChart = (eventData,chart) ->
    formatRelativeTime = (mills) ->
      if mills < 0 then sign = S('-') else sign = S('')
      absMs = Math.abs(mills)

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
      relTimeStr += S("#{hours}:").padLeft(3,'0')
      relTimeStr += S("#{minutes}:").padLeft(3,'0')
      relTimeStr += S("#{seconds}.").padLeft(3,'0')
      relTimeStr += S(milliseconds).padLeft(3,'0')
      relTimeStr

    chart.config = {
      options:{
        chart:{
          type: 'areaspline'
        },
        tooltip:{
          formatter:()->
            tip = formatRelativeTime(this.x)
            if(this.points[0])
              tip +="<br/>#{this.points[0].series.name}:#{this.points[0].y}"
            if(this.points[1])
              tip +="<br/>#{this.points[1].series.name}:#{this.points[1].y}"
            return tip
          
        },
        xAxis: {
          plotLines: [{
            value:0,
            color: 'red',
            width: 3,
            zIndex: 3
          }],
          labels:{
            formatter:()->formatRelativeTime(this.value)
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


