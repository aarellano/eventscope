preprocess = ($scope, json) ->
    refEvts = {}
    $scope.categories = []
    if json.events
      for p in json.events
        $scope.categories.push(p.event) if p.event not in $scope.categories
        if p.ts
          p.ts = moment(p.ts)
          if p.te
            p.te = moment(p.te)
      $scope.categories.sort()
      console.log("done with category updates")