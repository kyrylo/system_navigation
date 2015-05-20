class SystemNavigation
  module ModuleUtils
    refine Module do
      using ArrayUtils
      using UnboundMethodUtils

      def with_all_sub_and_superclasses
        Enumerator.new do |y|
          self.with_all_subclasses_do.each { |klass| y << klass }
          self.with_all_superclasses_do.each { |klass| y << klass }
        end
      end

      def with_all_subclasses_do
        Enumerator.new do |y|
          self.with_all_subclasses.each do |subclass|
            y.yield subclass
          end
        end
      end

      # Answer an Array of the receiver, the receiver's descendents, and the
      # receiver's descendents subclasses.
      def with_all_subclasses
        self.all_subclasses.push(self)
      end

      def all_subclasses
        all_subclasses = []

        ObjectSpace.each_object(singleton_class) do |klass|
          all_subclasses.unshift(klass) if klass != self
        end

        all_subclasses
      end

      def with_all_superclasses_do
        if self.superclass
          Enumerator.new do |y|
            y.yield self.superclass
            self.superclass.with_all_superclasses_do.each { |klass| y << klass }
          end
        else
          []
        end
      end

      # Answer a set of selectors whose methods access the argument, ivar, as a
      # named instance variable.
      def which_selectors_access(ivar)
        selectors.select do |sel|
          meth = self.instance_method(sel)
          meth.reads_field?(ivar) || meth.writes_field?(ivar)
        end
      end

      def selectors
        [self.all_method_selectors, self.ancestor_selectors].flatten
      end

      def closest_ancestors
        ancestors_list = self.ancestors - [self]

        if self.is_a?(Class)
          ancestors_list.split(self.superclass).first || []
        else
          ancestors_list
        end
      end

      def ancestor_selectors
        if closest_ancestors.any?
          closest_ancestors.flat_map { |ancestor| ancestor.all_method_selectors }
        else
          []
        end
      end

      def which_selectors_refer_to(literal)
        who = []

        self.selectors_and_methods do |selector, method|
          if method.has_literal?(literal)
            who << selector
          end
        end

        who
      end

      def selectors_and_methods(&block)
        self.method_hash.each_pair do |selector, method|
          block.call(selector, method)
        end
      end

      def method_hash
        Hash[self.all_methods.map { |method| [method.original_name, method] }]
      end

      def all_method_selectors
        self.instance_methods(false) + self.private_instance_methods(false)
      end

      def all_methods
        selectors.map { |selector| self.instance_method(selector) }
      end
    end
  end
end
