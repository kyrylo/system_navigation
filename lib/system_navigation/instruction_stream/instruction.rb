class SystemNavigation
  class InstructionStream
    class Instruction
      def self.parse(str)
        self.new(str).parse
      end

      def initialize(str)
        @raw = StringScanner.new(str)
        @pos = nil
        @opcode = ''
        @operand = nil
        @evaling_str = nil
        @lineno = nil
        @op_id = nil
        @service_instruction = false
      end

      def parse
        return if parse_service_instruction

        parse_position
        parse_opcode
        parse_operand
        parse_lineno
        parse_op_id

        self
      end

      def parse_service_instruction
        if @raw.peek(2) == '==' || @raw.peek(6) !~ /[0-9]{4,6} /
          @service_instruction = true
        end
      end

      def parse_position
        n = @raw.scan(/[0-9]{4,6}/)
        @pos = n.to_i if n
        @raw.skip(/\s*/)
      end

      def parse_opcode
        @opcode = @raw.scan(/[a-zA-Z0-9_]+/)
        @raw.skip(/\s*/)
      end

      def parse_operand
        if @raw.check(/</)
          @operand = @raw.scan(/<.+>/)
        elsif @raw.check(/\[/)
          @operand = @raw.scan(/\[.*\]/)
        elsif @raw.check(/"/)
          @operand = @raw.scan(/".*"/)
        elsif @raw.check(%r{/})
          @operand = @raw.scan(%r{/.*/})
        else
          @operand = @raw.scan(/-?[0-9a-zA-Z:@_=]+/)

          if @raw.peek(1) == ','
            @operand << @raw.scan(/[^\(]*/).rstrip
          end
        end

        @raw.skip(/\s*\(?/)
        @raw.skip(/\s*/)
      end

      def parse_lineno
        n = @raw.scan(/[0-9]+/)
        @lineno = n.to_i if n
        @raw.skip(/\)/)
      end

      def parse_op_id
        return unless sending?

        callinfo = StringScanner.new @operand
        callinfo.skip(/<callinfo!mid:/)
        @op_id = callinfo.scan(/\S+(?=,)/)
        callinfo.terminate
      end

      def vm_operative?
        @service_instruction == false
      end

      def gets_ivar?(ivar)
        !!(@opcode == 'getinstancevariable' && @operand == ":#{ivar}")
      end

      def dynamically_gets_ivar?(ivar)
        @op_id == 'instance_variable_get'
      end

      def dynamically_writes_ivar?(ivar)
        @op_id == 'instance_variable_set'
      end

      def evals?
        @op_id == 'eval'
      end

      def putstrings?(str)
        !!(@opcode == 'putstring' && @operand.match(/".*#{str}.*"/))
      end

      def putobjects?(str)
        !!(@opcode == 'putobject' && @operand.match(":#{str}"))
      end

      def duparrays?(str)
        !!(@opcode == 'duparray' && @operand.match(":#{str}"))
      end

      def writes_ivar?(ivar)
        !!(@opcode == 'setinstancevariable' && @operand == ":#{ivar}=")
      end

      def sends_msg?(message)
        !!(sending? && @op_id == message)
      end

      def operand
        @operand
      end

      def evaling_str
        @evaling_str ||= @operand.sub!(/\A"(.+)"/, '\1')
      end

      private

      def sending?
        @opcode == 'opt_send_without_block' || @opcode == 'send'
      end
    end
  end
end
