noflo = require 'noflo'
Constants = require '../src/Constants'
requestAnimationFrame = require 'raf'
cancelAnimationFrame = requestAnimationFrame.cancel

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'share-alt'
  c.raf = null
  c.tick = false
  c.group = null
  c._graphActions = []

  c.startLoop = () ->
    # Only start loop once if tick hasn't been hit
    return if c.tick or c.raf
    c.raf = requestAnimationFrame c.loop

  c.stopLoop = () ->
    if c.raf
      cancelAnimationFrame c.raf

  c.loop = (time) ->
    return if c.tick
    c.raf = requestAnimationFrame c.loop
    if c._graphActions.length > 0
      c.sendBatch(time)

  c.sendBatch = (groupName) ->
    c.outPorts.graph_action.beginGroup groupName
    for action in c._graphActions
      c.outPorts.graph_action.send action
    c._graphActions = []
    c.outPorts.graph_action.endGroup()
    c.outPorts.graph_action.disconnect()

  c.shutdown = () ->
    c.stopLoop()

  c.inPorts.add 'action', (event, payload) ->
    switch event
      when 'begingroup'
        c.group = payload
        if payload is Constants.Graph.NEW_GRAPH
          c._graphActions = []
          c.outPorts.new_graph.beginGroup c.group
      when 'data'
        if c.group is Constants.Graph.NEW_GRAPH
          c.outPorts.new_graph.send payload
        else
          c._graphActions.push payload
          c.startLoop()
      when 'endgroup'
        if c.group is Constants.Graph.NEW_GRAPH
          c.outPorts.new_graph.endGroup()
          c.outPorts.new_graph.disconnect()
        c.group = null

  c.inPorts.add 'tick',
    description: 'if never hit, will batch and dispatch on internal rAF loop'
    datatype: 'bang'
  , (event, payload) ->
    return unless event is 'data'
    c.stopLoop()
    c.tick = true
    c.sendBatch()
  c.outPorts.add 'new_graph'
  c.outPorts.add 'lib_action'
  c.outPorts.add 'graph_action'
  c