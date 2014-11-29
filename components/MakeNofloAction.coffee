noflo = require 'noflo'
Constants = require '../src/Constants'

exports.getComponent = ->
  c = new noflo.Component
  c._graph = null

  c.graphChanged = (event) ->
    c.outPorts.action.connect()
    c.outPorts.action.beginGroup Constants.Graph.CHANGE_GRAPH
    c.outPorts.action.send c._graph
    c.outPorts.action.endGroup()
    c.outPorts.action.disconnect()

  c.inPorts.add 'graph', (event, payload) ->
    return unless event is 'data'
    if c._graph
      c._graph.removeListener 'endTransaction', c.graphChanged
    graph = payload
    unless graph?.addNode?
      c.error new Error Constants.Error.NEED_NOFLO_GRAPH
      return
    c._graph = graph
    c._graph.on 'endTransaction', c.graphChanged

    c.outPorts.action.connect()
    c.outPorts.action.beginGroup Constants.Graph.NEW_GRAPH
    c.outPorts.action.send graph
    c.outPorts.action.endGroup()
    c.outPorts.action.disconnect()

  c.inPorts.add 'in', (event, payload) ->
    unless c._graph
      c.error new Error Constants.Error.NEED_NOFLO_GRAPH
      return
    return unless event is 'data'
    if payload.type and payload.args
      c._graph[payload.type]?.apply c._graph, payload.args

  c.outPorts.add 'action'
  c.outPorts.add 'error'
  c