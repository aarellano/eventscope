app.service 'preprocess', () ->
  this.firstPass = (json, records, timeLimits) ->
    # -makes the first pass over the data
    # -converts time strings to moment objects (see moment.js documentation)
    # -aggregates the unique event types into the 'eventTypes' array
    # -aggregates events into records
    # @param json: raw data - an array of objects of form
    #       {'event':'<event type here>'
    #         'ts':'<start of event>'
    #         'te':'<end of event>'
    #         'id':'<id of the record where the event occured (game/patient/etc.)>'
    #       }
    # @param records: an empty array to be populated with records
    # @param timeLimits: an object with two properties: firstTime and lastTime
    recordHash = {}
    if json.events
      eventTypes = {}
      for p in json.events
        #add new category if not present
        eventTypes[p.event] = true if p.event not in eventTypes
        #convert time string to moment
        if p.ts
          p.ts = moment(p.ts)
          #upgrade the time limits if necessary
          if p.ts.isBefore(timeLimits.firstTime) then timeLimits.firstTime = p.ts
          if p.ts.isAfter(timeLimits.lastTime) then timeLimits.lastTime = p.ts
          if p.te
            p.te = moment(p.te)
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
          if(a.ts > b.ts)
            1
          else if(b.ts > a.ts)
            -1
          else
            0
          )
        records.push(recordHash[recordId])

      eventTypesArray = []
      for key of eventTypes
        eventTypesArray.push key

      return eventTypesArray

  this.buildTimeSeries = (records, eventTypes, refEvents, binSize, numBins) ->
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
            hists[eventType][refEvent][i] = 0

    computeBinNumber = (refTime, nonrefTime) => Math.round(refTime.diff(nonrefTime) / binSize) + (numBins/2)

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
              hists[nonrefEvt][entry.event][binNum] +=1

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
              hists[entry.event][refEvent][binNum] +=1
    console.log(hists)
    hists
