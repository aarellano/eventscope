'use strict'

describe 'Directive: highcharts', () ->

  # load the directive's module
  beforeEach module 'multifinderApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<highcharts></highcharts>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the highcharts directive'
