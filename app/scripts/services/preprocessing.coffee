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
    # @timeLimits: an object with two properties: firstTime and lastTime
    recordHash = {}
    if json.events
      eventTypes = {}
      for p in json.events
        #add new category if not present
        eventTypes[p.event] = true if p.event not in eventTypes
        #convert time string to moment
        if p.ts
          p.ts = moment(p.ts)
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
        eventTypesArray.push { name: key }

      return eventTypesArray

  this.buildTimeSeries = (records, eventTypes, refEvents, binSize, numBins) ->
    # Initialize all the distribution values to zero. It could be done in the next loop, but it's very short
    hists = {}
    for eventType in eventTypes
      hists[eventType.name] = {}
      for refEvent in refEvents
        hists[eventType.name][refEvent.event] = []
        for i in [0..(numBins-1)]
          hists[eventType.name][refEvent.event][i] = 0

    for record in records
      for entry in record
        for refEvent in refEvents
          if entry.event isnt refEvent.event
            bin_number = Math.round(refEvent.ts.diff(entry.ts) / binSize) + (numBins / 2)
            hists[entry.event][refEvent.event][bin_number] += 1

    hists
