require 'stackprof'

require_relative '../lib/system_navigation'

sn = SystemNavigation.default

# To read the report run:
#   stackprof d.dump --text
StackProf.run(mode: :cpu, out: 'all_accesses.dump') do
  sn.all_accesses(to: :@foo)
end

=begin
==================================
  Mode: cpu(1000)
  Samples: 356 (2.73% miss rate)
  GC: 39 (10.96%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
        92  (25.8%)          92  (25.8%)     #<Module:0x007f51fe19c5b0>.source_for
        44  (12.4%)          43  (12.1%)     #<Module:0x007f51fe19c5b0>.comment_for
        27   (7.6%)          27   (7.6%)     SystemNavigation::InstructionStream::Instruction#initialize
        23   (6.5%)          23   (6.5%)     SystemNavigation::InstructionStream::Instruction#parse_service_instruction
        21   (5.9%)          21   (5.9%)     SystemNavigation::InstructionStream::Instruction#parse_operand
        16   (4.5%)          16   (4.5%)     SystemNavigation::InstructionStream#decode
        15   (4.2%)          15   (4.2%)     SystemNavigation::InstructionStream::Instruction#parse_position
        10   (2.8%)          10   (2.8%)     SystemNavigation::InstructionStream::Instruction#parse_opcode
        10   (2.8%)          10   (2.8%)     SystemNavigation::InstructionStream::Instruction#sending?
         6   (1.7%)           6   (1.7%)     SystemNavigation::InstructionStream::Instruction#parse_lineno
         6   (1.7%)           6   (1.7%)     SystemNavigation::InstructionStream#initialize
         5   (1.4%)           5   (1.4%)     SystemNavigation::InstructionStream::Instruction#reads_ivar?
         5   (1.4%)           5   (1.4%)     SystemNavigation::InstructionStream::Instruction#writes_ivar?
         5   (1.4%)           5   (1.4%)     SystemNavigation::InstructionStream::Instruction#accessing_ivar?
         4   (1.1%)           4   (1.1%)     SystemNavigation::InstructionStream::Instruction#evals?
         4   (1.1%)           4   (1.1%)     rescue in SystemNavigation::CompiledMethod#initialize
         3   (0.8%)           3   (0.8%)     SystemNavigation::MethodHash#initialize
       127  (35.7%)           2   (0.6%)     SystemNavigation::InstructionStream#iseqs
       311  (87.4%)           2   (0.6%)     SystemNavigation::MethodQuery#evaluate
         2   (0.6%)           2   (0.6%)     SystemNavigation::InstructionStream::Instruction::AttrWriterInstruction#visit
       120  (33.7%)           1   (0.3%)     block in SystemNavigation::InstructionStream#iseqs
       145  (40.7%)           1   (0.3%)     SystemNavigation::InstructionStream::Decoder#select_instructions
        74  (20.8%)           1   (0.3%)     block in SystemNavigation::CompiledMethod#reads_field?
        17   (4.8%)           1   (0.3%)     block in SystemNavigation::InstructionStream::Decoder#select_instructions
        11   (3.1%)           1   (0.3%)     SystemNavigation::InstructionStream::Instruction#parse_op_id
         6   (1.7%)           1   (0.3%)     SystemNavigation::InstructionStream::Instruction#parse_ivar
         1   (0.3%)           1   (0.3%)     #<Module:0x007f51fe547b10>#split
         1   (0.3%)           1   (0.3%)     SystemNavigation::InstructionStream::Instruction#dynamically_writes_ivar?
         1   (0.3%)           1   (0.3%)     SystemNavigation::AncestorMethodFinder#initialize
         1   (0.3%)           1   (0.3%)     SystemNavigation::MethodQuery#initialize
=end
