Tester = require 'noflo-tester'
chai = require 'chai'

Constants = require '../src/Constants'
graph = {}

describe 'Dispatch', ->
  t = new Tester 'the-graph/Dispatch'

  before (done) ->
    t.start ->
      done()

  describe 'When receiving a graph', ->
    it 'Should make `new graph` action.', (done) ->
      t.receive 'new_graph', (data, groups, dataCount, groupCount) ->
        chai.expect(groups[0]).to.equal(Constants.Graph.NEW_GRAPH)
        chai.expect(data).to.equal(graph)
        done()
      t.ins.action.beginGroup(Constants.Graph.NEW_GRAPH)
      t.ins.action.send(graph)
      t.ins.action.endGroup()

  describe 'When receiving an action with internal animation tick', ->
    it 'Should send the actions (async with animation frame).', (done) ->
      t.receive 'graph_action', (data, groups, dataCount, groupCount) ->
        chai.expect(data).to.equal(graph)
        done()
      t.ins.action.beginGroup(Constants.Graph.CHANGE_GRAPH)
      t.ins.action.send(graph)
      t.ins.action.endGroup()

  describe 'When receiving an action with external animation tick', ->
    before (done) ->
      t.ins.tick.send('!')
      done()

    it 'Should send the actions (sync with external tick).', (done) ->
      t.receive 'graph_action', (data, groups, dataCount, groupCount) ->
        chai.expect(data).to.equal(graph)
        done()
      t.ins.action.beginGroup(Constants.Graph.CHANGE_GRAPH)
      t.ins.action.send(graph)
      t.ins.action.endGroup()
      t.ins.tick.send('!')