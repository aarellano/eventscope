app.service 'preprocess', [
    this.preprocess = (categories,json) ->
      console.log("preprocess reached")
      refEvts = {}
      categories = []
      if json.events
        for p in json.events
          categories.push(p.event) if p.event not in categories
          if p.ts
            p.ts = moment(p.ts)
            if p.te
              p.te = moment(p.te)
        categories.sort()
        console.log("done with category updates")
]