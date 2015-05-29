class SystemNavigation
  class CompiledMethod
    def self.compile(method)
      self.new(method).compile
    end

    def initialize(method)
      @method = method
      @scanner = SystemNavigation::InstructionStream.on(method)
      @decoder = InstructionStream::Decoder.new(@scanner)

      begin
        @source = @method.source
      rescue MethodSource::SourceNotFoundError, NoMethodError, Errno::ENOTDIR
        @source = ''
      end

      begin
        @comment = @method.comment
      rescue MethodSource::SourceNotFoundError, NoMethodError, Errno::ENOTDIR
        @comment = ''
      end
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
      case literal
      when Hash
        self.includes_hash?(literal)
      when Array
        self.includes_array?(literal)
      else
        self.scan_for { @decoder.literal_scan(literal) } ||
          self.literals.include?(literal.inspect)
      end
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
      code_and_comment = @source + @comment
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
    #   in your Ruby installation minus procs) referenced by the receiver.
    def literals
      return [] if self.c_method?

      exptree = ExpressionTree.of(method: @method, source: @source)
      exptree.keywords
    end

    def includes_hash?(hash)
      return [] if self.c_method?

      exptree = ExpressionTree.of(method: @method, source: @source)
      exptree.includes_hash?(hash)
    end

    def includes_array?(array)
      return [] if self.c_method?

      exptree = ExpressionTree.of(method: @method, source: @source)
      exptree.includes_array?(array)
    end

    protected

    def scan_for
      @scanner.scan_for(yield)
    end
  end
end
