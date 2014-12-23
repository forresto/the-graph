noflo = require 'noflo'
# Constants = require '../src/Constants'
Constants =
  Error:
    NEED_NOFLO_GRAPH: 'IP should be a valid NoFlo Graph'

exports.getComponent = ->
  c = new noflo.Component
  c._graph = null

  c.graphChanged = (event) ->
    c.outPorts.action.send c._graph

  c.inPorts.add 'graph', (event, payload) ->
    return unless event is 'data'
    if c._graph
      c._graph.removeListener 'endTransaction', c.graphChanged
      c.outPorts.action.disconnect()
    graph = payload
    unless graph?.addNode?
      c.error new Error Constants.Error.NEED_NOFLO_GRAPH
      return
    c._graph = graph
    c._graph.on 'endTransaction', c.graphChanged

    c.outPorts.new_graph.send graph
    c.outPorts.new_graph.disconnect()

  c.inPorts.add 'in', (event, payload) ->
    unless c._graph
      c.error new Error Constants.Error.NEED_NOFLO_GRAPH
      return
    return unless event is 'data'
    if payload.type and payload.args
      c._graph[payload.type]?.apply c._graph, payload.args

  c.outPorts.add 'new_graph'
  c.outPorts.add 'action'
  c.outPorts.add 'error'
  c