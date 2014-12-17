noflo = require 'noflo'
Constants = require '../src/Constants'
requestAnimationFrame = require 'raf'
cancelAnimationFrame = requestAnimationFrame.cancel

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'share-alt'

  c._raf = null
  c._tick = false
  c._graphActions = []
  c._libActions = []

  c.startLoop = () ->
    # Only start loop once if tick hasn't been hit
    return if c._tick or c._raf
    c._raf = requestAnimationFrame c.loop

  c.stopLoop = () ->
    if c._raf
      cancelAnimationFrame c._raf
      c._raf = null
    c.outPorts.lib_actions.disconnect()
    c.outPorts.graph_actions.disconnect()

  c.loop = (time) ->
    return if c._tick
    c._raf = requestAnimationFrame c.loop
    c.sendBatch()

  c.sendBatch = () ->
    if c._libActions.length > 0
      c.outPorts.lib_actions.send c._libActions
      c._libActions = []
    if c._graphActions.length > 0
      c.outPorts.graph_actions.send c._graphActions
      c._graphActions = []

  c.shutdown = () ->
    c.stopLoop()

  c.inPorts.add 'graph',
    description: 'new graph, flush action cache'
    datatype: 'object'
  , (event, payload) ->
    return unless event is 'data'
    c._libActions = []
    c._graphActions = []
    c.outPorts.graph_actions.disconnect()
    c.outPorts.lib_actions.disconnect()
    c.outPorts.new_graph.send payload
    c.outPorts.new_graph.disconnect()

  c.inPorts.add 'action', (event, payload) ->
    return unless event is 'data'
    return unless payload?.route?
    switch payload.route
      when Constants.Library.ROUTE
        c._libActions.push payload
      when Constants.Graph.ROUTE, Constants.View.ROUTE
        c._graphActions.push payload
    c.startLoop()

  c.inPorts.add 'tick',
    description: 'if never hit, will batch and dispatch on internal rAF loop'
    datatype: 'bang'
  , (event, payload) ->
    return unless event is 'data'
    c.stopLoop()
    c._tick = true
    c.sendBatch()
  c.outPorts.add 'new_graph', {datatype: 'object'}
  c.outPorts.add 'lib_actions', {datatype: 'array'}
  c.outPorts.add 'graph_actions', {datatype: 'array'}
  c