class SystemNavigation
  class InstructionStream
    class Decoder
      def self.with_iseq(_for: nil, with:, &block)
        iseqs = with.iseqs(_for)

        iseqs.select.with_index do |instruction, idx|
          block.call(iseqs, instruction, idx)
        end
      end

      def self.ivar_read_scan(_for:, with:)
        self.with_iseq(_for: _for, with: with) do |iseqs, instruction, idx|
          next(instruction) if instruction.gets_ivar?(_for)
          prev_instruction = iseqs[idx.pred]

          next(instruction) if instruction.dynamically_gets_ivar?(_for) && prev_instruction.putobjects?(_for)

          next unless performs_an_eval?(_for, instruction, prev_instruction)

          ivar_read_scan(_for: _for, with: iseq_from_eval(prev_instruction)).any?
        end
      end

      def self.ivar_write_scan(_for:, with:)
        self.with_iseq(_for: _for, with: with) do |iseqs, instruction, idx|
          next(instruction) if instruction.writes_ivar?(_for)
          prev_instruction = iseqs[idx.pred]

          next(instruction) if instruction.dynamically_writes_ivar?(_for) && prev_instruction.putobjects?(_for)

          next unless performs_an_eval?(_for, instruction, prev_instruction)

          ivar_write_scan(_for: _for, with: iseq_from_eval(prev_instruction)).any?
        end
      end

      def self.literal_scan(_for:, with:)
        name = with.unbound_method.original_name

        self.with_iseq(_for: name, with: with) do |iseqs, instruction, idx|
          next(instruction) if instruction.putobjects?(_for) || instruction.duparrays?(_for)

          prev_instruction = iseqs[idx.pred]

          next unless performs_an_eval?(_for, instruction, prev_instruction)

          literal_scan(_for: _for, with: iseq_from_eval(prev_instruction, with.unbound_method)).any?
        end
      end

      def self.msg_send_scan(_for:, with:)
        self.with_iseq(_for: _for, with: with) do |iseqs, instruction, idx|
          next(instruction) if instruction.sends_msg?(_for)

          prev_instruction = iseqs[idx.pred]

          next unless performs_an_eval?(_for, instruction, prev_instruction)

          msg_send_scan(_for: _for, with: iseq_from_eval(prev_instruction, with.unbound_method)).any?
        end
      end

      def self.scan_for_sent_messages(with:)
        with.iseqs(nil).map do |instruction|
          instruction.find_message
        end.compact
      end

      private

      def self.performs_an_eval?(_for, instruction, prev_instruction)
        prev_instruction.putstrings?(_for) && instruction.evals?
      end

      def self.iseq_from_eval(instruction, method = nil)
        # Avoid segfault. See: https://bugs.ruby-lang.org/issues/11159
        uncompiled = instruction.evaling_str || nil.to_s

        iseq = RubyVM::InstructionSequence.compile(uncompiled).disasm
        InstructionStream.new(method: method, iseq: iseq)
      end
    end
  end
end
