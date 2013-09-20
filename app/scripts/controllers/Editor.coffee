'use strict'

# TODO: move service into separate file
angular.module('neo4jApp.services')
  .service 'Editor', [
    'Frame'
    (Frame) ->
      # Configure codemirror
      CodeMirror.commands.handleEnter = (cm) ->
        if cm.lineCount() == 1
          editor.execScript(editor.content)
        else
          CodeMirror.commands.newlineAndIndent(cm)

      CodeMirror.commands.handleUp = (cm) ->
        if cm.lineCount() == 1
          editor.historyPrev()
        else
          CodeMirror.commands.goLineUp(cm)

      CodeMirror.commands.handleDown = (cm) ->
        if cm.lineCount() == 1
          editor.historyNext()
        else
          CodeMirror.commands.goLineDown(cm)

      CodeMirror.keyMap["default"]["Enter"] = "handleEnter"
      CodeMirror.keyMap["default"]["Shift-Enter"] = "newlineAndIndent"
      CodeMirror.keyMap["default"]["Up"] = "handleUp"
      CodeMirror.keyMap["default"]["Down"] = "handleDown"


      class Editor
        constructor: ->
          @history = []
          @content = ''
          @cursor = null
          @next = null
          @prev = null

        execScript: (input) ->
          frame = Frame.create(input: input)
          #return unless frame
          if input?.length > 0 and @history[0] isnt input
            @history.unshift(input)
          @historySet(-1)

        historyNext: ->
          idx = @cursor
          idx ?= @history.length
          idx--
          @historySet(idx)

        historyPrev: ->
          idx = @cursor
          idx ?= -1
          idx++
          @historySet(idx)

        historySet: (idx) ->
          idx = -1 if idx < 0
          idx = @history.length - 1 if idx >= @history.length
          @cursor = idx
          @prev = @history[idx+1]
          @next = @history[idx-1]
          item = @history[idx] or ''
          @content = item

      editor = new Editor()
  ]

# TODO: maybe skip this controller and provide global access somewhere?
angular.module('neo4jApp.controllers')
  .controller 'EditorCtrl', [
    '$scope'
    'Editor'
    ($scope, Editor) ->
      $scope.editor = Editor
  ]
