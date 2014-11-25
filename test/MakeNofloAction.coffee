Noflo = require 'noflo'
test = require 'noflo-test'

Constants = require '../src/Constants'

graph = require './fixtures/graph.json'
nfGraph = null
Noflo.graph.loadJSON graph, (nf) -> nfGraph = nf

test.component('MakeNofloAction').
  describe('When receiving data that isn\'t a noflo graph').
    send.data('graph', {}).
    it('Should error').
      receive.data('error',
        (data, chai) ->
          chai.expect(data.message).to.equal(Constants.Error.NEED_NOFLO_GRAPH)
      ).
  # describe('When receiving a graph').
  #   send.data('graph', nfGraph).
  #   it('Should make `new graph` action.').
  #     receive.beginGroup('action', Constants.Graph.NEW_GRAPH).
  #     receive.data('action', nfGraph).
  #     receive.endGroup('action').
  describe('When receiving a graph change action').
    send.data('graph', nfGraph).
    send.beginGroup('in', Constants.Graph.ADD_NODE).
    send.data('in', ['name', 'lib/comp', {x:10, y:10}]).
    send.endGroup('in').
    it('Should make `new graph` and `change graph` actions.').
      receive.connect('action').
      receive.beginGroup('action', Constants.Graph.NEW_GRAPH).
      receive.data('action', nfGraph).
      receive.endGroup('action').
      receive.beginGroup('action', Constants.Graph.CHANGE_GRAPH).
      receive.data('action',
        (graph, chai) ->
          chai.expect(graph.nodes.length).to.equal 5
          chai.expect(graph.nodes[4].id).to.equal 'name'
          chai.expect(graph.nodes[4].component).to.equal 'lib/comp'
      ).
      receive.endGroup('action').
  describe('When receiving a new graph').
    send.data('graph', nfGraph).
    send.data('graph', nfGraph).
    it('Should disconnect, then connect').
      receive.connect('action').
      receive.disconnect('action').
      receive.connect('action').
export(module)
