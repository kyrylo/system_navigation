class SystemNavigation
  module ModuleUtils
    refine Module do
      using ArrayUtils
      using UnboundMethodUtils

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

      # Answer a set of selectors whose methods access the argument, ivar, as a
      # named instance variable.
      def which_selectors_access(ivar)
        self.reachable_selectors.select do |sel|
          meth = self.instance_method(sel)
          meth.reads_field?(ivar) || meth.writes_field?(ivar)
        end
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
        gemspecs = Gem::Specification.find_all_by_name(gem_name)
        return false if gemspecs.none? || gemspecs.count != 1
        return false if self.reachable_selectors.none?

        gemspec = gemspecs.first
        pattern = %r{(?:/gems/#{gem_name}-#{gemspec.version}/)|(?:/lib/ruby/[[0-9]\.]+/#{gem_name}/)}
        match_location = proc { |locations|
          !!locations.max_by { |_k, value| value }[0].match(pattern)
        }

        if self.contains_only_rb_methods?
          if self.all_neighbour_methods?
            MethodQuery.execute(
              collection: self.own_methods,
              query: :all_belong_to_gem?,
              pattern: pattern)
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
        MethodQuery.execute(
          collection: self.own_methods,
          query: :all_with_source_location?)
      end

      def all_neighbour_methods?
        MethodQuery.execute(
          collection: self.own_methods,
          query: :all_in_the_same_file?)
      end

      def group_locations_by_path
        MethodQuery.execute(
          collection: self.reachable_methods,
          query: :group_by_path)
      end

      def select_matching_methods(string, match_case)
        self.own_methods.select do |method|
          method.source_contains?(string, match_case)
        end
      end

      def c_methods
        self.own_methods.select do |method|
          method.c_method?
        end
      end

      def rb_methods
        self.own_methods.select do |method|
          method.rb_method?
        end
      end

      def which_selectors_send(message)
        self.own_methods.select do |method|
          method.sends_message?(message)
        end
      end

      def all_messages
        self.reachable_selectors.select do |selector|
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
