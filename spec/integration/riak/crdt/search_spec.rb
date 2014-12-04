require 'spec_helper'
require 'riak'
describe "CRDT searching", integration: true, test_client: true do
  describe 'map types' do
    it 'finds by register values'
    it 'finds by set entries'
    it 'finds by counter value'
    it 'finds by flag status'
    it 'finds by nested map registers and sets'

    it 'finds by combination of values'
  end

  describe 'sets' do
    it 'finds by entries'
    it 'finds by multiple entries'
  end

  describe 'counters' do
    it 'finds by value'
  end
end
