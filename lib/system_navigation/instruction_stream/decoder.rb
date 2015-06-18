class SystemNavigation
  class InstructionStream
    class Decoder
      def initialize(scanner)
        @scanner = scanner
      end

      def select_instructions(literal:, method_name: nil, &block)
        instructions = @scanner.iseqs(method_name || literal)

        instructions.select.with_index do |instruction, i|
          prev = instructions[i - 1]
          prev_prev = instructions[i - 2]

          returned = block.call(prev_prev, prev, instruction)
          next instruction if returned

          next if !(instruction.evals? && prev.putstrings?(literal))

          self.class.new(iseq_from_eval(prev, @scanner.method)).
            __send__(block.binding.eval('__method__'), literal).any?
        end
      end

      def ivar_read_scan(ivar)
        self.select_instructions(literal: ivar) do |_prev_prev, prev, instruction|
          next instruction if instruction.reads_ivar?(ivar)

          if instruction.dynamically_reads_ivar? && prev.putobjects?(ivar)
            next instruction
          end
        end
      end

      def ivar_write_scan(ivar)
        self.select_instructions(literal: ivar) do |prev_prev, prev, instruction|
          next instruction if instruction.writes_ivar?(ivar)

          if instruction.dynamically_writes_ivar? && prev_prev.putobjects?(ivar)
            next instruction
          end
        end
      end

      def gvar_read_scan(gvar)
        self.select_instructions(literal: gvar) do |_prev_prev, prev, instruction|
          next instruction if instruction.reads_gvar?(gvar)
        end
      end

      def gvar_write_scan(gvar)
        self.select_instructions(literal: gvar) do |prev_prev, prev, instruction|
          next instruction if instruction.writes_gvar?(gvar)
        end
      end

      def literal_scan(literal)
        name = @scanner.method.original_name

        self.select_instructions(method_name: name, literal: literal) do |_prev_prev, prev, instruction|
          if instruction.putobjects?(literal) ||
             instruction.putnils?(literal) ||
             instruction.duparrays?(literal) ||
             instruction.putstrings?(literal)
            next instruction
          end
        end
      end

      def msg_send_scan(message)
        self.select_instructions(literal: message) do |_prev_prev, prev, instruction|
          next instruction if instruction.sends_msg?(message)
        end
      end

      def scan_for_sent_messages
        @scanner.iseqs(nil).map do |instruction|
          instruction.find_message
        end.compact
      end

      private

      def iseq_from_eval(instruction, method = nil)
        # Avoid segfault if evaling_str is nil.
        # See: https://bugs.ruby-lang.org/issues/11159
        uncompiled = unwind_eval(instruction.evaling_str || nil.to_s)
        uncompiled.gsub!(/\\n/, ?\n)

        iseq = RubyVM::InstructionSequence.compile(uncompiled).disasm
        InstructionStream.new(method: method, iseq: iseq)
      end

      def unwind_eval(eval_string)
        eval_string.sub(/\A(eval\(\\?["'])*/, '').sub(/(\\?["']\))*\z/, '')
      end

      def sanitize_newlines(eval_string)
        eval_string.gsub(/\\n/, ?\n)
      end
    end
  end
end
