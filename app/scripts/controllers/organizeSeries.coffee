list = (data, refA, refB, categories, interval) ->
  for eventName in categories
    if eventName != refA
      before = 0
      after = 0
      for game in data
        game
        for event in game
          # Do something with the event
          event
