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
  Samples: 202 (0.00% miss rate)
  GC: 32 (15.84%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
        28  (13.9%)          28  (13.9%)     SystemNavigation::InstructionStream::Instruction#initialize
        23  (11.4%)          23  (11.4%)     SystemNavigation::InstructionStream::Instruction#parse_operand
        22  (10.9%)          22  (10.9%)     SystemNavigation::InstructionStream::Instruction#parse_service_instruction
        16   (7.9%)          16   (7.9%)     SystemNavigation::InstructionStream#decode
        10   (5.0%)          10   (5.0%)     SystemNavigation::InstructionStream::Instruction#parse_position
        10   (5.0%)           9   (4.5%)     #<Module:0x007f521a8ea3c8>.source_for
         8   (4.0%)           8   (4.0%)     SystemNavigation::InstructionStream::Instruction#accessing_ivar?
         6   (3.0%)           6   (3.0%)     SystemNavigation::InstructionStream::Instruction#parse_lineno
       120  (59.4%)           5   (2.5%)     SystemNavigation::InstructionStream#iseqs
         5   (2.5%)           5   (2.5%)     SystemNavigation::InstructionStream::Instruction#writes_ivar?
         5   (2.5%)           5   (2.5%)     SystemNavigation::InstructionStream::Instruction#sending?
         5   (2.5%)           5   (2.5%)     SystemNavigation::InstructionStream::Instruction#parse_opcode
         3   (1.5%)           3   (1.5%)     SystemNavigation::MethodHash#initialize
         3   (1.5%)           3   (1.5%)     #<Module:0x007f521a8ea3c8>.comment_for
         3   (1.5%)           3   (1.5%)     rescue in SystemNavigation::CompiledMethod#initialize
       166  (82.2%)           2   (1.0%)     SystemNavigation::MethodQuery#evaluate
         2   (1.0%)           2   (1.0%)     SystemNavigation::InstructionStream#initialize
         2   (1.0%)           2   (1.0%)     SystemNavigation::InstructionStream::Instruction#dynamically_writes_ivar?
         7   (3.5%)           2   (1.0%)     SystemNavigation::InstructionStream::Instruction#parse_op_id
         2   (1.0%)           2   (1.0%)     SystemNavigation::InstructionStream::Instruction#vm_operative?
       110  (54.5%)           1   (0.5%)     SystemNavigation::InstructionStream::Instruction.parse
       111  (55.0%)           1   (0.5%)     block in SystemNavigation::InstructionStream#iseqs
        20   (9.9%)           1   (0.5%)     SystemNavigation::CompiledMethod#initialize
         1   (0.5%)           1   (0.5%)     SystemNavigation::InstructionStream::Instruction#evals?
         1   (0.5%)           1   (0.5%)     SystemNavigation::InstructionStream::Instruction::AttrReaderInstruction#initialize
         1   (0.5%)           1   (0.5%)     SystemNavigation::InstructionStream::Instruction::AttrWriterInstruction#visit
         1   (0.5%)           1   (0.5%)     FastMethodSource::Method#name
         1   (0.5%)           1   (0.5%)     rescue in SystemNavigation::CompiledMethod#initialize
         1   (0.5%)           1   (0.5%)     SystemNavigation::MethodQuery#initialize
        81  (40.1%)           0   (0.0%)     SystemNavigation::InstructionStream::Instruction#parse
=end
