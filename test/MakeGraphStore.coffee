Noflo = require 'noflo'
Tester = require 'noflo-tester'
chai = require 'chai'

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

  it 'should send the expected graph state', (done) ->
    t.outs.state.on 'data', (data) ->
      chai.expect(data).to.deep.equal expected
      done()
    # t.receive 'state', (data) ->
    #   chai.expect(data).to.deep.equal graphExpectedState
    #   done()
    t.send 'library', library
    t.send 'graph', graph
