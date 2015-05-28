class SystemNavigation
  class CompiledMethod
    def self.compile(method)
      self.new(method).compile
    end

    def initialize(method)
      @method = method
      @scanner = SystemNavigation::InstructionStream.on(method)
      @decoder = InstructionStream::Decoder.new(@scanner)
    end

    def compile
      @scanner.decode

      self
    end

    def method_missing(method_name, *args, &block)
      @method.send(method_name, *args, &block)
    end

    def unwrap
      @method
    end

    def has_literal?(literal)
      self.scan_for { @decoder.literal_scan(literal) }
    end

    def reads_field?(ivar)
      self.scan_for { @decoder.ivar_read_scan(ivar) }
    end

    def writes_field?(ivar)
      self.scan_for { @decoder.ivar_write_scan(ivar) }
    end

    def sends_message?(message)
      self.scan_for { @decoder.msg_send_scan(message) }
    end

    def source_contains?(string, match_case)
      string = string.dup

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
      @method.source_location.nil?
    end

    def rb_method?
      !self.c_method?
    end

    def sent_messages
      @decoder.scan_for_sent_messages
    end

    # @return [Array] of literals (as described in `doc/syntax/literals.rdoc`
    #   in your Ruby installation) referenced by the receiver.
    def literals

    end

    protected

    def scan_for
      @scanner.scan_for(yield)
    end
  end
end
