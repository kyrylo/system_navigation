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

    def all_in_the_same_file?
      self.instance_and_singleton_do(
        for_all: proc { |_scope, _selectors, method| method.source_location[0] }
      ).as_array.uniq.count == 1
    end

    def find_accessing_methods(var:, only_set:, only_get:)
      self.instance_and_singleton_do(
        for_all: proc { |_scope, _selectors, method|
          compiled_method = CompiledMethod.compile(method)
          if only_set
            compiled_method.unwrap if compiled_method.writes_field?(var)
          elsif only_get
            compiled_method.unwrap if compiled_method.reads_field?(var)
          else
            if compiled_method.reads_field?(var) ||
               compiled_method.writes_field?(var)
              compiled_method.unwrap
            end
          end
        }
      )
    end

    def select_sent_messages
      self.instance_and_singleton_do(
        for_all: proc { |_scope, _selectors, method|
          compiled_method = CompiledMethod.compile(method)
          compiled_method.sent_messages.uniq.map(&:to_sym)
        }
      )
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
