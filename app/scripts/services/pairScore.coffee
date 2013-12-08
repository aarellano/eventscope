app.service 'pairScore', () ->
  this.computePairScore = (timeSeries)->
    for item in Object.keys(timeSeries)
      #if ( true ) # TODO TIE TO INTERFACE
      #  this.scaleForNumberOfEvents(timeSeries[item][0].data)
      #  this.scaleForNumberOfEvents(timeSeries[item][1].data)
      a = timeSeries[item][0].data
      b = timeSeries[item][1].data

      timeSeries[item].coOccurence   = [this.CoOccurence2(a), this.CoOccurence2(b)]
      timeSeries[item].standardDev   = [this.standardDeviation2(a), this.standardDeviation2(b)]
      timeSeries[item].peakOccurence = [this.peakOccurence2(a, 100, 3, 0.02), this.peakOccurence2(b, 100, 3, 0.02)]
      timeSeries[item].frequency     = [this.fft2(a), this.fft2(b)]
    this.normalize(timeSeries) # Normalize all values between 0 and 1

  this.max = (a, b) ->
    if a > b
      return a
    return b

  this.arrMax2 = (arr) ->
    if(arr.length <= 0)
       return 0.0
    m = arr[0].x
    for i in [0..(arr.length-1)]
      if arr[i].x > m
        m = arr[i].x
    return m

  this.arrMax = (arr) ->
    if(arr.length <= 0)
       return 0.0
    m = arr[0]
    for i in [0..arr.length-1]
      if arr[i] > m
        m = arr[i]
    return m

  this.arrArgMax = (arr) ->
    if(arr.length <= 0)
       return 0.0
    argMax = arr[0]
    maxMax = 0
    for i in [0..arr.length-1]
      if arr[i] > maxMax
        maxMax = arr[i]
        argMax = i
    return argMax

  this.arrMin2 = (arr) ->
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

  this.arrMin = (arr) ->
    if(arr.length <= 0)
       return 0.0
    m = arr[0]
    for i in [0..arr.length-1]
     if arr[i] < m
        m = arr[i]
    return m

  this.mean = (arr) ->
    sum = 0.0
    for i in [0..arr.length-1]
      sum += arr[i]
    return sum/arr.length

  this.mean2 = (arr) ->
    sum = 0.0
    items = 0.0
    for i in [0..arr.length-1]
      # Position (or value) * count of that value
      sum += (arr[i].x * arr[i].y)
      items += arr[i].y
    return sum/items

  this.standardDeviation2 = (a) ->
    if(a.length <= 0)
       return 0.0
    mean = this.mean2(a)
    items = 0.0
    difference = 0.0
    for i in [0..a.length-1]
      difference = difference + (a[i].y * Math.pow(mean - a[i].x, 2))
      items += a[i].y
    return Math.sqrt(difference/items)

  this.standardDeviation = (timeSeries) ->
   #this.mean(timeSeries)
    difference = 0.0
    for i in [0..timeSeries.length-1]
      difference = difference + Math.pow(mean - timeSeries[i], 2)
    return Math.sqrt(difference/timeSeries.length)

  this.CoOccurence2 = (timeSeries) ->
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

  this.CoOccurence = (timeSeries, ref) ->
    before = 0
    after  = 0
    result = 0.0
    for i in [0..timeSeries.length-1]
        if timeSeries[i] > ref
          after = after + 1
        else if timeSeries[i] < ref
          before = before + 1
        # else, do nothing ignore it
    if( after > before )
        result = ((2.0 * this.max(before, after))/(before + after)) - 1
    else if ( before > after )
        result = -1.0*(((2.0 * this.max(before, after))/(before + after)) - 1)
    else
        result = 0
    return result

  this.indexof = (elem, nbins, max, min) ->
    #if(elem < min)
    #  return -1
    #if(elem > max) # Dosent matter if this is an actually index into the array
    #  return nBins + 1
    return Math.floor((( elem - min ) / ( max - min ))* (nbins*1.0))

  this.peak_locs2 = (timeSeries, nbins, k, threshold, max, min) ->
    arr = Array(nbins)
    peaks = Array()
    total = 0.0
    for i in [0..(nbins-1)] #possibly here?
      arr[i] = 0.0
    # build a histogram
    for i in [0..timeSeries.length-1]
      idx = this.indexof(timeSeries[i].x, nbins, max, min)
      arr[idx] = arr[idx] + timeSeries[i].y
      total += timeSeries[i].y
    for i in [0..arr.length-1]
      arr[i] = arr[i]/total
    # find the number of peaks
    for i in [k..nbins-2-k]
      score = (this.arrMax(arr.slice(i-k,i)) + this.arrMax(arr.slice(i+1,i+1+k))) / 2.0
      if score > threshold
        peaks.push(i)
    return peaks

  # nbins in the number of bins in the hist
  # k is the sliding window for peak detection
  # threshold is the threshold for peak detection
  this.peakOccurence2 = (timeSeries, nbins, k, threshold) ->
    if(timeSeries.length <= 0)
        return 0.0
    max = this.arrMax2(timeSeries)
    min = this.arrMin2(timeSeries)

    peaks = this.peak_locs2(timeSeries, nbins, k, threshold, max, min)
    if peaks.length == 0
      return 0.0
	  
    refIdx = this.indexof(0, nbins, max, min)
    before = 0.0
    after  = 0.0
    result = 0.0
    
    for i in [0..peaks.length-1]
        if peaks[i] > refIdx
          after = after + 1
        else if peaks[i] < refIdx
          before = before + 1
        # else, do nothing ignore it

    result = 2.0 * this.max(before, after)/(before + after) - 1
    return result

  this.fft = (ts) ->
    console.log("WARNING : FFT FUNCTION NOT YET IMPLEMENTED")
    return 1.0

  this.nItems2 = (a) ->
    items = 0.0
    for elem in a
      items += elem.y
    return items

  this.zeroArray = (size) ->
    a = Array(Math.round(size))#TODO: does this still work w/ non-integers?
    for i in [0..(size-1)]
      a[i] = 0.0
    return a

  this.fft2 = (a) ->
    if(a.length <= 0)
        return 0.0

    nItems = this.nItems2(a)
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


