class SystemNavigation
  class ExpressionTree
    def self.of(method:, source:)
      tree = self.new(method: method, source: source)
      tree.parse
      tree
    end

    def initialize(method: nil, source: nil)
      @method = method
      @source = source
      @keywords = []
      @hashes = []
      @arrays = []
      @ranges = []
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

    def includes?(obj)
      built = Ripper.sexp(obj.inspect)
      built_obj = built[1][0][1]

      collection = case obj
                   when Array then @arrays
                   when Hash then @hashes
                   when Range then @ranges
                   else
                     []
                   end
      !!find_includes(collection, built_obj) || @keywords.include?(obj.inspect)
    end

    protected

    def find_includes(collection, obj)
      collection.find do |item|
        item = item[1]

        unify(item)
        unify(obj)

        item == obj
      end
    end

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
          @ranges << node if n == :dot2 || n == :dot3
        end
      end
    end
  end
end
