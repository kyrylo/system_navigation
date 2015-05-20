class SystemNavigation
  class RubyEnvironment
    # Execute block on each class, metaclass, module and module's metaclass.
    def all_behaviors
      if block_given?
        ObjectSpace.each_object(Module) do |klass|
          yield klass
          yield klass.singleton_class
        end
      else
        Enumerator.new do |y|
          ObjectSpace.each_object(Module) do |klass|
            y.yield klass
            y.yield klass.singleton_class
          end
        end
      end
    end
  end
end
