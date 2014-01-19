{$, _} = require '../vendors'
View   = require './view.coffee'

class Section extends View
  tagName:   'section'
  className: 'app-section'

  ui:
    '$title':         '> header h2'
    '$table':         'table'
    '$tbody':         'table tbody'
    '$addForm':       '.add-form'
    '$addInput':      '.add-form input'
    '$addFormToggle': '.add-form-toggle'

  events:
    'click .add-form-toggle button': 'showAddForm'
    'click .add-form button.add':    'submitAddForm'
    'click .add-form button.cancel': 'closeAddForm'
    'keyup .add-form input.name':    'updateOnKeyup'

  keyboardEvents:
    'c': 'showAddForm'

  dataEvents:
    'change model': 'updateTitle'

    'reset        collection': 'render'
    'add          collection': 'addModelAndUpdate'
    'request      collection': 'startSpinning'
    'sync destroy collection': 'stopSpinning'

    'attached this': 'onAttached'
    'detached this': 'onDetached'

  serialize: ->
    title: @formatTitle(@model)

  afterRender: ->
    @addAll()

    # Sort this bad boy.
    @$table.tablesorter textExtraction: (el) ->
      $('.value', el).text() or $(el).text()

    if @collection.size()
      @$table.trigger 'sorton', [[[0, 0]]]

  updateTitle: =>
    @$title.text @formatTitle(@model)

  showAddForm: (e) =>
    e?.preventDefault?()
    @$addFormToggle.hide()
    @$addForm.show()
    @$addInput.select().focus()

  submitAddForm: =>
    model = new @collection.model(name: @$addInput.val())
    model.collection = @collection
    model.save()
      .done( =>
        @collection.add(model)
        @closeAddForm()
      )
      .fail((xhr) => @app.alerts.handleError(xhr))

  closeAddForm: =>
    @$addFormToggle.show()
    @$addForm.hide()
    @$addInput.val('')

  updateOnKeyup: (e) =>
    switch e.keyCode
      when 13 then @submitAddForm() # enter
      when 27 then @closeAddForm()  # escape

  addModel: (model) =>
    view = new @rowView(model: model)
    view.attachTo(@$tbody)

  addModelAndUpdate: (model) =>
    @addModel(model)
    @$table.trigger('update')

  addAll: =>
    @$tbody.empty()
    @collection.each(@addModel)

  onAttached: =>
    @bindKeyboardEvents()

  onDetached: =>
    @unbindKeyboardEvents()

  startSpinning: =>
    @$el.addClass('spinning')

  stopSpinning: =>
    @$el.removeClass('spinning')

module.exports = Section
