require '../../test_helper'
require '../../helpers/express/controller_helper'

withTestController ->
  it 'should be able to return its partial name', ->
    expect(@controllerClass.partialName()).toBe('test')

  it 'should have its views wrapped', ->
    for key in CRUD
      expect(@controller[key]).not.toBe(@controllerClass::[key])
      @controller[key](request(), response())
      expect(@calls[key].context).toBe(@controller)

  describe 'with before and after filters set for the index view', ->
    it 'should call both filters when the view is called', ->
      ended = false
      initial_count = @controller.afterCalls

      res = response send: =>
        expect(@controller.beforeCalls).toBe(1)
        expect(@controller.afterCalls).toBe(0)

        setTimeout =>
          expect(@controller.afterCalls).toBe(1)
          ended = true
        , 50

      runs ->
        @controller.index request(), res

      waitsFor progress(-> ended), 'Timed out in controller index', 1000

  describe 'with no filters set for the show view', ->
    it 'should not have called the filter functions', ->
      ended = false
      initial_count = @controller.afterCalls

      res = response send: =>
        expect(@controller.beforeCalls).toBe(0)

        setTimeout =>
          expect(@controller.afterCalls).toBe(0)
          ended = true
        , 50

      runs ->
        @controller.show request(), res

      waitsFor progress(-> ended), 'Timed out in controller show', 1000

  describe 'when one of its views is invoked', ->
    describe 'and that view calls render with a string', ->
      it 'should send the response passed to render', ->
        ended = false

        runs ->
          @controller.show request(), response send: (response) ->
            expect(response).toBe('show was called')
            ended = true

        waitsFor progress(-> ended), 'Timed out in controller show', 1000

    describe 'and that view does not calls render', ->
      it 'should send the result of the template of the corresponding view', ->
        ended = false

        runs ->
          @controller.edit request(), response send: (response) ->
            expect(response).toBe('edit template was called')
            ended = true

        waitsFor progress(-> ended), 'Timed out in controller edit', 1000
