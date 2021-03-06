class SystemNavigation
  class CompiledMethod
    def self.compile(method)
      self.new(method).compile
    end

    IVAR = /\A@[^@]/
    CVAR = /\A@@/
    GVAR = /\A\$/

    attr_reader :source

    def initialize(method)
      @method = method
      @scanner = SystemNavigation::InstructionStream.on(method)
      @decoder = InstructionStream::Decoder.new(@scanner)

      begin
        @source = FastMethodSource.source_for(@method)
      rescue FastMethodSource::SourceNotFoundError, IOError
        @source = ''
      end

      begin
        @comment = FastMethodSource.comment_for(@method)
      rescue FastMethodSource::SourceNotFoundError, IOError
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

    # Literals that are referenced by the receiver as described in
    # `doc/syntax/literals.rdoc` in your Ruby, installation minus procs and
    # backticks.
    def has_literal?(literal)
      return true if self.scan_for { @decoder.literal_scan(literal) }
      return false if self.c_method?

      exptree = ExpressionTree.of(method: @method, source: @source)
      exptree.includes?(literal)
    end

    def reads_field?(var)
      case var
      when IVAR
        self.scan_for { @decoder.ivar_read_scan(var) }
      when CVAR
        self.scan_for { @decoder.cvar_read_scan(var) }
      when GVAR
        self.scan_for { @decoder.gvar_read_scan(var) }
      else
        raise ArgumentError, "unknown argument #{var}"
      end
    end

    def writes_field?(var)
      case var
      when IVAR
        self.scan_for { @decoder.ivar_write_scan(var) }
      when CVAR
        self.scan_for { @decoder.cvar_write_scan(var) }
      when GVAR
        self.scan_for { @decoder.gvar_write_scan(var) }
      else
        raise ArgumentError, "unknown argument #{var}"
      end
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

    protected

    def scan_for
      @scanner.scan_for(yield)
    end

    def scan_for_literal(literal)
      return false if self.c_method?

      exptree = ExpressionTree.of(method: @method, source: @source)
      exptree.includes?(literal)
    end
  end
end
