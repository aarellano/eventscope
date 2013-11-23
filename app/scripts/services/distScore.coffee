app.service 'distScore', () ->
  this.dist = (a, b) -> 
    a.sort( (l1,l2) -> return l1.x - l2.x )
    b.sort( (l1,l2) -> return l1.x - l2.x )
    aIdx = 0
    bIdx = 0
    diff = 0.0
    while((aIdx != a.length) && (bIdx != b.length))
      if( aIdx == a.length )
        diff += Math.pow(b[bIdx].y, 2)
        bIdx += 1
      else if (bIdx == a.length)
        diff += Math.pow(a[aIdx].y, 2)
        aIdx += 1
      else if (a[aIdx].x > b[bIdx].x)
        diff += Math.pow(b[bIdx].y, 2)
        bIdx += 1
      else if (a[aIdx].x < b[bIdx].x)
        diff += Math.pow(a[aIdx].y, 2)
        aIdx += 1
      else if (a[aIdx].x == b[bIdx].x)
        diff += Math.pow(a[aIdx].y - b[bIdx].y, 2)
        aIdx += 1
        bIdx += 1
    return Math.sqrt(diff)
	
  this.score = (a, b) ->
    return this.dist(a, b)
    
