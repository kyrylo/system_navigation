class SystemNavigation
  class InstructionStream
    class Decoder
      def with_iseq(_for: nil, with:, &block)
        iseqs = with.iseqs(_for)

        iseqs.select.with_index do |instruction, idx|
          block.call(iseqs, instruction, idx)
        end
      end

      def ivar_read_scan(_for:, with:)
        self.with_iseq(_for: _for, with: with) do |iseqs, instruction, idx|
          next(instruction) if instruction.reads_ivar?(_for)
          prev_instruction = iseqs[idx.pred]

          next(instruction) if instruction.dynamically_reads_ivar? && prev_instruction.putobjects?(_for)

          next unless performs_an_eval?(_for, instruction, prev_instruction)

          ivar_read_scan(_for: _for, with: iseq_from_eval(prev_instruction)).any?
        end
      end

      def ivar_write_scan(_for:, with:)
        self.with_iseq(_for: _for, with: with) do |iseqs, instruction, idx|
          next(instruction) if instruction.writes_ivar?(_for)
          prev_instruction = iseqs[idx.pred]

          next(instruction) if instruction.dynamically_writes_ivar? && prev_instruction.putobjects?(_for)

          next unless performs_an_eval?(_for, instruction, prev_instruction)

          ivar_write_scan(_for: _for, with: iseq_from_eval(prev_instruction)).any?
        end
      end

      def literal_scan(_for:, with:)
        name = with.method.original_name

        self.with_iseq(_for: name, with: with) do |iseqs, instruction, idx|
          next(instruction) if instruction.putobjects?(_for) || instruction.duparrays?(_for)

          prev_instruction = iseqs[idx.pred]

          next unless performs_an_eval?(_for, instruction, prev_instruction)

          literal_scan(_for: _for, with: iseq_from_eval(prev_instruction, with.method)).any?
        end
      end

      def msg_send_scan(_for:, with:)
        self.with_iseq(_for: _for, with: with) do |iseqs, instruction, idx|
          next(instruction) if instruction.sends_msg?(_for)

          prev_instruction = iseqs[idx.pred]

          next unless performs_an_eval?(_for, instruction, prev_instruction)

          msg_send_scan(_for: _for, with: iseq_from_eval(prev_instruction, with.method)).any?
        end
      end

      def self.scan_for_sent_messages(with:)
        with.iseqs(nil).map do |instruction|
          instruction.find_message
        end.compact
      end

      private

      def performs_an_eval?(_for, instruction, prev_instruction)
        instruction.evals? && prev_instruction.putstrings?(_for)
      end

      def iseq_from_eval(instruction, method = nil)
        # Avoid segfault. See: https://bugs.ruby-lang.org/issues/11159
        uncompiled = instruction.evaling_str || nil.to_s

        iseq = RubyVM::InstructionSequence.compile(uncompiled).disasm
        InstructionStream.new(method: method, iseq: iseq)
      end
    end
  end
end
