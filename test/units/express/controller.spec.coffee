require '../../test_helper'
require '../../helpers/express/controller_helper'

withTestController ->
  it 'should be able to return its partial name', ->
    expect(@controllerClass.partialName()).toBe('test')

  it 'should have its crud methods been wrapped', ->
    for key in CRUD
      expect(@controller[key]).not.toBe(@controllerClass::[key])
      @controller[key]()
      expect(@calls[key].context).toBe(@controller)

