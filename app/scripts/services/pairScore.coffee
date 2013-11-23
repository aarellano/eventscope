app.service 'pairScore', () ->
  this.max = (a, b) ->
    if a > b
      return a
    return b

  this.arrMax2 = (arr) ->
    m = arr[0].x
    for i in [1..arr.length-1]
      if arr[i].x > m
        m = arr[i].x
    return m
	
  this.arrMax = (arr) ->
    m = arr[0]
    for i in [1..arr.length-1]
      if arr[i] > m
        m = arr[i]
    return m
  
  this.arrArgMax = (arr) ->
    argMax = arr[0]
    maxMax = 0
    for i in [1..arr.length-1]
      if arr[i] > maxMax
        maxMax = arr[i]
        argMax = i
    return argMax

  this.arrMin2 = (arr) ->
    m = arr[0].x
    for i in [1..arr.length-1]
      if arr[i].x < m
        m = arr[i].x
    return m

  this.min = (arr) ->
    return 20.0
    m = arr[0]
    for i in [1..arr.length-1]
      if arr[i] < m
        m = arr[i]
    return m

  this.arrMin = (arr) ->
    return 20.0
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
 
  this.mean2 = (arr) ->
    sum = 0.0
    items = 0.0
    for i in [0..arr.length-1]
      # Position (or value) * count of that value 
      sum += (arr[i].x * arr[i].y)
      items += arr[i].y
    return sum/items

  this.standardDeviation2 = (a) ->
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
    #if(elem < min)
    #  return -1
    #if(elem > max) # Dosent matter if this is an actually index into the array
    #  return nBins + 1
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

  this.peak_locs2 = (timeSeries, nbins, k, threshold, max, min) -> 
    arr = Array(nbins)
    peaks = Array()
    for i in [0..nbins-1] 
      arr[i] = 0.0 
    # build a histogram
    for i in [0..timeSeries.length-1]
      idx = this.indexof(timeSeries[i].x, nbins, max, min)
      arr[idx] = arr[idx] + timeSeries[i].y
    # find the number of peaks
    for i in [k..nbins-2-k]
      score = (this.arrMax(arr.slice(i-k)) + this.arrMax(arr.slice(i+1+k))) / 2.0
      if score > threshold
        peaks.push(i)
    return peaks

  this.peakOccurence = (timeSeries, ref, nbins, k, threshold) ->
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

  # nbins in the number of bins in the hist
  # k is the sliding window for peak detection 
  # threshold is the threshold for peak detection
  this.peakOccurence2 = (timeSeries, nbins, k, threshold) ->
    max = this.arrMax2(timeSeries)
    min = this.arrMin2(timeSeries)
    peaks = this.peak_locs2(timeSeries, nbins, k, threshold, max, min)
    refIdx = this.indexof(0, nbins, max, min) # What happens if 0 is not in range 
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
	
  this.nItems2 = (a) ->
    items = 0.0
    for elem in a
      items += elem.y
    return items 

  this.zeroArray = (size) ->
    a = Array(size)
    for i in [0..size-1]
      a[i] = 0.0
    return a
  this.fft2 = (a) ->
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