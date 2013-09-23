'use strict';

angular.module('neo4jApp.services')
  .service 'GraphGeometry', [
    'GraphStyle', 'TextMeasurement',
    (GraphStyle, TextMeasurent) ->

      square = (distance) -> distance * distance

      setNodeRadii = (nodes) ->
        for node in nodes
          node.radius = parseFloat(GraphStyle.forNode(node).get("diameter")) / 2

      formatNodeCaptions = (nodes) ->
        for node in nodes
          template = GraphStyle.forNode(node).get("caption")
          captionText = GraphStyle.interpolate(template, node.id, node.propertyMap)
          words = captionText.split(" ")
          lines = []
          for i in [0..words.length - 1]
            lines.push(
              node: node
              text: words[i]
              baseline: (1 + i - words.length / 2) * 10
            )
          node.caption = lines

      measureRelationshipCaption = (relationship, caption) ->
        fontFamily = 'sans-serif'
        fontSize = parseFloat(GraphStyle.forRelationship(relationship).get('font-size'))
        padding = parseFloat(GraphStyle.forRelationship(relationship).get('padding'))
        TextMeasurent.measure(caption, fontFamily, fontSize) + padding * 2

      captionFitsInsideArrowShaftWidth = (relationship) ->
        parseFloat(GraphStyle.forRelationship(relationship).get('shaft-width')) >
        parseFloat(GraphStyle.forRelationship(relationship).get('font-size'))

      measureRelationshipCaptions = (relationships) ->
        for relationship in relationships
          relationship.captionLength = measureRelationshipCaption(relationship, relationship.type)
          relationship.captionLayout =
            if captionFitsInsideArrowShaftWidth(relationship)
              "internal"
            else
              "external"

      shortenCaption = (relationship, caption, targetWidth) ->
        shortCaption = caption
        while true
          if shortCaption.length <= 2
            return ['', 0]
          shortCaption = shortCaption.substr(0, shortCaption.length - 2) + '\u2026'
          width = measureRelationshipCaption(relationship, shortCaption)
          if width < targetWidth
            return [shortCaption, width]

      layoutRelationships = (relationships, scale) ->
        for relationship in relationships
          dx = scale.x(relationship.target.x) - scale.x(relationship.source.x)
          dy = scale.y(relationship.target.y) - scale.y(relationship.source.y)
          length = Math.sqrt(square(dx) + square(dy))
          relationship.arrowLength =
            length - relationship.source.radius - relationship.target.radius
          alongPath = (from, distance) ->
            x: scale.x(from.x) + dx * distance / length
            y: scale.y(from.y) + dy * distance / length

          shaftRadius = parseFloat(GraphStyle.forRelationship(relationship).get('shaft-width')) / 2
          headRadius = shaftRadius + 3
          headHeight = headRadius * 2
          shaftLength = relationship.arrowLength - headHeight

          relationship.startPoint = alongPath(relationship.source, relationship.source.radius)
          relationship.endPoint = alongPath(relationship.target, -relationship.target.radius)
          relationship.midShaftPoint = alongPath(relationship.source, relationship.source.radius + shaftLength / 2)
          relationship.angle = Math.atan2(dy, dx) / Math.PI * 180
          relationship.textAngle = relationship.angle
          if relationship.angle < -90 or relationship.angle > 90
            relationship.textAngle += 180

          [relationship.shortCaption, relationship.shortCaptionLength] = if shaftLength > relationship.captionLength
            [relationship.type, relationship.captionLength]
          else
            shortenCaption(relationship, relationship.type, shaftLength)

          if relationship.captionLayout is "external"
            startBreak = (shaftLength - relationship.shortCaptionLength) / 2
            endBreak = shaftLength - startBreak

            relationship.arrowOutline = [
              'M', 0, shaftRadius,
              'L', startBreak, shaftRadius,
              'L', startBreak, -shaftRadius,
              'L', 0, -shaftRadius,
              'Z'
              'M', endBreak, shaftRadius,
              'L', shaftLength, shaftRadius,
              'L', shaftLength, headRadius,
              'L', relationship.arrowLength, 0,
              'L', shaftLength, -headRadius,
              'L', shaftLength, -shaftRadius,
              'L', endBreak, -shaftRadius,
              'Z'
            ].join(' ')
          else
            relationship.arrowOutline = [
              'M', 0, shaftRadius,
              'L', shaftLength, shaftRadius,
              'L', shaftLength, headRadius,
              'L', relationship.arrowLength, 0,
              'L', shaftLength, -headRadius,
              'L', shaftLength, -shaftRadius,
              'L', 0, -shaftRadius,
              'Z'
            ].join(' ')

      @onGraphChange = (graph) ->
        setNodeRadii(graph.nodes())
        formatNodeCaptions(graph.nodes())
        measureRelationshipCaptions(graph.relationships())

      @onTick = (graph, scale) ->
        layoutRelationships(graph.relationships(), scale)
  ]
