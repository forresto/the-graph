noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'hdd-o'
  c.inPorts.add 'graph'
  c.inPorts.add 'action', (event, payload) ->
    return unless event is 'data'
    # Do something with the packet, then
    c.outPorts.library.send payload
  c.outPorts.add 'library'
  c