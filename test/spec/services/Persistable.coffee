'use strict'

describe 'Service: Persistable', () ->

  # load the service's module
  beforeEach module 'neo4jApp.services'

  # instantiate service
  Persistable = {}
  beforeEach inject (_Persistable_) ->
    Persistable = _Persistable_

