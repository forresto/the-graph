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
  c.actions = []

  c.startLoop = () ->
    return if c.tick or c.raf
    c.raf = requestAnimationFrame c.loop

  c.stopLoop = () ->
    if c.raf
      cancelAnimationFrame c.raf

  c.loop = (time) ->
    return if c.tick
    c.raf = requestAnimationFrame c.loop
    if c.actions.length > 0
      c.sendBatch(time)

  c.sendBatch = (groupName) ->
    c.outPorts.action.beginGroup groupName
    for action in c.actions
      c.outPorts.action.send action
    c.actions = []
    c.outPorts.action.endGroup()

  c.shutdown = () ->
    c.stopLoop()

  c.inPorts.add 'action', (event, payload) ->
    switch event
      when 'begingroup'
        c.group = payload
        if payload is Constants.Graph.NEW_GRAPH
          c.actions = []
          c.outPorts.new_graph.beginGroup c.group
      when 'data'
        if c.group is Constants.Graph.NEW_GRAPH
          c.outPorts.new_graph.send payload
        else
          c.actions.push payload
          c.startLoop()
      when 'endgroup'
        if c.group is Constants.Graph.NEW_GRAPH
          c.outPorts.new_graph.endGroup()
        c.group = null

  c.inPorts.add 'tick',
    description: 'if not hit, will batch and dispatch on internal rAF loop'
  , (event, payload) ->
    return unless event is 'data'
    c.stopLoop()
    c.tick = true
    c.sendBatch()
  c.outPorts.add 'new_graph'
  c.outPorts.add 'action'
  c