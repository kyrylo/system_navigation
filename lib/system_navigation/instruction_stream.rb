class SystemNavigation
  class InstructionStream
    def self.on(method)
      self.new(method: method)
    end

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
        iseqs.map do |instruction|
          Instruction.parse(instruction)
        end
      else
        Instruction::AttrInstruction.parse(@method, sym) || []
      end
    end

    def unbound_method
      @method
    end
  end
end
