Noflo = require 'noflo'
test = require 'noflo-test'

Constants = require '../src/Constants'

graph = require './fixtures/graph.json'
nfGraph = null
Noflo.graph.loadJSON graph, (nf) -> nfGraph = nf
expected = require './fixtures/graphExpectedLibrary.json'

test.component('MakeLibraryStore').
  describe('When receiving data that isn\'t a noflo graph').
    send.data('graph', {}).
    it('Should error').
      receive.data('error', (data, chai) -> 
        chai.expect(data.message).to.equal(Constants.Error.NEED_NOFLO_GRAPH)
      ).
  describe('When receiving an initial graph').
    send.beginGroup('graph', Constants.Graph.NEW_GRAPH).
    send.data('graph', nfGraph).
    send.endGroup('graph').
    it('Should make the expected initial library').
      receive.beginGroup('library', Constants.Library.NEW_LIBRARY).
      receive.data('library', (data, chai) -> 
        chai.expect(data).to.deep.equal(expected)
      ).
      receive.endGroup('library').
export(module)
