class SystemNavigation
  class ExpressionTree
    def self.of(method:, with:)
      tree = self.new(method, with)
      tree.parse
      tree
    end

    attr_reader :keywords

    def initialize(method, source)
      @method = method
      @source = source
      @keywords = []
    end

    def parse
      parsed = Ripper.sexp(@source)
      return false unless parsed

      parsed = parsed[1][0]
      return false unless parsed.first == :def

      method_body_tree = parsed[3][1]

      self.walk(method_body_tree)

      true
    end

    protected

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

          if n == :hash

          end
        end
      end
    end
  end
end
