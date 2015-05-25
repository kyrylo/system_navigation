class SystemNavigation
  module UnboundMethodUtils
    refine UnboundMethod do
      def reads_field?(ivar)
        self.scan_for do |s|
          self.decoder.ivar_read_scan(_for: ivar, with: s)
        end
      end

      def writes_field?(ivar)
        self.scan_for do |s|
          self.decoder.ivar_write_scan(_for: ivar, with: s)
        end
      end

      def has_literal?(literal)
        self.scan_for do |s|
          self.decoder.literal_scan(_for: literal, with: s)
        end
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
        self.scan_for do |s|
          self.decoder.msg_send_scan(_for: message, with: s)
        end
      end

      def sent_messages
        self.scan_for do |s|
          self.decoder.scan_for_sent_messages(with: s)
        end
      end

      # @return [Array] of literals (as described in `doc/syntax/literals.rdoc`
      #   in your Ruby installation) referenced by the receiver.
      def literals

      end
    end
  end
end
