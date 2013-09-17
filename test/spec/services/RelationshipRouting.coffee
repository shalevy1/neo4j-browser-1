'use strict'

describe 'Service: RelationshipRouting', () ->

  # load the service's module
  beforeEach module 'neo4jApp.services'

  # instantiate service
  RelationshipRouting = {}
  beforeEach inject (_RelationshipRouting_) ->
    RelationshipRouting = _RelationshipRouting_

