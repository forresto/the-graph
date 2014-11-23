Noflo = require 'noflo'
test = require 'noflo-test'
chai = require 'chai'

getComponent = require('../components/MakeLibraryStore').getComponent

graph = require './fixtures/graph.json'
nfGraph = null
Noflo.graph.loadJSON graph, (nf) -> nfGraph = nf
expected = require './fixtures/graphExpectedLibrary.json'

test.component('MakeLibraryStore', getComponent).
  describe('When receiving data that isn\'t a noflo graph').
    send.data('graph', {}).
    it('Should error').
      receive.data('error', (data) -> 
        chai.expect(data.message).to.equal('ip should be a noflo graph')
      ).
  describe('When receiving an initial graph').
    send.data('graph', nfGraph).
    it('Should make the expected initial library').
      receive.data('library', (data) -> 
        chai.expect(data).to.deep.equal(expected)
      ).
export(module)
