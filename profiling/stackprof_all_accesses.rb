require 'stackprof'

require_relative '../lib/system-navigation'

sn = SystemNavigation.default

StackProf.run(mode: :cpu, out: 'all_accesses.dump') do
  sn.all_accesses(to: :@foo)
end

=begin
==================================
  Mode: cpu(1000)
  Samples: 2922 (0.10% miss rate)
  GC: 453 (15.50%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
      1128  (38.6%)        1128  (38.6%)     block in MethodSource::CodeHelpers#complete_expression?
       381  (13.0%)         381  (13.0%)     block in MethodSource::CodeHelpers#extract_last_comment
       175   (6.0%)         175   (6.0%)     SystemNavigation::InstructionStream::Instruction#initialize
       133   (4.6%)         133   (4.6%)     SystemNavigation::InstructionStream::Instruction#parse_service_instruction
       114   (3.9%)         114   (3.9%)     SystemNavigation::InstructionStream::Instruction#parse_operand
        88   (3.0%)          88   (3.0%)     SystemNavigation::InstructionStream#decode
        75   (2.6%)          75   (2.6%)     SystemNavigation::InstructionStream::Instruction#parse_position
      1224  (41.9%)          56   (1.9%)     MethodSource::CodeHelpers#complete_expression?
        41   (1.4%)          41   (1.4%)     SystemNavigation::InstructionStream::Instruction#parse_opcode
        39   (1.3%)          39   (1.3%)     #<Module:0x007f53550e66e0>.===
        27   (0.9%)          27   (0.9%)     SystemNavigation::InstructionStream::Instruction#parse_lineno
        21   (0.7%)          21   (0.7%)     SystemNavigation::InstructionStream::Instruction#sending?
        41   (1.4%)          20   (0.7%)     SystemNavigation::InstructionStream::Instruction#parse_op_id
        20   (0.7%)          20   (0.7%)     SystemNavigation::InstructionStream::Instruction#accessing_ivar?
        16   (0.5%)          16   (0.5%)     SystemNavigation::InstructionStream::Instruction#vm_operative?
        14   (0.5%)          14   (0.5%)     SystemNavigation::InstructionStream::Instruction#reads_ivar?
        13   (0.4%)          13   (0.4%)     SystemNavigation::InstructionStream::Instruction#writes_ivar?
       666  (22.8%)          12   (0.4%)     SystemNavigation::InstructionStream#iseqs
        10   (0.3%)          10   (0.3%)     SystemNavigation::InstructionStream::Instruction#evals?
         9   (0.3%)           9   (0.3%)     SystemNavigation::InstructionStream#initialize
      1232  (42.2%)           6   (0.2%)     block in MethodSource::CodeHelpers#extract_first_expression
         5   (0.2%)           5   (0.2%)     block in #<Module:0x007f5356772d00>#all_subclasses
       719  (24.6%)           5   (0.2%)     SystemNavigation::InstructionStream::Decoder#select_instructions
         5   (0.2%)           5   (0.2%)     SystemNavigation::InstructionStream::Instruction#dynamically_reads_ivar?
      2456  (84.1%)           4   (0.1%)     SystemNavigation::MethodQuery#evaluate
      1243  (42.5%)           4   (0.1%)     MethodSource::MethodExtensions#source
      1239  (42.4%)           3   (0.1%)     #<Module:0x007f53550fdfc0>.source_helper
         3   (0.1%)           3   (0.1%)     SystemNavigation::AncestorMethodFinder#initialize
         3   (0.1%)           3   (0.1%)     SystemNavigation::InstructionStream::Instruction::AttrWriterInstruction#visit
         4   (0.1%)           3   (0.1%)     SystemNavigation::MethodHash#initialize
=end
