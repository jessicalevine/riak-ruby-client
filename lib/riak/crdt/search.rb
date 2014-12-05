module Riak::Crdt
  
  # Encapsulates query submission and result parsing logic for Yokozuna/full
  # text searches for CRDTs.
  class Search
    def initialize(client, index_name)
      @client = client
      @index_name = index_name
    end
  end
end
