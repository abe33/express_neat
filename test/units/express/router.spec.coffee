require '../../test_helper'
require '../../helpers/express/router_helper'

withRouter ->

  expectRoute('baz').toValidate()
  expectRoute('/baz').toValidate()
  expectRoute('/baz#foo').toValidate()
  expectRoute('/foo/baz#foo').toValidate()
  expectRoute('foo/baz#foo').toValidate()

  expectRoute('foo bar').not.toValidate()
  expectRoute('foo bar#foo').not.toValidate()
  expectRoute('foo-bar#foo').not.toValidate()

  expectRoute('get',    '/').toExists()
  expectRoute('get',    '/baz').toExists()
  expectRoute('post',   '/baz/foo').toExists()
  expectRoute('put',    '/oof/:id').toExists()
  expectRoute('delete', '/oof/:id').toExists()
  expectRoute('get',    '/foo/bar').toExists()
  expectRoute('post',   '/foo/bar').toExists()
  expectRoute('get',    '/foo/bar/new').toExists()
  expectRoute('get',    '/foo/bar/:id').toExists()
  expectRoute('put',    '/foo/bar/:id').toExists()
  expectRoute('delete', '/foo/bar/:id').toExists()
  expectRoute('get',    '/foo/bar/:id/edit').toExists()

  expectRoute('post',   '/bar').not.toExists()
  expectRoute('get',    '/bar/:id').not.toExists()

  expectRoute('get',    '/foo/bar').toMatch('/foo/bar')
  expectRoute('post',   '/foo/bar').toMatch('/foo/bar')
  expectRoute('put',    '/foo/bar/12').toMatch('/foo/bar/:id')
  expectRoute('delete', '/foo/bar/baz').toMatch('/foo/bar/:id')

  expectRoute('get',    '/10/bar').not.toMatch()
  expectRoute('post',   '/bar/bar').not.toMatch()
  expectRoute('put',    '/bar/12').not.toMatch()
  expectRoute('delete', '/foo/231/baz').not.toMatch()

  expectRoute('get',    '/').toHaveRegistered("baz#index")
  expectRoute('get',    '/baz').toHaveRegistered("baz#index")
  expectRoute('post',   '/baz/foo').toHaveRegistered("baz#foo")
  expectRoute('get',    '/foo/bar').toHaveRegistered("foo/bar#index")
  expectRoute('post',   '/foo/bar').toHaveRegistered("foo/bar#create")

  describe 'calling a route to a controller', ->
    it 'should create a new instance of this controller', ->
      initialCount = @controllerClasses.baz.instancesCount
      @get '/'
      newCount = @controllerClasses.baz.instancesCount
      expect(newCount).toBe(initialCount + 1)

    it 'should have called the corresponding action on the instance', ->
      initialCount = @controllerClasses.baz.calls.index
      @get '/'
      newCount = @controllerClasses.baz.calls.index
      expect(newCount).toBe(initialCount + 1)

    describe 'when this route was defined using a function', ->
      it 'should call this function', ->
        initialCount = @anonymousCalls
        @put '/oof/:id'
        newCount = @anonymousCalls
        expect(newCount).toBe(initialCount + 1)

