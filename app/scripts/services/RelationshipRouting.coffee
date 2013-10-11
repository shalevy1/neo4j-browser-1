'use strict';

angular.module('neo4jApp.services')
  .service 'RelationshipRouting', [
    'CircumferentialDistribution', 'RelationshipAngle'
    (CircumferentialDistribution, RelationshipAngle) ->

      routeRelationships: do () ->
        reverse = (angle) -> if angle > 180 then angle - 180 else angle + 180

        (graph) ->
          for node in graph.nodes()
            node.layout.relationshipAngles = []

          for relationship in graph.relationships()
            relationship.source.layout.relationshipAngles.push(
              new RelationshipAngle(relationship, 'outgoing', relationship.angle, 'floating')
            )

            relationship.target.layout.relationshipAngles.push(
              new RelationshipAngle(relationship, 'incoming', reverse(relationship.angle), 'floating')
            )

          for node in graph.nodes()
            CircumferentialDistribution.distribute(node.layout.relationshipAngles, 20)
  ]