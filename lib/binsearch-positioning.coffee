{CompositeDisposable, Disposable} = require 'atom'

module.exports = BinsearchPositioning =
  subscriptions: null
  boundLeft: null
  boundRight: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',  'binsearch-positioning:moveRight': => @moveRight()
    @subscriptions.add atom.commands.add 'atom-workspace',  'binsearch-positioning:moveLeft': => @moveLeft()

    @keyupHandler = (event) => @keyup(event)

  addEventListener: (editor)->
    editorView = atom.views.getView(editor)
    editorView.addEventListener "keyup", @keyupHandler

  removeEventListener: (editor)->
    editorView = atom.views.getView(editor)
    editorView.removeEventListener "keyup", @keyupHandler

  deactivate: ->
    @subscriptions.dispose()

  keyup: (event) ->
    if event.key == "Control"
      @boundLeft = null
      @boundRight = null
      @removeEventListener(@editor)

  checkBounds: ->
    if @boundLeft == null
      @editor = atom.workspace.getActiveTextEditor()
      position = @editor.getCursorBufferPosition()
      lineLength = @editor.lineTextForBufferRow(position.row).length

      @boundLeft = 0
      @boundRight = lineLength

      @addEventListener(@editor)

  moveRight: ->
    @checkBounds()

    if @editor
      position = @editor.getCursorBufferPosition()
      newPosition = (position.column + @boundRight) / 2
      @boundLeft = Math.min(newPosition, position.column + 1)

      @editor.moveRight(newPosition - position.column)
    else
      console.log("@editor is null")

  moveLeft: ->
    @checkBounds()

    if @editor
      position = @editor.getCursorBufferPosition()
      newPosition = (position.column + @boundLeft) / 2
      @boundRight = Math.max(newPosition, position.column - 1)

      @editor.moveLeft(position.column - newPosition)
    else
      console.log("@editor is null")
