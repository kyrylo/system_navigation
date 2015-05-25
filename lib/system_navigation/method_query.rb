class SystemNavigation
  class MethodQuery
    def self.execute(collection:, query:, behavior: nil, **rest)
      args = [query]
      args << rest unless rest.empty?
      self.new(collection, behavior).__send__(*args)
    end

    def initialize(collection, behavior)
      @collection = collection
      @behavior = behavior
    end

    def convert_to_methods
      self.instance_and_singleton_do(
        for_instance: proc { |_scope, _selectors, selector|
          @behavior.instance_method(selector)
        },

        for_singleton: proc { |_scope, _selectors, selector|
          @behavior.singleton_class.instance_method(selector)
        }
      )
    end

    def tupleize
      self.instance_and_singleton_do(
        for_all: proc { |_scope, _selectors, method| [method.name, method] }
      )
    end

    def find_literal(literal:)
      self.instance_and_singleton_do(
        for_all: proc { |_scope, _selectors, method|
          compiled_method = CompiledMethod.compile(method)
          compiled_method.unwrap if compiled_method.has_literal?(literal)
        }
      )
    end

    def all_with_source_location?
      @collection.as_array.all? { |method| method.source_location }
    end

    def all_in_the_same_file?
      self.instance_and_singleton_do(
        for_all: proc { |_scope, _selectors, method| method.source_location[0] }
      ).as_array.uniq.count == 1
    end

    def all_belong_to_gem?(pattern:)
      @collection.as_array.all? do |method|
        method.source_location.first.match(pattern)
      end
    end

    def group_by_path
      Hash[@collection.as_array.map { |m| m.source_location && m.source_location.first || nil }.
            group_by(&:itself).map{ |k,v| [k, v.count] }.reject { |k, _v| k.nil? }]
    end

    def find_accessing_methods(ivar:)
      self.instance_and_singleton_do(
        for_all: proc { |_scope, _selectors, method|
          compiled_method = CompiledMethod.compile(method)
          if compiled_method.reads_field?(ivar) ||
             compiled_method.writes_field?(ivar)
            compiled_method.unwrap
          end
        }
      )
    end

    def select_where_source_contains(string:, match_case:)
      @collection.as_array.select do |method|
        compiled_method = CompiledMethod.compile(method)
        if compiled_method.source_contains?(string, match_case)
          compiled_method.unwrap
        end
      end
    end

    def select_senders_of(message:)
      @collection.as_array.select do |method|
        compiled_method = CompiledMethod.compile(method)
        if compiled_method.sends_message?(message)
          compiled_method.unwrap
        end
      end
    end

    def select_c_methods
      @collection.as_array.select do |method|
        compiled_method = CompiledMethod.compile(method)
        if compiled_method.c_method?
          compiled_method.unwrap
        end
      end
    end

    def select_rb_methods
      @collection.as_array.select do |method|
        compiled_method = CompiledMethod.compile(method)
        if compiled_method.rb_method?
          compiled_method.unwrap
        end
      end
    end

    protected

    def instance_and_singleton_do(for_instance: nil, for_singleton: nil, for_all: nil)
      for_instance = for_all && for_singleton = for_all if for_all

      @collection.inject(MethodHash.new) do |h, (scope, selectors)|
        self.evaluate(callable: for_instance, group: :instance, hash: h,
                      scope: scope, selectors: selectors)
        self.evaluate(callable: for_singleton, group: :singleton, hash: h,
                      scope: scope, selectors: selectors)
        h
      end
    end

    def evaluate(callable:, group:, hash:, scope:, selectors:)
      return if callable.nil?

      result = selectors[group].map do |selector|
        callable.call(scope, selectors, selector)
      end

      hash[scope][group].concat(result)
    end
  end
end
