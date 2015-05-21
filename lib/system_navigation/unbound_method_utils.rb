class SystemNavigation
  module UnboundMethodUtils
    refine UnboundMethod do
      def with_scanner
        scanner = InstructionStream.on(self)
        scanner.decode
        yield scanner
      end

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

      def source_contains?(string, match_case)
        begin
          source_code = self.source
        rescue MethodSource::SourceNotFoundError, NoMethodError
          source_code = ''
        end

        begin
          source_comment = self.comment
        rescue MethodSource::SourceNotFoundError, NoMethodError
          source_comment = ''
        end

        code_and_comment = source_code + source_comment
        code_and_comment.downcase! && string.downcase! unless match_case
        !!code_and_comment.match(string)
      end

      def c_method?
        self.source_location.nil?
      end

      def rb_method?
        !self.c_method?
      end

      def sends_message?(message)
        self.with_scanner do |s|
          s.scan_for(self.decoder_class.msg_send_scan(_for: message, with: s))
        end
      end
    end
  end
end
