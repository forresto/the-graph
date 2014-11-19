noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'paint-brush'
  c.inPorts.add 'container'
  c.inPorts.add 'state', (event, payload) ->
    return unless event is 'data'
    # Do something with the packet, then
    
  c.outPorts.add 'out'
  c