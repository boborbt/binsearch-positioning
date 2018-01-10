{CompositeDisposable, Disposable} = require 'atom'

module.exports = BinsearchPositioning =
  subscriptions: null
  boundLeft: null
  boundRight: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',  'binsearch-positioning:moveRight': => @moveRight()
    @subscriptions.add atom.commands.add 'atom-workspace',  'binsearch-positioning:moveLeft': => @moveLeft()

    @editor = atom.workspace.getActiveTextEditor()
    @editorView = atom.views.getView(@editor)
    @subscriptions.add @addEventListener 'keyup', (event) => @keyup(event)

  addEventListener: (eventName, handler) ->
    editorView = atom.views.getView @editor
    editorView.addEventListener eventName, handler
    new Disposable ->
      @editor.removeEventListener eventName, handler

  deactivate: ->
    @subscriptions.dispose()

  # serialize: ->

  keyup: (event) ->
    if event.key == "Control"
      @boundLeft = null
      @boundRight = null

  checkBounds: ->
    # console.log("left:" + @boundLeft + " right:" + @boundRight)
    if @boundLeft == null
      position = @editor.getCursorBufferPosition()
      lineLength = @editor.lineTextForBufferRow(position.row).length

      @boundLeft = 0
      @boundRight = lineLength

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
