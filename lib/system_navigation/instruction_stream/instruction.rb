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
        @ivar = nil
        @gvar = nil
        @cvar = nil
        @service_instruction = false
      end

      def parse
        return if parse_service_instruction

        parse_position
        parse_opcode
        parse_operand
        parse_lineno
        parse_op_id
        parse_var

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
          @operand = @raw.scan(/-?[0-9a-zA-Z:@_=.$]+/)

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

        callinfo = StringScanner.new(@operand)
        callinfo.skip(/<callinfo!mid:/)
        @op_id = callinfo.scan(/\S+(?=,)/)
        callinfo.terminate
      end

      def parse_var
        parse_ivar
        parse_gvar
        parse_cvar
      end

      def parse_ivar
        return unless accessing_ivar?

        ivar = StringScanner.new(@operand)
        @ivar = ivar.scan(/:[^,]+/)[1..-1].to_sym
        ivar.terminate
        @ivar
      end

      def parse_gvar
        return unless accessing_gvar?

        gvar = StringScanner.new(@operand)
        @gvar = gvar.scan(/[^,]+/).to_sym
        gvar.terminate
        @gvar
      end

      def parse_cvar
        return unless accessing_cvar?

        cvar = StringScanner.new(@operand)
        @cvar = cvar.scan(/:[^,]+/)[1..-1].to_sym
        cvar.terminate
        @cvar
      end

      def accessing_ivar?
        @opcode == 'getinstancevariable' || @opcode == 'setinstancevariable'
      end

      def accessing_gvar?
        @opcode == 'getglobal' || @opcode == 'setglobal'
      end

      def accessing_cvar?
        @opcode == 'getclassvariable' || @opcode == 'setclassvariable'
      end

      def vm_operative?
        @service_instruction == false
      end

      def reads_ivar?(ivar)
        @opcode == 'getinstancevariable' && @ivar == ivar
      end

      def writes_ivar?(ivar)
        @opcode == 'setinstancevariable' && @ivar == ivar
      end

      def dynamically_reads_ivar?
        self.op_id == 'instance_variable_get'
      end

      def dynamically_writes_ivar?
        @op_id == 'instance_variable_set'
      end

      def reads_gvar?(gvar)
        @opcode == 'getglobal' && @gvar == gvar
      end

      def writes_gvar?(gvar)
        @opcode == 'setglobal' && @gvar == gvar
      end

      def reads_cvar?(cvar)
        @opcode == 'getclassvariable' && @cvar == cvar
      end

      def writes_cvar?(cvar)
        @opcode == 'setclassvariable' && @cvar == cvar
      end

      def evals?
        self.op_id == 'eval'
      end

      def putstrings?(str)
        return false unless self.opcode == 'putstring'

        s = str.inspect

        return true if @operand == s || @operand == %|"#{s}"|
        if @operand.match(/(eval\()?.*:?#{str}[^[\w;]].*\)?/)
          return true
        else

        end

        false
      end

      def putobjects?(str)
        return false unless @opcode == 'putobject'

        s = (str.instance_of?(String) ? Regexp.escape(str) : str)

        return true if @operand.match(/(?::#{s}\z|\[.*:#{s},.*\])/)
        return true if @operand == str.inspect

        false
      end

      def putnils?(str)
        return false unless self.opcode == 'putnil'
        @operand == str.inspect
      end

      def duparrays?(str)
        s = case str
            when Array, Hash then Regexp.escape(str.inspect)
            else str
            end

        !!(self.opcode == 'duparray' && @operand.match(/:#{s}[,\]]/))
      end

      def sends_msg?(message)
        !!(sending? && @op_id == message.to_s)
      end

      def evaling_str
        @evaling_str ||= @operand.sub!(/\A"(.+)"/, '\1')
      end

      def find_message
        return unless sending?

        @op_id
      end

      private

      def sending?
        @opcode == 'opt_send_without_block' || @opcode == 'send'
      end

      protected

      attr_reader :opcode, :op_id
    end
  end
end
