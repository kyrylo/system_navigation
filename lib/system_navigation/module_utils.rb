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
        self.selectors.select do |sel|
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

      def which_global_selectors_refer_to(literal)
        who = []

        self.selectors_and_methods(only_own: false) do |selector, method|
          if method.has_literal?(literal)
            who << selector
          end
        end

        who
      end

      def selectors_and_methods(only_own: true, &block)
        self.method_hash(only_own: only_own).each_pair do |selector, method|
          block.call(selector, method)
        end
      end

      def method_hash(only_own: true)
        Hash[self.all_methods(only_own: only_own).map do |method|
               [method.original_name, method]
             end]
      end

      def all_method_selectors
        self.instance_methods(false) + self.private_instance_methods(false)
      end

      def all_methods(only_own: true)
        selectors.map do |selector|
          method = self.instance_method(selector)
          if only_own
            method if self.own_method?(method)
          else
            method
          end
        end.compact
      end

      def includes_selector?(selector)
        self.all_method_selectors.include?(selector)
      end

      def belongs_to?(gem_name)
        gemspecs = Gem::Specification.find_all_by_name(gem_name)
        return false if gemspecs.none? || gemspecs.count != 1
        return false if self.all_methods.none?

        gemspec = gemspecs.first
        pattern = %r{(?:/gems/#{gem_name}-#{gemspec.version}/)|(?:/lib/ruby/[[0-9]\.]+/#{gem_name}/)}
        match_location = proc { |locations|
          !!locations.max_by { |_k, value| value }[0].match(pattern)
        }

        if self.contains_only_rb_methods?
          if self.all_neighbour_methods?
            !!self.all_methods.first.source_location.first.match(pattern)
          else
            grouped_locations = self.group_locations_by_path

            if grouped_locations.all? { |l| l[0].match(pattern) }
              return true
            else
              match_location.call(grouped_locations)
            end
          end
        else
          grouped_locations = grouped_locations = self.group_locations_by_path
          grouped_locations.delete_if { |k, v| k.nil? }

          if grouped_locations.empty?
            false
          else
            match_location.call(grouped_locations)
          end
        end
      end

      def contains_only_rb_methods?
        self.all_methods.all? { |meth| meth.source_location }
      end

      def all_neighbour_methods?
        self.all_methods.map { |meth| meth.source_location[0] }.uniq.count == 1
      end

      def group_locations_by_path
        grouped = self.all_methods.map { |m| m.source_location && m.source_location.first || nil }.
                  group_by(&:itself).map{ |k,v| [k, v.count] }
        Hash[grouped]
      end

      def select_matching_methods(string, match_case)
        self.all_methods.select do |method|
          self.own_method?(method) && method.source_contains?(string, match_case)
        end
      end

      def own_method?(method)
        method.owner == self
      end

      def c_methods
        self.all_methods(only_own: true).select do |method|
          method.c_method?
        end
      end

      def rb_methods
        self.all_methods(only_own: true).select do |method|
          method.rb_method?
        end
      end

      def which_selectors_send(message)
        self.all_methods(only_own: true).select do |method|
          method.sends_message?(message)
        end
      end

      def all_messages
        self.all_method_selectors.select do |selector|
          self.instance_method(selector).sent_messages.uniq
        end
      end

      def which_selectors_store_into(ivar)
        self.selectors.select do |sel|
          meth = self.instance_method(sel)
          meth.writes_field?(ivar)
        end
      end
    end
  end
end
