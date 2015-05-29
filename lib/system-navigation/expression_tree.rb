class SystemNavigation
  class ExpressionTree
    def self.of(method:, source:)
      tree = self.new(method: method, source: source)
      tree.parse
      tree
    end

    attr_reader :keywords, :hashes

    def initialize(method: nil, source: nil)
      @method = method
      @source = source
      @keywords = []
      @hashes = []
      @arrays = []
      @tree = nil
    end

    def parse
      return false if [@method, @source].compact.empty?

      @tree = Ripper.sexp(@source)
      return false unless @tree

      parsed = @tree[1][0]
      return false unless parsed.first == :def

      method_body_tree = parsed[3][1]

      self.walk(method_body_tree)

      true
    end

    def includes_hash?(hash_obj)
      built = Ripper.sexp(hash_obj.inspect)

      built_hash = built[1][0][1]

      includes = @hashes.find do |hash|
        hash = hash[1]

        unify(hash)
        unify(built_hash)

        hash == built_hash
      end

      !!includes
    end

    def includes_array?(array_obj)
      built = Ripper.sexp(array_obj.inspect)

      built_array = built[1][0][1]
      includes = @arrays.find do |array|
        array = array[1]

        unify(array)
        unify(built_array)

        array == built_array
      end

      !!includes
    end

    protected

    def unify(node)
      node.each do |n|
        if n.instance_of?(Array)
          if n.size == 2 && n.all? { |num| num.instance_of?(Fixnum) }
            n[0] = 0
            n[1] = 0
          end

          unify(n)
        end
      end
    end

    def walk(tree)
      tree.each do |node|
        walk_node(node)
      end
    end

    def walk_node(node)
      node.each_with_index do |n, i|
        case n
        when Array
          walk_node(n)
        when Symbol
          @keywords << node[i + 1] if n == :@kw
          @hashes << node if n == :hash
          @arrays << node if n == :array
        end
      end
    end
  end
end
