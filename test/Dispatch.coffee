test = require 'noflo-test'

Constants = require '../src/Constants'
graph = {}

test.component('Dispatch').
  describe('When receiving a graph').
    send.beginGroup('action', Constants.Graph.NEW_GRAPH).
    send.data('action', graph).
    send.endGroup('action').
    it('Should send the graph in a `new graph` group.').
      receive.beginGroup('new_graph', Constants.Graph.NEW_GRAPH).
      receive.data('new_graph', graph).
      receive.endGroup('new_graph').
  describe('When receiving a graph 2').
    send.beginGroup('action', Constants.Graph.NEW_GRAPH).
    send.data('action', graph).
    send.endGroup('action').
    it('Should send the graph in a `new graph` group.').
      receive.beginGroup('new_graph', Constants.Graph.NEW_GRAPH).
      receive.data('new_graph', graph).
      receive.endGroup('new_graph').
  describe('When receiving an action with internal animation tick').
    send.beginGroup('action', Constants.Graph.CHANGE_GRAPH).
    send.data('action', graph).
    it('Should send the graph (async with animation frame).').
      receive.data('graph_action', graph).
  describe('When receiving an action with external animation tick').
    send.data('tick', true).
    send.beginGroup('action', Constants.Graph.CHANGE_GRAPH).
    send.data('action', graph).
    send.endGroup('action').
    send.data('tick', true).
    it('Should send the graph (sync with external tick).').
      receive.data('graph_action', graph).
export(module)
