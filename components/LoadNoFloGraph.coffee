noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'json', (event, payload) ->
    return unless event is 'data'
    noflo.graph.loadJSON payload, (graph) ->
	  c.outPorts.graph.send graph
  c.outPorts.add 'graph'
  c