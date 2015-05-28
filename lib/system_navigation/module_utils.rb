class SystemNavigation
  module ModuleUtils
    refine Module do
      def with_all_sub_and_superclasses
        Enumerator.new do |y|
          self.with_all_subclasses.each { |klass| y << klass }
          self.with_all_superclasses.each { |klass| y << klass }
        end
      end

      def with_all_subclasses
        Enumerator.new do |y|
          self.all_subclasses.push(self).each { |subclass| y << subclass }
        end
      end

      def all_subclasses
        all_subclasses = []

        ObjectSpace.each_object(self.singleton_class) do |klass|
          all_subclasses.unshift(klass) if klass != self
        end

        all_subclasses
      end

      def with_all_superclasses
        if self.superclass
          Enumerator.new do |y|
            y.yield self.superclass
            self.superclass.with_all_superclasses.each { |klass| y << klass }
          end
        else
          []
        end
      end

      def select_methods_that_access(ivar, only_get, only_set)
        own_methods = self.own_methods
        if ancestor_methods.any?
          ancestor_methods.each do |methods|
            own_methods.merge!(methods) do |_group, old_h, new_h|
              old_h.merge!(new_h) { |_key, oldval, newval| oldval | newval }
            end
          end
        end

        MethodQuery.execute(
          collection: own_methods,
          query: :find_accessing_methods,
          ivar: ivar,
          only_get: only_get,
          only_set: only_set,
          behavior: self).as_array
      end

      def select_methods_that_refer_to(literal)
        MethodQuery.execute(
          collection: self.own_methods,
          query: :find_literal,
          literal: literal,
          behavior: self).as_array
      end

      def reachable_selectors
        MethodHash.create(based_on: self, include_super: true)
      end

      def own_selectors
        MethodHash.create(based_on: self, include_super: false)
      end

      def reachable_methods
        MethodQuery.execute(
          collection: self.reachable_selectors,
          query: :convert_to_methods,
          behavior: self)
      end

      def own_methods
        MethodQuery.execute(
          collection: self.own_selectors,
          query: :convert_to_methods,
          behavior: self)
      end

      def reachable_method_hash
        MethodQuery.execute(
          collection: self.reachable_methods,
          query: :tupleize)
      end

      def own_method_hash
        MethodQuery.execute(
          collection: self.own_methods,
          query: :tupleize)
      end

      def which_global_selectors_refer_to(literal)
        who = []

        self.own_selectors_and_methods do |selector, method|
          if method.has_literal?(literal)
            who << selector
          end
        end

        who
      end

      def belongs_to?(gem_name)
        gemspec = Gem::Specification.find_all_by_name(gem_name).last

        return false unless gemspec || self.own_selectors.empty?

        pattern = %r{(?:/gems/#{gem_name}-#{gemspec.version}/)|(?:/lib/ruby/[[0-9]\.]+/#{gem_name}/)}
        match_location = proc { |locations|
          !!locations.max_by { |_k, value| value }[0].match(pattern)
        }

        if self.contains_only_rb_methods?
          if self.all_neighbour_methods?
            self.own_methods.as_array.all? do |method|
              method.source_location.first.match(pattern)
            end
          else
            grouped_locations = self.group_locations_by_path

            if grouped_locations.all? { |l| l[0].match(pattern) }
              true
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
        self.own_methods.as_array.all? { |method| method.source_location }
      end

      def all_neighbour_methods?
        MethodQuery.execute(
          collection: self.own_methods,
          query: :all_in_the_same_file?)
      end

      def group_locations_by_path
        Hash[
          self.own_methods.as_array.map do |method|
            method.source_location && method.source_location.first || nil
          end.group_by(&:itself).map do |key, value|
            [key, value.count]
          end.reject { |k, _v| k.nil? }
        ]
      end

      def select_matching_methods(string, match_case)
        self.own_methods.as_array.select do |method|
          compiled_method = CompiledMethod.compile(method)
          if compiled_method.source_contains?(string, match_case)
            compiled_method.unwrap
          end
        end
      end

      def select_c_methods
        self.own_methods.as_array.select do |method|
          compiled_method = CompiledMethod.compile(method)
          if compiled_method.c_method?
            compiled_method.unwrap
          end
        end
      end

      def select_rb_methods
        self.own_methods.as_array.select do |method|
          compiled_method = CompiledMethod.compile(method)
          if compiled_method.rb_method?
            compiled_method.unwrap
          end
        end
      end

      def select_senders_of(message)
        self.own_methods.as_array.select do |method|
          compiled_method = CompiledMethod.compile(method)
          if compiled_method.sends_message?(message)
            compiled_method.unwrap
          end
        end
      end

      def all_messages
        MethodQuery.execute(
          collection: self.own_methods,
          query: :select_sent_messages)
      end

      def which_selectors_store_into(ivar)
        self.selectors.select do |sel|
          meth = self.instance_method(sel)
          meth.writes_field?(ivar)
        end
      end

      def ancestor_methods
        AncestorMethodFinder.find_all_ancestors(of: self)
      end

      def includes_selector?(selector)
        self.own_selectors.as_array.include?(selector)
      end
    end
  end
end
