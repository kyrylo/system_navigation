class SystemNavigation
  class CompiledMethod
    def self.compile(method)
      self.new(method).compile
    end

    def initialize(method)
      @method = method
      @decoder = InstructionStream::Decoder.new
      @scanner = SystemNavigation::InstructionStream.on(method)
    end

    def method_missing(method_name, *args, &block)
      @method.send(method_name, *args, &block)
    end

    def unwrap
      @method
    end

    def has_literal?(literal)
      self.scan_for do |s|
        @decoder.literal_scan(_for: literal, with: s)
      end
    end

    def compile
      @scanner.decode

      self
    end

    protected

    def scan_for
      @scanner.scan_for(yield @scanner)
    end
  end
end
