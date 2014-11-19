noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'share-alt'
  c.inPorts.add 'in', (event, payload) ->
    return unless event is 'data'
    # Do something with the packet, then
    c.outPorts.view.send payload
  c.outPorts.add 'noflo'
  c.outPorts.add 'view'
  c