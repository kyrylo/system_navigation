class SystemNavigation
  class InstructionStream
    class Instruction
     class AttrInstruction < Instruction
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

       private

       def convert_accessor_to_name(sym)
         sym.to_s.tr('@', '').downcase
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
end
