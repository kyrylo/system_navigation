class SystemNavigation
  module UnboundMethodUtils
    refine UnboundMethod do
      def reads_field?(ivar)
        self.with_scanner do |s|
          s.scan_for(self.decoder_class.ivar_read_scan(_for: ivar, with: s))
        end
      end

      def writes_field?(ivar)
        self.with_scanner do |s|
          s.scan_for(self.decoder_class.ivar_write_scan(_for: ivar, with: s))
        end
      end

      def has_literal?(literal)
        self.with_scanner do |s|
          s.scan_for(self.decoder_class.literal_scan(_for: literal, with: s))
        end
      end

      def decoder_class
        InstructionStream::Decoder
      end

      def with_scanner
        scanner = InstructionStream.on(self)
        scanner.decode
        yield scanner
      end
    end
  end
end
