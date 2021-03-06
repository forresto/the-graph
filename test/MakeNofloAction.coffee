Noflo = require 'noflo'
Tester = require 'noflo-tester'
chai = require 'chai'

Constants = require '../src/Constants'

graphJSON = require './fixtures/graph.json'
graph = null
Noflo.graph.loadJSON graphJSON, (nfGraph) -> graph = nfGraph

describe 'MakeNofloAction', ->
  t = new Tester 'the-graph/MakeNofloAction'

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
    it 'Should forward to `new_graph` port.', (done) ->
      t.receive 'new_graph', (data, groups, dataCount, groupCount) ->
        chai.expect(data).to.equal(graph)
        done()
      t.send {graph}

  describe 'When receiving a graph change action', ->
    it 'Should send to `action` port.', (done) ->
      t.outs.action.once 'data', (data) ->
        graph = data
        chai.expect(graph.nodes.length).to.equal 5
        chai.expect(graph.nodes[4].id).to.equal 'name'
        chai.expect(graph.nodes[4].component).to.equal 'lib/comp'
        done()
      t.send
        in:
          type: Constants.Graph.ADD_NODE
          args: ['name', 'lib/comp', {x:10, y:10}]

  describe 'When receiving a new graph', ->
    it 'Should send on `new_graph` port.', (done) ->
      t.receive 'new_graph', (data, groups, dataCount, groupCount) ->
        chai.expect(data).to.equal(graph)
        done()
      t.send {graph}
