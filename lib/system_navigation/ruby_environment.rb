class SystemNavigation
  # @api private
  # @since 0.1.0
  class RubyEnvironment
    ##
    # Execute +block+ on each class, metaclass, module and module's metaclass.
    #
    # @return [Enumerator] if +block+ was given
    # @return [Enumerator] if +block+ is missing
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

    ##
    # Execute +block+ on each class (but not its metaclass).
    #
    # @return [Enumerator] if +block+ was given
    # @return [Enumerator] if +block+ is missing
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

    ##
    # Execute +block+ on each class and module (but not their metaclasses).
    #
    # @return [Enumerator] if +block+ was given
    # @return [Enumerator] if +block+ is missing
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

    ##
    # Execute +block+ on each module (but not its metaclass).
    #
    # @return [Enumerator] if +block+ was given
    # @return [Enumerator] if +block+ is missing
    def all_modules(&block)
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

    ##
    # Execute +block+ on each object.
    #
    # @return [Enumerator] if +block+ was given
    # @return [Enumerator] if +block+ is missing
    def all_objects(&block)
      enum = Enumerator.new do |y|
        ObjectSpace.each_object do |obj|
          y.yield obj
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
