Noflo = require 'noflo'
test = require 'noflo-test'
chai = require 'chai'

Constants = require '../src/Constants'

graph = require './fixtures/graph.json'
nfGraph = null
Noflo.graph.loadJSON graph, (nf) -> nfGraph = nf
expected = require './fixtures/graphExpectedLibrary.json'

test.component('MakeLibraryStore').
  describe('When receiving data that isn\'t a noflo graph').
    send.data('graph', {}).
    it('Should error').
      receive.data('error', (data) -> 
        chai.expect(data.message).to.equal(Constants.Error.NEED_NOFLO_GRAPH)
      ).
  describe('When receiving an initial graph').
    send.data('graph', nfGraph).
    it('Should make the expected initial library').
      receive.data('library', (data) -> 
        chai.expect(data).to.deep.equal(expected)
      ).
export(module)
