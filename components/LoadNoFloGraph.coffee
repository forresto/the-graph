noflo = require 'noflo'
loadJSON = noflo.graph.loadJSON

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'json', (event, payload) ->
    return unless event is 'data'
    loadJSON payload, (graph) ->
      c.outPorts.graph.send graph
  c.outPorts.add 'graph'
  c