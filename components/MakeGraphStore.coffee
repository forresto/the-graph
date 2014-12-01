noflo = require 'noflo'
Constants = require '../src/Constants'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'hdd-o'

  c._graph = null
  c._library = null
  c._icons = {}
  c._tempPos = {}

  c.buildState = () ->
    return unless c._graph and c._library
    graph = c._graph
    state =
      width: 800
      height: 800
      margin_top: 0
      margin_right: 0
      margin_bottom: 0
      margin_left: 0
      center_x: 400
      center_y: 400
      scale: 1
      groups: []
      edges: []
      nodes: []
      initializers: []
      inports: []
      outports: []

    # Test if ports should render as addressable
    addressableIns = {}
    addressableOuts = {}
    for edge in graph.edges
      if edge.from.index?
        hashAddressable edge.from, 'out', addressableOuts
      if edge.to.index?
        hashAddressable edge.to, 'in', addressableIns

    nodeHash = {}
    portHash = {}
    for node in graph.nodes
      lib = c._library[node.component]
      nodeState =
        key: node.id
        icon: c._icons[node.id] or lib.icon or undefined
        x: c._tempPos[node.id]?.x or node.metadata.x or 0
        y: c._tempPos[node.id]?.y or node.metadata.y or 0
        width: 72
        height: 72
        inports: []
        outports: []
      for libIn in lib.inports
        makePortState node.id, 'in', libIn, addressableIns, nodeState.inports, portHash
      for libOut in lib.outports
        makePortState node.id, 'out', libOut, addressableOuts, nodeState.outports, portHash
      # Taller nodes if there are >8 ports
      nodeState.height = Math.max(8, nodeState.inports.length, nodeState.outports.length) * 9
      # Port positioning
      inSpaceing = nodeState.height / (nodeState.inports.length+1)
      for inport, index in nodeState.inports
        inport.x = 0
        inport.y = Math.round(inSpaceing * (index+1))
      outSpaceing = nodeState.height / (nodeState.inports.length+1)
      for outport, index in nodeState.outports
        outport.x = 72
        outport.y = Math.round(outSpaceing * (index+1))

      nodeHash[node.id] = nodeState
      state.nodes.push nodeState

    for edge in graph.edges
      fromKey = "#{edge.from.node}:::out:::#{edge.from.port}"
      if edge.from.index?
        fromKey += ":::#{edge.from.index}"
      toKey = "#{edge.to.node}:::in:::#{edge.to.port}"
      if edge.to.index?
        toKey += ":::#{edge.to.index}"

      fromNode = nodeHash[edge.from.node]
      toNode = nodeHash[edge.to.node]
      fromPort = portHash[fromKey]
      toPort = portHash[toKey]

      edgeState =
        sX: fromNode.x + fromPort.x
        sY: fromNode.y + fromPort.y
        tX: toNode.x + toPort.x
        tY: toNode.y + toPort.y
        from:
          node: edge.from.node
          port: edge.from.port
        to:
          node: edge.to.node
          port: edge.to.port
        metadata: edge.metadata
      if edge.from.index?
        edgeState.from.index = edge.from.index
      if edge.to.index?
        edgeState.to.index = edge.to.index
      state.edges.push edgeState

    c._lastState = state
    return state

  c.inPorts.add 'graph', (event, payload) ->
    return unless event is 'data'
    graph = payload
    unless graph?.addNode?
      c.error new Error Constants.Error.NEED_NOFLO_GRAPH
      return
    c._graph = payload
    c.outPorts.state.connect()
    c.outPorts.state.send c.buildState()
    c.outPorts.state.disconnect()
  c.inPorts.add 'library', (event, payload) ->
    return unless event is 'data'
    c._library = payload
  c.inPorts.add 'action', (event, payload) ->
    return unless event is 'data'
    # TODO Process action
    c.outPorts.state.send c.buildState()
  c.outPorts.add 'state'
  c.outPorts.add 'error'
  c


# Utils

# Will need reworking if hashports (non-numeric keys) become a thing
hashAddressable = (side, direction, hash) ->
  key = "#{side.node}:::#{direction}:::#{side.port}"
  if hash[key]? and hash[key] < side.index
    hash[key] = side.index
  else
    hash[key] = 0

makePortState = (nodeID, direction, lib, addressableHash, ports, portHash) ->
  key = "#{nodeID}:::#{direction}:::#{lib.name}"
  port =
    key: key
    name: lib.name
    type: lib.type
  if addressableHash[key]?
    count = addressableHash[key]
    for index in [0..count+1]
      addressablePort =
        key: "#{key}:::#{index}"
        name: lib.name
        type: lib.type
        index: index
      ports.push addressablePort
      portHash[addressablePort.key] = addressablePort
    return
  ports.push port
  portHash[port.key] = port
