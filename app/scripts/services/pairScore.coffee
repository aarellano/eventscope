app.service 'pairScore', () ->
  this.max = (a, b) ->
    if a > b
      return a
    return b
	
  this.arrMax = (arr) ->
    m = arr[0]
    for i in [1..arr.length-1]
      if arr[i] > m
        m = arr[i]
    return m

  this.min = (arr) ->
    m = arr[0]
    for i in [1..arr.length-1]
      if arr[i] < m
        m = arr[i]
    return m
	
  this.arrMin = (arr) ->
    m = arr[0]
    for i in [1..arr.length-1]
      if arr[i] < m
        m = arr[i]
    return m	

  this.mean = (arr) ->
    sum = 0.0
    for i in [0..arr.length-1]
      sum += arr[i]
    return sum/arr.length
	
  this.standardDeviation = (timeSeries) ->
    mean = 10 #this.mean(timeSeries)
    difference = 0.0
    for i in [0..timeSeries.length-1]
      difference = difference + Math.pow(mean - timeSeries[i], 2)
    return Math.sqrt(difference/timeSeries.length)
	
  this.CoOccurence2 = (timeSeries) ->
    before = 0
    after  = 0
    result = 0.0
    for i in [0..timeSeries.length-1]
        if timeSeries[i].x > 0
          after = after + timeSeries[i].y
        else if timeSeries[i].x < 0
          before = before + timeSeries[i].y
    if( after > before )
        result = ((2.0 * this.max(before, after))/(before + after)) - 1
    else if ( before > after )
        result = -1.0*(((2.0 * this.max(before, after))/(before + after)) - 1)
    else
        result = 0
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
    return Math.floor((( elem - min ) / ( max - min ))* (nbins*1.0))
	
  this.peak_locs = (timeSeries, nbins, k, threshold, max, min) -> 
    arr = Array(nbins)
    peaks = Array()
    for i in [0..nbins-1] 
      arr[i] = 0.0 
    # build a histogram
    for i in [0..timeSeries.length-1]
      idx = this.indexof(timeSeries[i], nbins, max, min)
      arr[idx] = arr[idx] + 1.0
    # find the number of peaks
    for i in [k..nbins-2-k]
      score = (this.arrMax(arr.slice(i-k)) + this.arrMax(arr.slice(i+1+k))) / 2.0
      if score > threshold
        peaks.push(i)
    return peaks

  this.periodicity = (timeSeries, ref, nbins, k, threshold) ->
    max = this.arrMax(timeSeries)
    min = this.arrMin(timeSeries)
    peaks = this.peak_locs(timeSeries, nbins, k, threshold, max, min)
    refIdx = this.indexof(ref, nbins, max, min)
    before = 0
    after  = 0
    result = 0.0
    for i in [0..peaks.length-1]
        if peaks[i] > refIdx
          after = after + 1
        else if peaks[i] < refIdx
          before = before + 1
        # else, do nothing ignore it
    if( after > before )
        result = ((2.0 * this.max(before, after))/(before + after)) - 1
    else if ( before > after )
        result = -1.0*(((2.0 * this.max(before, after))/(before + after)) - 1)
    else
        result = 0
    return result

  this.fft = (ts) ->
    return 1.0