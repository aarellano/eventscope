app.service 'preprocess', () ->
  this.firstPass = (json, records) ->
    # -makes the first pass over the data
    # -converts time strings to moment objects (see moment.js documentation)
    # -aggregates the unique event types into the 'eventTypes' array
    # -aggregates events into records sorted by time
    # -computes the maximum record time range in milliseconds
    # @param json: raw data - an array of objects of form
    #       {'event':'<event type here>'
    #         'ts':'<start of event>'
    #         'te':'<end of event>'
    #         'id':'<id of the record where the event occured (game/patient/etc.)>'
    #       }
    # @param records: an empty array to be populated with records
    # @return: [an array of unique eventTypes (strings), maximum record time range]
    recordHash = {}
    maxRecordMillis = 0
    if json.events
      #determine how to parse date - if only time is given, follow the time format
      #assume all dates are formatted in the same way
      firstTime = json.events[0].ts
      if(firstTime and moment(firstTime).isValid())
        parseDate = (dateStr) -> moment(dateStr)
      else
        #only time given (date + date & time combinations are pretty hard to mess up for moment.js)\
        #assume maximums are 24 hours, 59 minutes, etc.
        getColonFormat = (timeStr) ->
          splitColon = timeStr.split(':')
          if splitColon.length == 3
            splitColon = timeStr.split(':')
            formatString = "HH:mm:ss"
          else if splitColon.length == 2
            formatString = "mm:ss"
          else if splitColon.length == 1
            formatString = "s"
          else
            formatString = null
          formatString

        splitPeriod = firstTime.split('.')
        if splitPeriod.length > 1
          if splitPeriod.length == 4
            formatString = "HH.mm.ss.nnn"
          else if splitPeriod.length == 3
            formatString = "HH.mm.ss"
          else if splitPeriod.length == 2
            #milliseconds at the end
            formatString = getColonFormat(splitPeriod[0])
            #add them on
            if formatString then formatString += ".nnn"
          else
            formatString = null
        else
          #no milliseconds, just time
          formatString = getColonFormat(firstTime)

        if not formatString
          console.log("Invalid Date Format: #{firstTime}")
          return
        parseDate = (dateStr) -> moment(dateStr, formatString)

      eventTypes = {}
      for p in json.events
        #add new category if not present
        eventTypes[p.event] = true if p.event not in eventTypes
        #convert time string to moment
        if p.ts
          newTime = parseDate(p.ts)
          if(not newTime.isValid())
            console.log(p.ts)
          p.ts = newTime
          #upgrade the time limits if necessary
          if p.te
            p.te = parseDate(p.te)
        #aggregate records
        if p.id.toString() in Object.keys(recordHash)
          record = recordHash[p.id]
          record.push(p)
        else
          record = [p]
          recordHash[p.id] = record
      for recordId in  Object.keys(recordHash)
        record = recordHash[recordId]
        #sort the records based on time
        record.sort((a,b)->
          if(a.ts > b.ts) then 1 else if(b.ts > a.ts) then -1 else 0)
        #compute the max range
        recordRangeMillis = record[record.length-1].ts.diff(record[0].ts)
        #keep track of the max range
        maxRecordMillis = recordRangeMillis if recordRangeMillis > maxRecordMillis
        records.push(recordHash[recordId])

      eventTypesArray = []
      for key of eventTypes
        eventTypesArray.push key

      [eventTypesArray, maxRecordMillis]

  this.suggestTimeBin = (maxRecordMillis, binTimeUnits) ->
    #@param
    #sugguest closest whole time unit to making 20 bins / record,
    #or 20 on either side of the ref event (40 total)
    binSizeMillis = maxRecordMillis / 20
    curUnit = binTimeUnits[0]
    if binSizeMillis < curUnit.factor
      [1,curUnit]
    else
      for iUnit in [1...binTimeUnits.length]
        nextUnit = binTimeUnits[iUnit]
        #check if bin size exceeds the next unit's
        #duration in milliseconds
        if binSizeMillis < nextUnit.factor
          #if no, return in current units
          return [Math.round(binSizeMillis / curUnit.factor), curUnit]
        curUnit = nextUnit#if yes, continue
      #return in biggest units
      [Math.round(binSizeMillis / curUnit.factor), curUnit]

  this.buildTimeSeries = (records, eventTypes, refEvents, binSizeMilis, numBins) ->
    #Creates 2 frequency series for each non-reference event, one relative to each of the
    #reference events.
    #@param records: event records (arrays of events pertaining to the same sequence), where
    #each event has the form:
    #       {'event':'<event type here>'
    #         'ts':'<start of event>'
    #         'te':'<end of event>'
    #         'id':'<id of the record where the event occured (game/patient/etc.)>'
    #       }
    #@param eventTypes: a set of unique event types, as an array of strings
    #@param refEvents: an array of two reference event types (strings)
    #@param binSizeMillis: time bin size in milliseconds
    #@param numBins: maximum number of time bins in any record
    #@return series hash of the form:
    # {
    #   '<non-ref event 1>': [
    #      {
    #         'name':'<ref event 1>',
    #         'data':[
    #                  {
    #                    x:<time bin 1>,
    #                    y:<bin 1 count>
    #                  },
    #                  {
    #                    x:<time bin 2>,
    #                    y:<bin 2 count>
    #                  },
    #                  ...
    #                 ]
    #      },
    #      {
    #         'name':'<ref event 2>'
    #         'data':-||-
    #      }
    #    ]
    #   '<non-ref event 2>': [-||-]
    #   '<non-ref event 3>': [-||-]
    #   ...
    # }

    #maximum bin count now doubles, because we could have both
    #ref and non-ref at the end and the beginning of a dataset
    numBins *=2
    # Initialize all the distribution values to zero. It could be done in the next loop, but it's very short
    hists = {}
    for eventType in eventTypes
      if(eventType not in refEvents)
        #create histogram pair for that non-reference event
        hists[eventType] = {}
        for refEvent in refEvents
          #create distribution for that event pair
          hists[eventType][refEvent] = []
          for i in [0..(numBins-1)]
            #zero out intial values
            hists[eventType][refEvent][i] = {y:0,x:(i - numBins / 2)*binSizeMilis}

    computeBinNumber = (refTime, nonrefTime) ->
      bin = Math.round(refTime.diff(nonrefTime) / binSizeMilis) + (numBins / 2)

    for record in records
      occursNonref = {}
      occursRef = {}
      occursRef[refEvents[0]] = []
      occursRef[refEvents[1]] = []
      for entry in record
        if entry.event in refEvents
          #current event is a reference event, add it to its ref event array
          occursRef[entry.event].push(entry.ts)
          for nonrefEvt of occursNonref
            nonrefOccurArr = occursNonref[nonrefEvt]
            #bin all non-ref occurences preceding this one
            for occurTime in nonrefOccurArr
              #calulate every non-ref event's bin in reference to the current (reference) event
              binNum = computeBinNumber(entry.ts,occurTime)
              #increment the bin counter
              hists[nonrefEvt][entry.event][binNum].y +=1
        else
          #current event is a non-reference event, add it to its nonref event array
          if entry.event not in occursNonref then occursNonref[entry.event] = []
          occursNonref[entry.event].push(entry.ts)
          for refEvent of occursRef
            refOccurArr = occursRef[refEvent]
            #bin this event for all ref occurences preceding this one
            for occurTime in refOccurArr
              #calulate this event's bin in reference to every preceding ref event
              binNum = computeBinNumber(occurTime,entry.ts)
              #console.log(occurTime.diff(entry.ts))
              hists[entry.event][refEvent][binNum].y+=1
    #make a quick pass eliminating the zeroes
    for evtType of hists
      series = []
      for refEvtType of hists[evtType]
        hist = hists[evtType][refEvtType]
        ixFirst = 0
        #find first non-zero element
        ixFirst++ while ixFirst < hist.length and not hist[ixFirst].y
        ixLast = hist.length-1
        ixLast-- while ixLast >= 0 and not hist[ixLast].y
        newHist = hist[ixFirst..ixLast]
        series.push({'name': refEvtType, 'data': newHist})# if newHist.length > 0
      hists[evtType] = series
    hists
