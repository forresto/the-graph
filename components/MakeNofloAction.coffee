noflo = require 'noflo'
Constants = require '../src/Constants'

exports.getComponent = ->
  c = new noflo.Component
  c._graph = null
  c._group = null

  c.graphChanged = (event) ->
    c.outPorts.action.beginGroup Constants.Graph.CHANGE_GRAPH
    c.outPorts.action.send c._graph
    c.outPorts.action.endGroup()

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
    c.outPorts.action.connect()
    c.outPorts.action.beginGroup Constants.Graph.NEW_GRAPH
    c.outPorts.action.send graph
    c.outPorts.action.endGroup()
    c._graph.on 'endTransaction', c.graphChanged
  c.inPorts.add 'in', (event, payload) ->
    unless c._graph
      c.error new Error Constants.Error.NEED_NOFLO_GRAPH
      return
    switch event
      when 'begingroup'
        c._group = payload
      when 'data'
        return unless c._group
        c._graph[c._group]?.apply c._graph, payload
      when 'endgroup'
        c._group = null

  c.outPorts.add 'action'
  c.outPorts.add 'error'
  c