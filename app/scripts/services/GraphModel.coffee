'use strict';

angular.module('neo4jApp.services')
  .factory 'GraphModel', [
    'Node', 'Relationship'
    (Node, Relationship) ->

      class GraphModel
        constructor: (cypher) ->
          @nodeMap = {}
          @relationshipMap = {}

          for node in cypher.nodes
            @addNode(node)
          for relationship in cypher.relationships
            @addRelationship(relationship)

        nodes: ->
          value for own key, value of @nodeMap

        relationships: ->
          value for own key, value of @relationshipMap

        addNode: (raw) ->
          @nodeMap[raw.id] ||= new Node(raw.id, raw.labels, raw.properties)

        addRelationship: (raw) ->
          source = @nodeMap[raw.startNode] or throw malformed()
          target = @nodeMap[raw.endNode] or throw malformed()
          @relationshipMap[raw.id] = new Relationship(raw.id, source, target, raw.type, raw.properties)

        merge: (result, localNode) ->
          nodes = (@addNode(n) for n in result.nodes)
          if localNode.x? && localNode.y?
            linkDistance = 60
            for n, i in nodes
              n.x = localNode.x + linkDistance * Math.sin(2 * Math.PI * i / nodes.length)
              n.y = localNode.y + linkDistance * Math.cos(2 * Math.PI * i / nodes.length)
          @addRelationships(result.relationships)

        addRelationships: (relationships) ->
          @addRelationship(r) for r in relationships

        boundingBox: ->
          axes =
            x: (node) -> node.x
            y: (node) -> node.y

          bounds = {}

          for key,accessor of axes
            bounds[key] =
              min: Math.min.apply(null, @nodes().map(accessor))
              max: Math.max.apply(null, @nodes().map(accessor))

          bounds.maxRadius = Math.max.apply(null, @nodes().map((node) -> node.radius))
          bounds

      malformed = ->
        new Error('Malformed graph: must add nodes before relationships that connect them')

      GraphModel
]
