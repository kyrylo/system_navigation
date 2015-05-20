class SystemNavigation
  module UnboundMethodUtils
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

      def has_literal?(literal)
        scanner = InstructionStream.on(self)
        scanner.decode
        scanner.scan_for(self.decoder_class.literal_scan(_for: literal, with: scanner))
      end
    end
  end
end
