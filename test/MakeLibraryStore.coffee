Noflo = require 'noflo'
Tester = require 'noflo-tester'
chai = require 'chai'

Constants = require '../src/Constants'

graphJSON = require './fixtures/graph.json'
graph = null
Noflo.graph.loadJSON graphJSON, (nfGraph) -> graph = nfGraph
expected = require './fixtures/graphExpectedLibrary.json'

describe 'MakeLibraryStore', ->
  t = new Tester 'the-graph/MakeLibraryStore'

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
    it 'Should make the expected initial library.', (done) ->
      t.receive 'library', (data) ->
        chai.expect(data).to.deep.equal(expected)
        done()
      t.send {graph}
