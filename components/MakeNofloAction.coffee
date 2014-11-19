noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'graph'
  c.inPorts.add 'in', (event, payload) ->
    return unless event is 'data'
    # Do something with the packet, then
    c.outPorts.action.send payload
  c.outPorts.add 'action'
  c