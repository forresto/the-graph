noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'share-alt'
  c.inPorts.add 'action', (event, payload) ->
    return unless event is 'data'
    # Do something with the packet, then
    c.outPorts.graph_action.send payload
  c.outPorts.add 'new_graph'
  c.outPorts.add 'lib_action'
  c.outPorts.add 'graph_action'
  c