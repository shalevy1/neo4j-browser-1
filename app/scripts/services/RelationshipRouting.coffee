'use strict';

angular.module('neo4jApp.services')
  .service 'RelationshipRouting', [
    'CircumferentialDistribution'
    (CircumferentialDistribution) ->

      @routeRelationships = (graph) ->
        for relationship in graph.relationships.all()
          relationship.start.addRelationship(
            direction: 'outgoing'
            angle: relationship.angle
          )
          relationship.end.addRelationship(
            direction: 'incoming'
            angle: wrapAngle(relationship.angle + 180)
          )

        nodesAndDensities = graph.nodes.all().map((node) ->
          node: node
          density: 2
        )
        nodesAndDensities.sort((a, b) -> a.density - b.density)

        for node in nodesAndDensities.map((d) -> d.node)
          angles = CircumferentialDistribution.distribute(node.layout.angles)
          for angle in angles
            angle.otherNode.layout.fixAngle(angle)
          node.layout.angles = angles
  ]