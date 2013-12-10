app.service 'pairScore', () ->
  this.computePairScore = (timeSeries)->
    for item in Object.keys(timeSeries)
      #if ( true ) # TODO TIE TO INTERFACE
      #  this.scaleForNumberOfEvents(timeSeries[item][0].data)
      #  this.scaleForNumberOfEvents(timeSeries[item][1].data)
      a = timeSeries[item][0].data
      b = timeSeries[item][1].data

      timeSeries[item].coOccurence   = [this.coOccurence(a), this.coOccurence(b)]
      timeSeries[item].peakOccurence = [this.peakOccurence(a, 100, 3, 0.25), this.peakOccurence(b, 100, 3, 0.25)]
      timeSeries[item].standardDev   = [this.standardDeviation(a), this.standardDeviation(b)]
      timeSeries[item].frequency     = [this.fft(a), this.fft(b)]
    this.normalize(timeSeries) # Normalize all values between 0 and 1

  this.max = (a, b) ->
    if a > b
      return a
    return b

  this.arrMax = (arr) ->
      if(arr.length <= 0)
         return 0.0
      m = arr[0]
      for i in [0..(arr.length-1)]
        if arr[i] > m
          m = arr[i]
      return m

  this.serieMax = (arr) ->
    if(arr.length <= 0)
       return 0.0
    m = arr[0].x
    for i in [0..(arr.length-1)]
      if arr[i].x > m
        m = arr[i].x
    return m

  this.arrMin = (arr) ->
      if(arr.length <= 0)
         return 0.0
      m = arr[0]
      for i in [0..(arr.length-1)]
        if arr[i] < m
          m = arr[i]
      return m

  this.serieMin = (arr) ->
    if(arr.length <= 0)
       return 0.0
    m = arr[0].x
    for i in [0..(arr.length-1)]
      if arr[i].x < m
        m = arr[i].x
    return m

  this.min = (a, b) ->
    if a < b
      return a
    return b

  this.mean = (arr) ->
    sum = 0.0
    items = 0.0
    for i in [0..arr.length-1]
      # Position (or value) * count of that value
      sum += (arr[i].x * arr[i].y)
      items += arr[i].y
    return sum/items

  this.standardDeviation = (a) ->
    if(a.length == 0)
       return 0.0
    mean = this.mean(a)
    items = 0.0
    difference = 0.0
    for i in [0..a.length-1]
      difference = difference + (a[i].y * Math.pow(mean - a[i].x, 2))
      items += a[i].y
    return Math.sqrt(difference/items)

  this.coOccurence = (timeSeries) ->
    before = 0
    after  = 0
    result = 0.0
    if(timeSeries.length > 0)
      for i in [0..timeSeries.length-1]
        if timeSeries[i].x > 0
          after = after + timeSeries[i].y
        else if timeSeries[i].x < 0
          before = before + timeSeries[i].y
      result = 2.0 * this.max(before, after)/(before + after) - 1.0
    return result

  this.indexof = (elem, nbins, max, min) ->
    #if(elem < min)
    #  return -1
    #if(elem > max) # Dosent matter if this is an actually index into the array
    #  return nBins + 1
    return Math.floor((( elem - min ) / ( max - min ))* (nbins*1.0))

  this.findPeakLocations = (timeSeries, nbins, k, threshold, max, min) ->
    arr = Array(nbins)
    peaks = Array()
    for i in [0...nbins] #possibly here?
      arr[i] = 0.0
    # build a histogram
    for i in [0...timeSeries.length]
      idx = this.indexof(timeSeries[i].x, nbins, max, min)
      arr[idx] = arr[idx] + timeSeries[i].y
    # find the number of peaks
    for i in [k..nbins-2-k]
      score = (this.arrMax(arr[(i-k)..]) + this.arrMax(arr[i+1+k..])) / 2.0
      if score > threshold
        peaks.push(i)
    return peaks

  # nbins in the number of bins in the hist
  # k is the sliding window for peak detection
  # threshold is the threshold for peak detection
  this.peakOccurence = (timeSeries, nbins, k, threshold) ->
    if(timeSeries.length <= 1)
        return 0.0
    max = this.serieMax(timeSeries)
    min = this.serieMin(timeSeries)
    peaks = this.findPeakLocations(timeSeries, nbins, k, threshold, max, min)
    refIdx = this.indexof(0, nbins, max, min)
    before = 0
    after  = 0
    result = 0.0
    for i in [0...peaks.length]
        if peaks[i] > refIdx
          after = after + 1
        else if peaks[i] < refIdx
          before = before + 1
        # else, do nothing ignore it
    result = 2.0 * this.max(before, after)/(before + after) - 1
    return result

  this.nItems = (a) ->
    items = 0.0
    for elem in a
      items += elem.y
    return items

  this.zeroArray = (size) ->
    a = Array(Math.round(size))#TODO: does this still work w/ non-integers?
    for i in [0..(size-1)]
      a[i] = 0.0
    return a

  this.fft = (a) ->
    if(a.length <= 0)
        return 0.0

    nItems = this.nItems(a)

    x_real = this.zeroArray(nItems)
    x_imag = this.zeroArray(nItems)
    x_mag  = this.zeroArray(nItems)
    for k in [0..nItems-1]
      for n in [0..a.length-1]
        exponent = -2 * Math.PI * k * (n/nItems)
        x_real[k] += (a[n].y * a[n].x * Math.cos(exponent))
        x_imag[k] += (a[n].y * a[n].x * Math.sin(exponent))
      x_mag[k] = Math.sqrt(Math.pow(x_real[k], 2) + Math.pow(x_imag[k], 2))
    return 1.0/this.arrMax(x_mag)

  this.scale = (value, max, min) ->
    if max == min
      return 0.0
    return (value - min)/(max - min)

  this.normalize = (timeSeries) ->
    m = -9999999999.0  # pragmatic
    mi=  9999999999.0
    maxCo = m; maxSt = m;  maxPk = m;  maxFr = m;
    minCo = mi; minSt = mi; minPk = mi; minFr = mi;
    for item in Object.keys(timeSeries)
      maxCo = this.max(maxCo, this.arrMax(timeSeries[item].coOccurence))
      minCo = this.min(minCo, this.arrMin(timeSeries[item].coOccurence))
      maxSt = this.max(maxSt, this.arrMax(timeSeries[item].standardDev))
      minSt = this.min(minSt, this.arrMin(timeSeries[item].standardDev))
      maxPk = this.max(maxPk, this.arrMax(timeSeries[item].peakOccurence))
      minPk = this.min(minPk, this.arrMin(timeSeries[item].peakOccurence))
      maxFr = this.max(maxFr, this.arrMax(timeSeries[item].frequency))
      minFr = this.min(minFr, this.arrMin(timeSeries[item].frequency))

    for item in Object.keys(timeSeries)
      for i in [0..timeSeries[item].coOccurence.length-1]
        timeSeries[item].coOccurence[i]   = this.scale(timeSeries[item].coOccurence[i], minCo, maxCo)
        timeSeries[item].standardDev[i]   = this.scale(timeSeries[item].standardDev[i], minSt, maxSt)
        timeSeries[item].peakOccurence[i] = this.scale(timeSeries[item].peakOccurence[i], minPk, maxPk)
        timeSeries[item].frequency[i]     = this.scale(timeSeries[item].frequency[i], minFr, maxFr)

   this.nEvents = (a) ->
     sum = 0.0
     for i in [0..a.length-1]
       sum += a[i].y
     return sum

   this.scaleForNumberOfEvents = (a) ->
      if(a.length <= 0)
        return []
      nA = this.nEvents(a)
      for i in [0..a.length-1]
        a[i].y = parseInt((a[i].y*100)/nA,10)