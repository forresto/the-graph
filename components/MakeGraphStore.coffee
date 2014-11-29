noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'hdd-o'

  c._graph = null
  c._library = null
  c._icons = {}

  c.buildState = () ->
    return unless c._graph and c._library
    graph = c._graph
    state =
      nodes: []
      edges: []
      inports: []
      outports: []
      groups: []

    for node in graph.nodes
      lib = c._library[node.component]
      nodeState =
        icon: c._icons[node.id] or lib.icon or undefined
        inports: []
        outports: []
      for inport in lib.inports
        nodeState.inports.push
          name: inport.name
          type: inport.type
      for outport in lib.outports
        nodeState.outports.push
          name: outport.name
          type: outport.type

      state.nodes.push nodeState

    for edge in graph.edges
      state.edges.push edge

    return state

  c.inPorts.add 'graph', (event, payload) ->
    return unless event is 'data'
    c._graph = payload
    c.outPorts.state.send c.buildState()
  c.inPorts.add 'library', (event, payload) ->
    return unless event is 'data'
    c._library = payload
  c.inPorts.add 'action', (event, payload) ->
    return unless event is 'data'
    # TODO Process action
    c.outPorts.state.send c.buildState()
  c.outPorts.add 'state'
  c