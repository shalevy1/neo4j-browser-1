'use strict'

describe 'Service: CircumferentialDistribution', () ->

  # load the service's module
  beforeEach module 'neo4jApp.services'

  # instantiate service
  Distribution = {}
  beforeEach inject (_CircumferentialDistribution_) ->
    Distribution = _CircumferentialDistribution_

  it 'should leave arrows alone that are far enough apart', () ->
    arrowsThatAreAlreadyFarEnoughApart =
        0: 0
        1: 120
        2: 240
    result = Distribution.distribute(
      floating: arrowsThatAreAlreadyFarEnoughApart
      fixed: {}
    , 20)
    expect(result).toEqual(arrowsThatAreAlreadyFarEnoughApart)

  it 'should spread out arrows that are too close together', () ->
    arrowsThatAreTooCloseTogether =
      0: 160
      1: 170
      2: 180
      3: 190
      4: 200
    result = Distribution.distribute(
      floating: arrowsThatAreTooCloseTogether
      fixed: {}
    , 20)
    expect(result).toEqual(
      0: 140
      1: 160
      2: 180
      3: 200
      4: 220
    )

  it 'should spread out arrows that are too close together, wrapping across 0 degrees', () ->
    arrowsThatAreTooCloseTogether =
      0: 340
      1: 350
      2: 0
      3: 10
      4: 20
    result = Distribution.distribute(
      floating: arrowsThatAreTooCloseTogether
      fixed: {}
    , 20)
    expect(result).toEqual(
      0: 320
      1: 340
      2: 0
      3: 20
      4: 40
    )

  it 'should leave arrows alone whose positions have already been fixed, and bump up the floating ones', () ->
    floating =
      1: 359
      2: 0
      3: 1
    fixed =
      0: 340
    result = Distribution.distribute(
      floating: floating
      fixed: fixed
    , 20)
    expect(result).toEqual(
      0: 340
      1: 0
      2: 20
      3: 40
    )

  it 'should leave arrows alone whose positions have already been fixed, and bump down the floating ones', () ->
    floating =
      1: 359
      2: 0
      3: 1
    fixed =
      0: 20
    result = Distribution.distribute(
      floating: floating
      fixed: fixed
    , 20)
    expect(result).toEqual(
      0: 20
      1: 320
      2: 340
      3: 0
    )

  it 'should leave arrows alone whose positions have already been fixed, and distribute between them', () ->
    floating =
      1: 359
      2: 0
      3: 1
    fixed =
      0: 340
      4: 20
    result = Distribution.distribute(
      floating: floating
      fixed: fixed
    , 20)
    expect(result).toEqual(
      0: 340
      1: 350
      2: 0
      3: 10
      4: 20
    )
