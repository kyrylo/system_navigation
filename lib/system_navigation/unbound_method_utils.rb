class SystemNavigation
  module UnboundMethodUtils
    refine UnboundMethod do
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
