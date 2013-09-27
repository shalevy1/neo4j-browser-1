'use strict';

angular.module('neo4jApp.services')
  .service 'GraphGeometry', [
    'GraphStyle', 'TextMeasurement',
    (GraphStyle, TextMeasurent) ->

      square = (distance) -> distance * distance

      setNodeRadii = (nodes) ->
        for node in nodes
          node.radius = parseFloat(GraphStyle.forNode(node).get("diameter")) / 2

      formatNodeCaptions = do () ->
        fitOnFixedNumberOfLines = (node, words, maxLines, radius, lineHeight, measure) ->
          lines = []
          iWord = 0;
          for iLine in [0..maxLines - 1]
            line = ""
            baseline = (1 + iLine - maxLines / 2) * lineHeight
            constainingHeight = if iLine < maxLines / 2 then baseline - lineHeight else baseline
            lineWidth = Math.sqrt(square(radius) - square(constainingHeight)) * 2
            console.log(maxLines, iLine, lineHeight, radius, lineWidth, constainingHeight)
            while iWord < words.length and measure(line + " " + words[iWord]) < lineWidth
              line += " " + words[iWord]
              iWord++
            lines.push
              node: node
              text: line
              baseline: baseline
          [lines, iWord]

        fitCaptionIntoCircle = (node) ->
          template = GraphStyle.forNode(node).get("caption")
          captionText = GraphStyle.interpolate(template, node.id, node.propertyMap)
          fontFamily = 'sans-serif'
          fontSize = parseFloat(GraphStyle.forNode(node).get('font-size'))
          measure = (text) ->
            TextMeasurent.measure(text, fontFamily, fontSize)

          words = captionText.split(" ")
          maxLines = node.radius * 2 / fontSize

          for lineCount in [1..maxLines]
            [lines, iWord] = fitOnFixedNumberOfLines(node, words, lineCount, node.radius, fontSize, measure)
            if iWord >= words.length
              return lines
          []

        (nodes) ->
          for node in nodes
            node.caption = fitCaptionIntoCircle(node)

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

      layoutRelationships = (relationships) ->
        for relationship in relationships
          dx = relationship.target.x - relationship.source.x
          dy = relationship.target.y - relationship.source.y
          length = Math.sqrt(square(dx) + square(dy))
          relationship.arrowLength =
            length - relationship.source.radius - relationship.target.radius
          alongPath = (from, distance) ->
            x: from.x + dx * distance / length
            y: from.y + dy * distance / length

          shaftRadius = parseFloat(GraphStyle.forRelationship(relationship).get('shaft-width')) / 2
          headRadius = shaftRadius + 3
          headHeight = headRadius * 2
          shaftLength = relationship.arrowLength - headHeight

          relationship.startPoint = alongPath(relationship.source, relationship.source.radius)
          relationship.endPoint = alongPath(relationship.target, -relationship.target.radius)
          relationship.midShaftPoint = alongPath(relationship.startPoint, shaftLength / 2)
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

      @onTick = (graph) ->
        layoutRelationships(graph.relationships())
  ]
