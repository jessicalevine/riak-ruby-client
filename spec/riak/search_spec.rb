require 'spec_helper'
require 'rexml/document'

describe "Search features" do
  describe Riak::Client do
    before :each do
      @client = Riak::Client.new
      @pb = double(Riak::Client::BeefcakeProtobuffsBackend)
      allow(@client).to receive(:backend).and_yield(@pb)
    end

    describe "searching" do
      it "searches the default index" do
        expect(@pb).to receive(:search).with(nil, "foo", {}).and_return({})
        @client.search("foo")
      end

      it "searches the default index with additional options" do
        expect(@pb).to receive(:search).with(nil, 'foo', 'rows' => 30).and_return({})
        @client.search("foo", 'rows' => 30)
      end

      it "searches the specified index" do
        expect(@pb).to receive(:search).with('search', 'foo', {}).and_return({})
        @client.search("search", "foo")
      end
    end
  end

  describe Riak::Bucket do
    before :each do
      @client = Riak::Client.new
      @bucket = Riak::Bucket.new(@client, "foo")
    end

    def load_without_index_hook
      @bucket.instance_variable_set(:@props, {"precommit" => [], "search" => false})
    end

    def load_with_index_hook
      @bucket.instance_variable_set(:@props, {"precommit" => [{"mod" => "riak_search_kv_hook", "fun" => "precommit"}], "search" => true})
    end

    it "detects whether the indexing hook is installed" do
      load_without_index_hook
      expect(@bucket.is_indexed?).to be_falsey

      load_with_index_hook
      expect(@bucket.is_indexed?).to be_truthy
    end

    describe "enabling indexing" do
      it "adds the index hook when not present" do
        load_without_index_hook
        expect(@bucket).to receive(:props=).with({"precommit" => [Riak::Bucket::SEARCH_PRECOMMIT_HOOK], "search" => true})
        @bucket.enable_index!
      end

      it "doesn't modify the precommit when the hook is present" do
        load_with_index_hook
        expect(@bucket).not_to receive(:props=)
        @bucket.enable_index!
      end
    end

    describe "disabling indexing" do
      it "removes the index hook when present" do
        load_with_index_hook
        expect(@bucket).to receive(:props=).with({"precommit" => [], "search" => false})
        @bucket.disable_index!
      end

      it "doesn't modify the precommit when the hook is missing" do
        load_without_index_hook
        expect(@bucket).not_to receive(:props=)
        @bucket.disable_index!
      end
    end
  end

  describe Riak::MapReduce do
    before :each do
      @client = Riak::Client.new
      @mr = Riak::MapReduce.new(@client)
    end

    describe "using a search query as inputs" do
      it "accepts a bucket name and query" do
        @mr.search("foo", "bar OR baz")
        expect(@mr.inputs).to eq({:module => "riak_search", :function => "mapred_search", :arg => ["foo", "bar OR baz"]})
      end

      it "accepts a Riak::Bucket and query" do
        @mr.search(Riak::Bucket.new(@client, "foo"), "bar OR baz")
        expect(@mr.inputs).to eq({:module => "riak_search", :function => "mapred_search", :arg => ["foo", "bar OR baz"]})
      end

      it "emits the Erlang function and arguments" do
        @mr.search("foo", "bar OR baz")
        expect(@mr.to_json).to include('"inputs":{')
        expect(@mr.to_json).to include('"module":"riak_search"')
        expect(@mr.to_json).to include('"function":"mapred_search"')
        expect(@mr.to_json).to include('"arg":["foo","bar OR baz"]')
      end
    end
  end
end
