'use strict';

angular.module('neo4jApp.services')
  .factory 'RelationshipAngle', [ ->

    reverseAngle = (angle) -> if angle > 180 then angle - 180 else angle + 180
    reverseDirection = (direction) -> if direction is 'incoming' then 'outgoing' else 'incoming'

    class RelationshipAngle
      constructor: (@relationship, @direction, @angle, @fixedOrFloating) ->

      floating: () ->
        @fixedOrFloating is 'floating'

      fix: (angle) ->
        @angle = angle
        @fixedOrFloating = 'fixed'

      otherNode: () ->
        if @direction is 'incoming'
          @relationship.source
        else
          @relationship.target

      reverse: () ->
        new RelationshipAngle(@relationship, reverseDirection(@direction), reverseAngle(@angle), @fixedOrFloating)

    RelationshipAngle
  ]