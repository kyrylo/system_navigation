class SystemNavigation
  class RubyEnvironment
    # Execute block on each class, metaclass, module and module's metaclass.
    def all_behaviors(&block)
      enum = Enumerator.new do |y|
        ObjectSpace.each_object(Module) do |klass|
          y.yield klass
          y.yield klass.singleton_class
        end
      end

      if block_given?
        enum.each(&block)
      else
        enum
      end
    end

    def all_classes(&block)
      enum = Enumerator.new do |y|
        ObjectSpace.each_object(Class) do |klass|
          y.yield klass
        end
      end

      if block_given?
        enum.each(&block)
      else
        enum
      end
    end

    def all_classes_and_modules(&block)
      enum = Enumerator.new do |y|
        ObjectSpace.each_object(Module) do |klass|
          y.yield klass
        end
      end

      if block_given?
        enum.each(&block)
      else
        enum
      end
    end

    def all_modules
      enum = Enumerator.new do |y|
        self.all_classes_and_modules.each do |klass|
          y.yield(klass) if klass.instance_of?(Module)
        end
      end

      if block_given?
        enum.each(&block)
      else
        enum
      end
    end
  end
end
