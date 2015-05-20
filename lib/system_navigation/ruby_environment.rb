class SystemNavigation
  class RubyEnvironment
    # Execute block on each class, metaclass, module and module's metaclass.
    def all_behaviors
      Enumerator.new do |y|
        ObjectSpace.each_object(Module) do |klass|
          y.yield klass
          y.yield klass.singleton_class
        end
      end
    end
  end
end
