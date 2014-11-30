Noflo = require 'noflo'
Tester = require 'noflo-tester'
chai = require 'chai'

Constants = require '../src/Constants'
graphJSON = require './fixtures/graph.json'
graph = null
Noflo.graph.loadJSON graphJSON, (nfGraph) -> graph = nfGraph
library = require './fixtures/graphExpectedLibrary.json'

expected = require './fixtures/graphExpectedState.json'

describe 'MakeGraphStore', ->
  t = new Tester 'the-graph/MakeGraphStore'

  before (done) ->
    t.start ->
      done()

  describe 'When receiving data that isn\'t a noflo graph', ->
    it 'Should error', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data.message).to.equal(Constants.Error.NEED_NOFLO_GRAPH)
        done()
      t.send 'graph', {}

  describe 'When receiving a graph', ->
    it 'should send the expected graph state', (done) ->
      t.outs.state.on 'data', (data) ->
        chai.expect(data).to.deep.equal expected
        # chai.expect(data).to.deep.equal {}
        done()
      t.send 'library', library
      t.send 'graph', graph
