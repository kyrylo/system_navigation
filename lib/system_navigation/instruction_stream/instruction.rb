class SystemNavigation
  class InstructionStream
    class Instruction
      INSTR_POS_PATTERN = /\A[0-9]+\s/

      def self.parse(str)
        self.new(str).parse
      end

      def initialize(str)
        @instruction = ''
        @pos = 0
        @evaling_str = nil
        @unparsed = str
        @raw_instruction = str.dup
      end

      def parse
        unless service_instruction?
          @pos = parse_pos
          @instruction = parse_instruction
        end

        self
      end

      def gets_ivar?(ivar)
        getinstancevariable? && @unparsed =~ /\A:#{ivar},/
      end

      def dynamically_gets_ivar?(ivar)
        opt_send_without_block? && @unparsed =~ /\A<callinfo!mid:instance_variable_get/
      end

      def dynamically_writes_ivar?(ivar)
        opt_send_without_block? && @unparsed =~ /\A<callinfo!mid:instance_variable_set/
      end

      def evals?
        opt_send_without_block? && @unparsed =~ /\A<callinfo!mid:eval/
      end

      def putstrings?(str)
        putstring? && @unparsed =~ /\A".*#{str}.*"/
      end

      def putobjects?(str)
        putobject? &&
          (
            @unparsed =~ /\A:#{str}\s*(?:\([0-9\s]+\))?\z/ ||
            @unparsed =~ /\A\[.*:#{str}.*\]\s*(?:\([0-9\s]+\))?\z/
          )
      end

      def duparrays?(str)
        duparray? && @unparsed =~ /\A\[.*:#{str}.*\]\s*(?:\([0-9\s]+\))?\z/
      end

      def evaling_str
        @evaling_str ||= parse_evaling_str
      end

      def writes_ivar?(ivar)
        setinstancevariable? && @unparsed =~ /\A:#{ivar},/
      end

      def sends_msg?(message)
        (opt_send_without_block? || send?) && @unparsed =~ /\A<callinfo!mid:#{message}/
      end

      private

      def getinstancevariable?
        @instruction == 'getinstancevariable'
      end

      def opt_send_without_block?
        @instruction == 'opt_send_without_block'
      end

      def putstring?
        @instruction == 'putstring'
      end

      def putobject?
        @instruction == 'putobject'
      end

      def setinstancevariable?
        @instruction == 'setinstancevariable'
      end

      def duparray?
        @instruction == 'duparray'
      end

      def send?
        @instruction == 'send'
      end

      def parse_pos
        @unparsed.sub!(INSTR_POS_PATTERN, '')
        $MATCH.to_i
      end

      def parse_instruction
        @unparsed.sub!(/\A[a-zA-Z0-9_]+\s+/, '')
        $MATCH.rstrip
      end

      def parse_evaling_str
        @unparsed.sub!(/\A"(.+)"/, '')
        $1
      end

      def service_instruction?
        @raw_instruction !~ INSTR_POS_PATTERN
      end
    end
  end
end
