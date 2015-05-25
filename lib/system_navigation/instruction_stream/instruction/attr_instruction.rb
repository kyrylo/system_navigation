class SystemNavigation
  class InstructionStream
    class Instruction
      class AttrInstruction < Instruction
        def self.parse(method, sym)
          instr = self.new(method)
          self.attrreaderinstr(instr, sym) || self.attrwriterinstr(instr, sym)
        end

        def self.attrreaderinstr(instr, sym)
          instr.accept(AttrReaderInstruction.new(sym)) && instr.parse
        end

        def self.attrwriterinstr(instr, sym)
          instr.accept(AttrWriterInstruction.new(sym)) && instr.parse
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

        private

        def convert_accessor_to_name(sym)
          sym.to_s.tr('@', '').downcase
        end
      end

      class AttrReaderInstruction < AttrInstruction
        def initialize(sym)
          @sym = sym
        end

        def visit(obj)
          matched = obj.method.original_name.to_s == convert_accessor_to_name(@sym)
          obj.visitor = self if matched
          matched
        end

        def reads_ivar?(_sym)
          true
        end

        def writes_ivar?(_sym)
          false
        end

        def putobjects?(sym)
          @sym == sym
        end
      end

      class AttrWriterInstruction < AttrInstruction
        def initialize(sym)
          @sym = sym
        end

        def visit(obj)
          name = obj.method.original_name.to_s
          matched = (name[-1] == '=') && (name[0..-2] == convert_accessor_to_name(@sym))
          obj.visitor = self if matched
          matched
        end

        def reads_ivar?(_sym)
          false
        end

        def writes_ivar?(_sym)
          true
        end

        def putobjects?(sym)
          @sym == sym
        end
      end
    end
  end
end
