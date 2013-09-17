'use strict'

describe 'Service: CircumferentialDistribution', () ->

  # load the service's module
  beforeEach module 'neo4jApp.services'

  # instantiate service
  RelationshipAngle = null
  distribute = null

  beforeEach inject (_CircumferentialDistribution_) ->
    distribute = _CircumferentialDistribution_.distribute

  beforeEach inject ($injector) ->
    RelationshipAngle = $injector.get('RelationshipAngle')

  it 'should leave arrows alone that are far enough apart', () ->
    arrowsThatAreAlreadyFarEnoughApart = [
      new RelationshipAngle(0, 'incoming', 0, 'floating')
      new RelationshipAngle(1, 'incoming', 120, 'floating')
      new RelationshipAngle(2, 'incoming', 240, 'floating')
    ]

    expect(distribute(arrowsThatAreAlreadyFarEnoughApart, 20))
      .toEqual([
        new RelationshipAngle(0, 'incoming', 0, 'fixed')
        new RelationshipAngle(1, 'incoming', 120, 'fixed')
        new RelationshipAngle(2, 'incoming', 240, 'fixed')
      ])

  it 'should spread out arrows that are too close together', () ->
    arrowsThatAreTooCloseTogether = [
      new RelationshipAngle(0, 'incoming', 160, 'floating')
      new RelationshipAngle(1, 'incoming', 170, 'floating')
      new RelationshipAngle(2, 'incoming', 180, 'floating')
      new RelationshipAngle(3, 'incoming', 190, 'floating')
      new RelationshipAngle(4, 'incoming', 200, 'floating')
    ]
    expect(distribute(arrowsThatAreTooCloseTogether, 20)).toEqual([
      new RelationshipAngle(0, 'incoming', 140, 'fixed')
      new RelationshipAngle(1, 'incoming', 160, 'fixed')
      new RelationshipAngle(2, 'incoming', 180, 'fixed')
      new RelationshipAngle(3, 'incoming', 200, 'fixed')
      new RelationshipAngle(4, 'incoming', 220, 'fixed')
    ])

  it 'should spread out arrows that are too close together, wrapping across 0 degrees', () ->
    arrowsThatAreTooCloseTogether = [
      new RelationshipAngle(0, 'incoming', 340, 'floating')
      new RelationshipAngle(1, 'incoming', 350, 'floating')
      new RelationshipAngle(2, 'incoming', 0, 'floating')
      new RelationshipAngle(3, 'incoming', 10, 'floating')
      new RelationshipAngle(4, 'incoming', 20, 'floating')
    ]
    expect(distribute(arrowsThatAreTooCloseTogether, 20)).toEqual([
      new RelationshipAngle(2, 'incoming', 0, 'fixed')
      new RelationshipAngle(3, 'incoming', 20, 'fixed')
      new RelationshipAngle(4, 'incoming', 40, 'fixed')
      new RelationshipAngle(0, 'incoming', 320, 'fixed')
      new RelationshipAngle(1, 'incoming', 340, 'fixed')
    ])

  it 'should leave arrows alone whose positions have already been fixed, and bump up the floating ones', () ->
    arrowsThatAreTooCloseTogether = [
      new RelationshipAngle(0, 'incoming', 340, 'fixed')
      new RelationshipAngle(1, 'incoming', 359, 'floating')
      new RelationshipAngle(2, 'incoming', 0, 'floating')
      new RelationshipAngle(3, 'incoming', 1, 'floating')
    ]
    expect(distribute(arrowsThatAreTooCloseTogether, 20)).toEqual([
      new RelationshipAngle(2, 'incoming', 20, 'fixed')
      new RelationshipAngle(3, 'incoming', 40, 'fixed')
      new RelationshipAngle(0, 'incoming', 340, 'fixed')
      new RelationshipAngle(1, 'incoming', 0, 'fixed')
    ])

  it 'should leave arrows alone whose positions have already been fixed, and bump down the floating ones', () ->
    arrowsThatAreTooCloseTogether = [
      new RelationshipAngle(0, 'incoming', 20, 'fixed')
      new RelationshipAngle(1, 'incoming', 359, 'floating')
      new RelationshipAngle(2, 'incoming', 0, 'floating')
      new RelationshipAngle(3, 'incoming', 1, 'floating')
    ]
    expect(distribute(arrowsThatAreTooCloseTogether, 20)).toEqual([
      new RelationshipAngle(2, 'incoming', 340, 'fixed')
      new RelationshipAngle(3, 'incoming', 0, 'fixed')
      new RelationshipAngle(0, 'incoming', 20, 'fixed')
      new RelationshipAngle(1, 'incoming', 320, 'fixed')
    ])

  it 'should leave arrows alone whose positions have already been fixed, and distribute between them', () ->
    arrowsThatAreTooCloseTogether = [
      new RelationshipAngle(0, 'incoming', 340, 'fixed')
      new RelationshipAngle(1, 'incoming', 359, 'floating')
      new RelationshipAngle(2, 'incoming', 0, 'floating')
      new RelationshipAngle(3, 'incoming', 1, 'floating')
      new RelationshipAngle(4, 'incoming', 20, 'fixed')
    ]
    expect(distribute(arrowsThatAreTooCloseTogether, 20)).toEqual([
      new RelationshipAngle(2, 'incoming', 0, 'fixed')
      new RelationshipAngle(3, 'incoming', 10, 'fixed')
      new RelationshipAngle(4, 'incoming', 20, 'fixed')
      new RelationshipAngle(0, 'incoming', 340, 'fixed')
      new RelationshipAngle(1, 'incoming', 350, 'fixed')
    ])
