'use strict';

angular.module('neo4jApp.services')
  .factory 'RelationshipAngle', [ ->

    class RelationshipAngle
      constructor: (@relationship, @direction, @angle, @fixedOrFloating) ->

      floating: () ->
        @fixedOrFloating is 'floating'

      fix: (angle) ->
        @angle = angle
        @fixedOrFloating = 'fixed'

      otherNode: () ->
        if @direction is 'incoming'
          @relationship.start
        else
          @relationship.end

    RelationshipAngle
  ]