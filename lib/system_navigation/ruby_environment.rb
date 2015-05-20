class SystemNavigation
  class RubyEnvironment
    # Execute block on each class, metaclass, module and module's metaclass.
    def all_behaviors
      ObjectSpace.each_object(Module) do |klass|
        yield klass
        yield klass.singleton_class
      end
    end
  end
end
