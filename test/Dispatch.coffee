Tester = require 'noflo-tester'
chai = require 'chai'

Constants = require '../src/Constants'
graph = {}

lib_action =
  route: Constants.Library.ROUTE
  type: Constants.Library.CHANGE_LIBRARY
  data: {}
graph_action =
  route: Constants.Graph.ROUTE
  type: Constants.Graph.CHANGE_GRAPH
  data: graph

describe 'Dispatch', ->
  t = new Tester 'the-graph/Dispatch'

  before (done) ->
    @timeout 10000
    t.start ->
      done()

  describe 'When receiving a graph', ->
    it 'Should make `new graph` action.', (done) ->
      t.receive 'new_graph', (data, groups, dataCount, groupCount) ->
        chai.expect(data).to.equal(graph)
        done()
      t.ins.graph.send(graph)

  describe 'When receiving a graph action with internal animation tick', ->
    it 'Should send the actions (async with animation frame).', (done) ->
      t.outs.graph_actions.once 'data', (data) ->
        chai.expect(data).to.be.an('array')
        chai.expect(data[0]).to.equal(graph_action)
        done()
      t.ins.action.send(graph_action)
      
  describe 'When receiving a lib action with internal animation tick', ->
    it 'Should send a lib action', (done) ->
      t.outs.lib_actions.once 'data', (data) ->
        chai.expect(data).to.be.an('array')
        chai.expect(data[0]).to.equal(lib_action)
        done()
      t.ins.action.send(lib_action)

  describe 'When receiving an action with external animation tick', ->
    before (done) ->
      t.ins.tick.send('!')
      done()
    it 'Should send the actions (sync with external tick).', (done) ->
      t.outs.graph_actions.once 'data', (data) ->
        chai.expect(data).to.be.an('array')
        chai.expect(data[0]).to.equal(graph_action)
        done()
      t.ins.action.send(graph_action)
      t.ins.tick.send('!')