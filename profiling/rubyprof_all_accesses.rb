require 'ruby-prof'

require_relative '../lib/system_navigation'

sn = SystemNavigation.default

result = RubyProf.profile do
  sn.all_accesses(to: :@foo)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, {})

=begin
Measure Mode: wall_time
Thread ID: 70111957055840
Fiber ID: 70111959573520
Total: 3.652571
Sort by: self_time

 %self      total      self      wait     child     calls  name
 14.47      0.550     0.529     0.000     0.021     3673   FastMethodSource::MethodExtensions#source
  5.64      0.226     0.206     0.000     0.020     3673   FastMethodSource::MethodExtensions#comment
  5.60      0.205     0.205     0.000     0.000   262800   StringScanner#scan
  5.19      0.190     0.190     0.000     0.000   319026   StringScanner#skip
  4.99      0.310     0.182     0.000     0.128    76136   SystemNavigation::InstructionStream::Instruction#initialize
  4.52      1.589     0.165     0.000     1.424    76136   SystemNavigation::InstructionStream::Instruction#parse
  4.36      1.352     0.159     0.000     1.193   201212  *Class#new
  3.83      0.398     0.140     0.000     0.258    62258   SystemNavigation::InstructionStream::Instruction#parse_operand
  3.16      0.115     0.115     0.000     0.000   196056   StringScanner#peek
  2.81      0.103     0.103     0.000     0.000    71396   String#=~
  2.68      0.320     0.098     0.000     0.222    76136   SystemNavigation::InstructionStream::Instruction#parse_service_instruction
  2.64      0.096     0.096     0.000     0.000   212964   StringScanner#check
  2.47      0.275     0.090     0.000     0.185    17494   Array#select
  2.32      0.095     0.085     0.000     0.010     3673   <Class::RubyVM::InstructionSequence>#disasm
  2.09      0.204     0.076     0.000     0.128    62258   SystemNavigation::InstructionStream::Instruction#parse_position
  1.77      2.080     0.065     0.000     2.015    76136   <Class::SystemNavigation::InstructionStream::Instruction>#parse
  1.69      0.135     0.062     0.000     0.073    62258   SystemNavigation::InstructionStream::Instruction#parse_lineno
  1.54      0.148     0.056     0.000     0.092    62258   SystemNavigation::InstructionStream::Instruction#parse_opcode
  1.29      0.126     0.047     0.000     0.079    62258   SystemNavigation::InstructionStream::Instruction#parse_op_id                                                                 [96/17920]
  1.26      0.046     0.046     0.000     0.000    62258   SystemNavigation::InstructionStream::Instruction#sending?
  1.25      0.046     0.046     0.000     0.000    85954   StringScanner#initialize
  1.23      0.045     0.045     0.000     0.000    81220   String#to_i
  1.16      0.042     0.042     0.000     0.000    62258   SystemNavigation::InstructionStream::Instruction#accessing_ivar?
  1.06      0.092     0.039     0.000     0.053    62258   SystemNavigation::InstructionStream::Instruction#parse_ivar
  0.91      0.136     0.033     0.000     0.103    71396   Kernel#!~
  0.91      0.033     0.033     0.000     0.000     7346   String#split
  0.72      0.026     0.026     0.000     0.000    62258   SystemNavigation::InstructionStream::Instruction#evals?
  0.47      0.017     0.017     0.000     0.000    62258   SystemNavigation::InstructionStream::Instruction#vm_operative?
  0.42      0.844     0.015     0.000     0.828     3673   SystemNavigation::CompiledMethod#initialize
  0.42      2.290     0.015     0.000     2.274     7346   SystemNavigation::InstructionStream#iseqs
  0.41      0.015     0.015     0.000     0.000    31129   SystemNavigation::InstructionStream::Instruction#dynamically_writes_ivar?
  0.40      0.015     0.015     0.000     0.000    31129   SystemNavigation::InstructionStream::Instruction#writes_ivar?
  0.38      0.014     0.014     0.000     0.000    31129   SystemNavigation::InstructionStream::Instruction#reads_ivar?
  0.37      0.013     0.013     0.000     0.000    31129   SystemNavigation::InstructionStream::Instruction#dynamically_reads_ivar?
  0.35      3.558     0.013     0.000     3.545    70721  *Proc#call
  0.26      2.576     0.009     0.000     2.566     7346   SystemNavigation::CompiledMethod#scan_for
  0.24      2.549     0.009     0.000     2.540     7346   SystemNavigation::InstructionStream::Decoder#select_instructions
  0.23      3.566     0.008     0.000     3.558     7669  *Array#map
  0.21      0.244     0.008     0.000     0.237     7346   Enumerator#with_index
  0.20      0.016     0.007     0.000     0.009     7346   FastMethodSource::Method#name
  0.19      3.577     0.007     0.000     3.570     4524   SystemNavigation::MethodQuery#evaluate
  0.18      0.007     0.007     0.000     0.000    13944   Symbol#to_s
  0.18      0.242     0.007     0.000     0.236     3673   <Module::FastMethodSource>#comment_for
  0.16      0.011     0.006     0.000     0.005     4544   SystemNavigation::InstructionStream::Instruction::AttrWriterInstruction#visit
  0.16      1.292     0.006     0.000     1.286     3673   SystemNavigation::InstructionStream::Decoder#ivar_read_scan
  0.16      0.017     0.006     0.000     0.011     3673   <Class::SystemNavigation::InstructionStream>#on
  0.15      0.105     0.006     0.000     0.099     3673   SystemNavigation::CompiledMethod#compile
  0.15      0.006     0.006     0.000     0.000     7346   UnboundMethod#source_location
  0.15      0.011     0.006     0.000     0.006     7346   FastMethodSource::Method#source_location
  0.15      0.006     0.006     0.000     0.000     4454   Exception#initialize
  0.15      0.017     0.005     0.000     0.012     1165   SystemNavigation::MethodHash#initialize
  0.14      1.268     0.005     0.000     1.263     3673   SystemNavigation::InstructionStream::Decoder#ivar_write_scan
  0.14      0.005     0.005     0.000     0.000     4790   Module#instance_method
  0.14      0.005     0.005     0.000     0.000     7346   Kernel#respond_to?
  0.14      0.005     0.005     0.000     0.000     7346   FastMethodSource::Method#initialize
  0.14      0.005     0.005     0.000     0.000     6770   Array#concat
  0.14      0.038     0.005     0.000     0.033     9088   SystemNavigation::InstructionStream::Instruction::AttrInstruction#accept
  0.14      0.022     0.005     0.000     0.017     4544   SystemNavigation::InstructionStream::Instruction::AttrReaderInstruction#visit
  0.13      0.005     0.005     0.000     0.000     4798   String#tr
  0.13      0.005     0.005     0.000     0.000    15035   Array#any?
  0.13      0.015     0.005     0.000     0.010     4798   SystemNavigation::InstructionStream::Instruction::AttrInstruction#convert_accessor_to_name
  0.13      0.073     0.005     0.000     0.068     4544   <Class::SystemNavigation::InstructionStream::Instruction::AttrInstruction>#parse
  0.12      0.561     0.005     0.000     0.556     3673   <Module::FastMethodSource>#source_for
  0.12      0.099     0.004     0.000     0.095     3673   SystemNavigation::InstructionStream#decode
  0.12      0.004     0.004     0.000     0.000     3145   Array#compact
  0.11      3.581     0.004     0.000     3.577      754   Hash#each
  0.11      0.006     0.004     0.000     0.002     7346   SystemNavigation::InstructionStream#scan_for                                                                                 [48/17920]
  0.11      0.004     0.004     0.000     0.000     2773   Symbol#inspect
  0.11      0.008     0.004     0.000     0.004      750   Array#-
  0.11      0.958     0.004     0.000     0.954     3673   <Class::SystemNavigation::CompiledMethod>#compile
  0.11      0.004     0.004     0.000     0.000     6669   Kernel#hash
  0.10      0.004     0.004     0.000     0.000     9818   StringScanner#terminate
  0.10      0.004     0.004     0.000     0.000     4047   Fixnum#inspect
  0.10      1.304     0.004     0.000     1.300     3673   SystemNavigation::CompiledMethod#reads_field?
  0.10      0.003     0.003     0.000     0.000     7346   UnboundMethod#name
  0.09      0.003     0.003     0.000     0.000     6880   String#[]
  0.09      0.004     0.003     0.000     0.001        1   <Module::ObjectSpace>#each_object
  0.09      0.003     0.003     0.000     0.000     3673   SystemNavigation::InstructionStream#initialize
  0.09      0.035     0.003     0.000     0.031     4544   <Class::SystemNavigation::InstructionStream::Instruction::AttrInstruction>#attrreaderinstr
  0.08      0.024     0.003     0.000     0.022     4544   <Class::SystemNavigation::InstructionStream::Instruction::AttrInstruction>#attrwriterinstr
  0.08      0.010     0.003     0.000     0.007      750   #<refinement:Array@SystemNavigation::ArrayRefinement>#split
  0.07      0.003     0.003     0.000     0.000     3673   SystemNavigation::InstructionStream::Decoder#initialize
  0.07      0.003     0.003     0.000     0.000     3950   String#rstrip
  0.07      0.003     0.003     0.000     0.000      822   Module#public_instance_methods
  0.07      0.002     0.002     0.000     0.000      754   SystemNavigation::MethodHash#empty_hash
  0.06      0.002     0.002     0.000     0.000     1874   Kernel#singleton_class
  0.06      0.002     0.002     0.000     0.000     4544   SystemNavigation::InstructionStream::Instruction::AttrInstruction#initialize
  0.06      0.002     0.002     0.000     0.000     9088   UnboundMethod#original_name
  0.06      1.278     0.002     0.000     1.276     3673   SystemNavigation::CompiledMethod#writes_field?
  0.06      3.597     0.002     0.000     3.595      754   <Class::SystemNavigation::MethodQuery>#execute
  0.05      0.002     0.002     0.000     0.000     4798   String#downcase
  0.05      0.002     0.002     0.000     0.000     4544   SystemNavigation::InstructionStream::Instruction::AttrReaderInstruction#initialize
  0.05      0.002     0.002     0.000     0.000     4544   SystemNavigation::InstructionStream::Instruction::AttrWriterInstruction#initialize
  0.05      0.002     0.002     0.000     0.001      204   Array#|
  0.04      0.002     0.002     0.000     0.000     2245   Array#shift
  0.04      0.002     0.002     0.000     0.000      822   Module#private_instance_methods
  0.04      0.002     0.002     0.000     0.000     2082   String#to_sym
  0.04      0.002     0.002     0.000     0.000      822   Module#protected_instance_methods
  0.04      0.002     0.002     0.000     0.000     2802   Symbol#to_proc
  0.04      0.012     0.001     0.000     0.011      750   SystemNavigation::AncestorMethodFinder#find_closest_ancestors
  0.04      0.001     0.001     0.000     0.000     4454   Exception#exception
  0.04      3.647     0.001     0.000     3.645      343   #<refinement:Module@SystemNavigation::ModuleRefinement>#select_methods_that_access
  0.04      0.001     0.001     0.000     0.000     4454   Exception#backtrace
  0.03      0.001     0.001     0.000     0.000     1165   Kernel#proc
  0.03      0.001     0.001     0.000     0.000     1058   String#inspect
  0.03      0.010     0.001     0.000     0.009      750   SystemNavigation::AncestorMethodFinder#initialize
  0.03      3.583     0.001     0.000     3.581      754   Enumerable#inject
  0.03      0.001     0.001     0.000     0.000     1165   Hash#initialize
  0.03      0.001     0.001     0.000     0.000     1496   Array#index
  0.03      0.001     0.001     0.000     0.000     4524   Kernel#nil?
  0.03      0.001     0.001     0.000     0.000     4728   Hash#[]
  0.03      0.001     0.001     0.000     0.000     4558   Module#===
  0.03      3.590     0.001     0.000     3.589      754   SystemNavigation::MethodQuery#instance_and_singleton_do
  0.03      0.038     0.001     0.000     0.037      375   <Class::SystemNavigation::AncestorMethodFinder>#find_all_ancestors
  0.03      0.001     0.001     0.000     0.000      343   Array#flatten
  0.03      0.001     0.001     0.000     0.000      750   Module#ancestors
  0.02      0.011     0.001     0.000     0.010      343   #<refinement:Module@SystemNavigation::ModuleRefinement>#own_selectors
  0.02      0.001     0.001     0.000     0.000     1496   Array#last
  0.02      0.025     0.001     0.000     0.024      750   SystemNavigation::AncestorMethodFinder#find_all_methods
  0.02      0.001     0.001     0.000     0.000      754   SystemNavigation::MethodQuery#initialize
  0.02      0.003     0.001     0.000     0.003     1301  *Hash#merge!
  0.02      0.002     0.001     0.000     0.001      750   Kernel#dup
  0.02      0.001     0.001     0.000     0.000      750   Array#initialize_copy
  0.02      0.028     0.001     0.000     0.027      411   SystemNavigation::MethodQuery#convert_to_methods
  0.02      0.001     0.001     0.000     0.000     3429   UnboundMethod#hash
  0.02      0.001     0.001     0.000     0.000      342   Array#unshift
  0.02      0.035     0.001     0.000     0.034      343   #<refinement:Module@SystemNavigation::ModuleRefinement>#own_methods
  0.02      0.001     0.001     0.000     0.001      750   Kernel#initialize_dup
  0.01      3.648     0.001     0.000     3.648      686  *Enumerator::Yielder#<<
  0.01      0.038     0.000     0.000     0.038      375   #<refinement:Module@SystemNavigation::ModuleRefinement>#ancestor_methods
  0.01      0.000     0.000     0.000     0.000      751   Class#superclass
  0.01      0.001     0.000     0.000     0.000       41   SystemNavigation::InstructionStream::Instruction#putobjects?
  0.01      0.013     0.000     0.000     0.012      411   <Class::SystemNavigation::MethodHash>#create
  0.01      3.565     0.000     0.000     3.564      343   SystemNavigation::MethodQuery#find_accessing_methods
  0.01      0.000     0.000     0.000     0.000      750   Array#first
  0.01      0.003     0.000     0.000     0.003      343   SystemNavigation::MethodHash#as_array
  0.01      0.001     0.000     0.000     0.000      113   Array#inspect
  0.01      0.000     0.000     0.000     0.000      343   Hash#values
  0.01      0.000     0.000     0.000     0.000      750   Kernel#is_a?
  0.01      3.648     0.000     0.000     3.648      852  *Array#each
  0.01      0.000     0.000     0.000     0.000       30   Regexp#match
  0.00      0.000     0.000     0.000     0.000      131   Regexp#inspect
  0.00      0.000     0.000     0.000     0.000      186   FalseClass#inspect
  0.00      3.653     0.000     0.000     3.652        1   Global#[No method]
  0.00      0.000     0.000     0.000     0.000       20   Module#inspect
  0.00      0.000     0.000     0.000     0.000      236   UnboundMethod#eql?
  0.00      0.000     0.000     0.000     0.000       10   SystemNavigation::InstructionStream::Instruction#putstrings?
  0.00      0.000     0.000     0.000     0.000       69   TrueClass#inspect
  0.00      0.000     0.000     0.000     0.000       30   String#match
  0.00      0.000     0.000     0.000     0.000        6   Range#inspect
  0.00      0.000     0.000     0.000     0.000        4   Float#inspect
  0.00      3.652     0.000     0.000     3.652        1   SystemNavigation#all_accesses
  0.00      3.652     0.000     0.000     3.652        2  *Enumerator::Generator#each
  0.00      3.652     0.000     0.000     3.652      751  *Enumerable#flat_map
  0.00      0.000     0.000     0.000     0.000        2   Enumerator#initialize
  0.00      0.004     0.000     0.000     0.004        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#all_subclasses
  0.00      0.000     0.000     0.000     0.000        1   Array#push
  0.00      0.000     0.000     0.000     0.000        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#with_all_superclasses
  0.00      3.652     0.000     0.000     3.652        2  *Enumerator#each
  0.00      0.000     0.000     0.000     0.000        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#with_all_sub_and_superclasses
  0.00      0.000     0.000     0.000     0.000        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#with_all_subclasses

* indicates recursively called methods
=end
