require 'spec_helper'
require 'riak'
describe "CRDT searching", integration: true, test_client: true do
  let(:index_name){ @index_name }
  before :all do
    @index_name = random_key
    test_client.create_search_index(@index_name)
    wait_until{ test_client.get_search_index @index_name }
  end

  describe 'map types' do
    let(:bucket){ @bucket }
    let(:type){ @type }
    let(:map){ @map }

    before :all do
      @bucket = random_bucket 'crdt-search'
      @type = Riak::Crdt::DEFAULT_BUCKET_TYPES[:map]
      test_client.set_bucket_props @bucket, { search_index: @index_name }, @type
      wait_until do
        test_client.
          get_bucket_props(@bucket, type: @type)['search_index'] == @index_name
      end

      @map = Riak::Crdt::Map.new @bucket, random_key

      @map.batch do |m|
        m.registers['coffee'] = 'panther'
        m.sets['burgers'].add 'kush'
        m.sets['burgers'].add 'lokal'
        m.counters['steps'].increment 1701
        m.flags['pirate'] = true
        m.maps['cables'].sets['ends'].add 'lightning'
        m.maps['cables'].registers['color'] = 'striped'
      end
    end

    subject{ Riak::Crdt::Search.new test_client, index_name }

    it 'finds by register values' do
      results = nil

      expect{ results = subject.search 'coffee_register:panther' }.to_not raise_error
      expect(results).to_not be_empty
      expect(results.first['_yz_rk']).to eq map.key

      expect(results.objects).to_not be_empty
      expect(result_map = results.objects.first).to be
      expect(result_map.key).to eq map.key
    end

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
