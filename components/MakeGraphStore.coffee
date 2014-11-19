noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'hdd-o'
  c.inPorts.add 'graph'
  c.inPorts.add 'library'
  c.inPorts.add 'action', (event, payload) ->
    return unless event is 'data'
    # Do something with the packet, then
    c.outPorts.state.send payload
  c.outPorts.add 'state'
  c