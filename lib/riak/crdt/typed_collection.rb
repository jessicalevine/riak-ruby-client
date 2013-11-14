module Riak
  module Crdt
    class TypedCollection
      def initialize(type, parent, contents={})
        @type = type
        @parent = parent
        stringified_contents = contents.stringify_keys
        @contents = stringified_contents.keys.inject(Hash.new) do |mem, key|
          mem[key] = @type.new self, stringified_contents[key]
          mem
        end
      end

      def include?(key)
        @contents.include? normalize_key(key)
      end
      
      def [](key)
        key = normalize_key key
        return @contents[key] if include? key
        return @type.new
      end
      
      private
      def normalize_key(unnormalized_key)
        unnormalized_key.to_s
      end
            
      def backend_class
        @parent.backend_class
      end
    end
  end
end