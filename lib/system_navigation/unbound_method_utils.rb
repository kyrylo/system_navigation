class SystemNavigation
  module UnboundMethodUtils
    refine UnboundMethod do
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
