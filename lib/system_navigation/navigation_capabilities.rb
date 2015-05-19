class SystemNavigation
  module NavigationCapabilities
    refine Array do
      # Thanks, Rails.
      def split(value = nil)
        results, arr = [[]], self.dup
        until arr.empty?
          if (idx = arr.index(value))
            results.last.concat(arr.shift(idx))
            arr.shift
            results << []
          else
            results.last.concat(arr.shift(arr.size))
          end
        end
        results
      end
    end

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
        self.all_subclasses.push(self)
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
        ancestors = (self.ancestors - [self]).split(self.superclass).first
        ancestor_methods = if ancestors
                             ancestors.map do |mod|
                               mod.instance_methods(false) +
                                 mod.private_instance_methods(false)
                             end.flatten
                           else
                             []
                           end

        self.instance_methods(false) +
          self.private_instance_methods(false) +
          ancestor_methods
      end
    end
  end
end
