'use strict'

angular.module('neo4jApp.controllers')
  .controller 'InspectorCtrl', [
    '$scope',
    'GraphStyle'
    ($scope, GraphStyle) ->
      $scope.sizes = GraphStyle.defaultSizes()
      $scope.arrowWidths = GraphStyle.defaultArrayWidths()
      $scope.colors = GraphStyle.defaultColors()
      $scope.style =
        color: $scope.colors[0].color
        'border-color': $scope.colors[0]['border-color']
        diameter: $scope.sizes[0].diameter

      $scope.$watch 'selectedGraphItem', (item) ->
        return unless item
        $scope.item = item
        $scope.style = GraphStyle.forEntity(item).props
        if $scope.style.caption
          $scope.selectedCaption = $scope.style.caption.replace(/\{([^{}]*)\}/, "$1")

      $scope.selectSize = (size) ->
        $scope.style.diameter = size.diameter
        $scope.saveStyle()

      $scope.selectArrowWidth = (arrowWidth) ->
        $scope.style['shaft-width'] = arrowWidth['shaft-width']
        $scope.saveStyle()

      $scope.selectScheme = (color) ->
        $scope.style.color = color.color
        $scope.style['border-color'] = color['border-color']
        $scope.style['text-color-internal'] = color['text-color-internal']
        $scope.saveStyle()

      $scope.selectCaption  = (caption) ->
        $scope.selectedCaption = caption
        $scope.style.caption = '{' + caption + '}'
        $scope.saveStyle()

      $scope.saveStyle = ->
        GraphStyle.change($scope.item, $scope.style)

  ]
