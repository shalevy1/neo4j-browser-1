'use strict';

angular.module('neo4jApp.services')
  .service 'RelationshipRouting', [
    'CircumferentialDistribution', 'RelationshipAngle'
    (CircumferentialDistribution, RelationshipAngle) ->

      routeRelationships: do () ->
        minSeparation = 20
        reverse = (angle) -> if angle > 180 then angle - 180 else angle + 180
        densestFirst = (a, b) ->
          CircumferentialDistribution.density(d3.values(a.layout.relationshipAngles, minSeparation)) -
          CircumferentialDistribution.density(d3.values(b.layout.relationshipAngles, minSeparation))

        (graph) ->
          for node in graph.nodes()
            node.layout.relationshipAngles = {}

          for relationship in graph.relationships()
            relationship.source.layout.relationshipAngles[relationship.id] =
              new RelationshipAngle(relationship, 'outgoing', relationship.angle, 'floating')

            relationship.target.layout.relationshipAngles[relationship.id] =
              new RelationshipAngle(relationship, 'incoming', reverse(relationship.angle), 'floating')

          for node in graph.nodes().sort(densestFirst)
            relationshipAngles = CircumferentialDistribution.distribute(d3.values(node.layout.relationshipAngles), minSeparation)
            for angle in relationshipAngles
              node.layout.relationshipAngles[angle.relationship.id] = angle
              angle.otherNode().layout.relationshipAngles[angle.relationship.id] = angle.reverse()
  ]