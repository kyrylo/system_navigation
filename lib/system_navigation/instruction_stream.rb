class SystemNavigation
  class InstructionStream
    def self.on(method)
      self.new(method: method)
    end

    attr_reader :method

    def initialize(method: nil, iseq: nil)
      @method = method
      @iseq = iseq
    end

    def decode
      @iseq ||= RubyVM::InstructionSequence.disasm(@method) || ''
    end

    def scan_for(selected_instructs)
      selected_instructs.any?
    end

    def iseqs(sym)
      iseqs = @iseq.split("\n")

      if iseqs.any?
        instructions = iseqs.map { |instruction| Instruction.parse(instruction) }
        instructions.compact.select(&:vm_operative?)
      else
        Instruction::AttrInstruction.parse(@method, sym) || []
      end
    end
  end
end
