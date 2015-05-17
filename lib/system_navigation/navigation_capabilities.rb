class SystemNavigation
  module NavigationCapabilities
    refine UnboundMethod do
      def decoder_class
        InstructionStream::Decoder
      end

      # Answer whether the receiver loads the instance variable indexed by the
      # argument.
      def reads_field?(ivar)
        scanner = InstructionStream.on(self)
        scanner.decode
        scanner.scan_for(self.decoder_class.ivar_read_scan(_for: ivar, with: scanner))
      end

      def writes_field?(ivar)
         scanner = InstructionStream.on(self)
         scanner.decode
         scanner.scan_for(self.decoder_class.ivar_write_scan(_for: ivar, with: scanner))
      end
    end

    refine Class do
      def with_all_sub_and_superclasses(&block)
        self.with_all_subclasses_do(&block)
        self.all_superclasses_do(&block)
      end

      # Evaluate the block, for the receiver and each of its subclasses.
      def with_all_subclasses_do(&block)
        self.with_all_subclasses.each do |subclass|
          block.call(subclass)
        end
      end

      # Answer an Array of the receiver, the receiver's descendent's, and the
      # receiver's descendent's subclasses.
      def with_all_subclasses(&block)
        self.all_subclasses.push(self).itself
      end

      def all_subclasses
        all_subclasses = []
        ObjectSpace.each_object(singleton_class) do |klass|
          all_subclasses.unshift(klass) if klass != self
        end
        all_subclasses
      end

      def all_superclasses_do(&block)
        if self.superclass
          block.call(self.superclass)
          self.superclass.all_superclasses_do(&block)
        end
      end

      # Answer a set of selectors whose methods access the argument,
      # ivar, as a named instance variable.
      def which_selectors_access(ivar)
        selectors.select do |sel|
          meth = self.instance_method(sel)
          meth.reads_field?(ivar) || meth.writes_field?(ivar)
        end
      end

      def selectors
        s = self.instance_methods(false)

        if self.respond_to?(:new)
          s << :initialize
        end

        s
      end
    end
  end
end
