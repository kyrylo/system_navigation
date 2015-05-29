class SystemNavigation
  class AncestorMethodFinder
    using ArrayRefinement

    def self.find_all_ancestors(of:)
      finder = self.new(of)
      singleton_finder = self.new(of.singleton_class)

      ancestor_list = []

      ancestor_list.concat(finder.find_all_methods)
      ancestor_list.concat(singleton_finder.find_all_methods)

      ancestor_list
    end

    def initialize(behavior)
      @behavior = behavior
      @ancestor_list = behavior.ancestors - [behavior]
    end

    def find_all_methods
      self.find_closest_ancestors(@ancestor_list).flat_map do |ancestor|
        selectors = MethodHash.create(based_on: ancestor, include_super: false)
        # No inheritance for singletons in Ruby
        [:public, :private, :protected].each { |t| selectors[t][:singleton] = [] }

        MethodQuery.execute(collection: selectors,
                            query: :convert_to_methods,
                            behavior: @behavior)
      end
    end

    protected

    def find_closest_ancestors(ancestors)
      if @behavior.is_a?(Class)
        ancestors.split(@behavior.superclass).first || []
      else
        ancestors
      end
    end
  end
end
