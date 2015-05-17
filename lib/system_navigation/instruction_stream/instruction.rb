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
        getinstancevariable? && @unparsed =~ /\A:#{ivar}/
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
        putobject? && @unparsed =~ /\A:#{str}/
      end

      def evaling_str
        @evaling_str ||= parse_evaling_str
      end

      def writes_ivar?(ivar)
        setinstancevariable? && @unparsed =~ /\A:#{ivar}/
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

    module AccessorHelpers
      def convert_accessor_to_name(sym)
        sym.to_s.tr('@', '').downcase
      end
    end

    class AttrInstruction < Instruction
      include AccessorHelpers

      def self.parse(method, ivar)
        instr = self.new(method)
        self.attrreaderinstr(instr, ivar) || self.attrwriterinstr(instr, ivar)
      end

      def self.attrreaderinstr(instr, ivar)
        instr.accept(AttrReaderInstruction.new(ivar)) && instr.parse
      end

      def self.attrwriterinstr(instr, ivar)
        instr.accept(AttrWriterInstruction.new(ivar)) && instr.parse
      end

      attr_accessor :visitor
      attr_reader :method

      def initialize(method)
        @method = method
      end

      def accept(visitor)
        visitor.visit(self)
      end

      def parse
        [self.visitor]
      end
    end

    class AttrReaderInstruction < AttrInstruction
      def initialize(ivar)
        @ivar = ivar
      end

      def visit(obj)
        matched = obj.method.original_name.to_s == convert_accessor_to_name(@ivar)
        obj.visitor = self if matched
        matched
      end

      def gets_ivar?(_ivar)
        true
      end

      def writes_ivar?(_ivar)
        false
      end
    end

    class AttrWriterInstruction < AttrInstruction
      def initialize(ivar)
        @ivar = ivar
      end

      def visit(obj)
        name = obj.method.original_name.to_s
        matched = name[-1] == '=' && name[0..-2] == convert_accessor_to_name(@ivar)
        obj.visitor = self if matched
        matched
      end

      def gets_ivar?(_ivar)
        false
      end

      def writes_ivar?(_ivar)
        true
      end
    end
  end
end
