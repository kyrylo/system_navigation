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
Thread ID: 70196480948580
Fiber ID: 70196484021440
Total: 3.163940
Sort by: self_time

 %self      total      self      wait     child     calls  name
  6.87      0.217     0.217     0.000     0.000   262800   StringScanner#scan
  6.23      0.335     0.197     0.000     0.138    76136   SystemNavigation::InstructionStream::Instruction#initialize
  6.20      0.196     0.196     0.000     0.000   319026   StringScanner#skip
  5.44      1.675     0.172     0.000     1.502    76136   SystemNavigation::InstructionStream::Instruction#parse
  5.42      0.744     0.172     0.000     0.572   201223  *Class#new
  4.51      0.420     0.143     0.000     0.277    62258   SystemNavigation::InstructionStream::Instruction#parse_operand
  3.86      0.122     0.122     0.000     0.000   196056   StringScanner#peek
  3.68      0.116     0.116     0.000     0.000    71396   String#=~
  3.28      0.104     0.104     0.000     0.000   212964   StringScanner#check
  3.21      0.343     0.102     0.000     0.242    76136   SystemNavigation::InstructionStream::Instruction#parse_service_instruction
  2.98      0.298     0.094     0.000     0.204    17498   Array#select
  2.87      0.101     0.091     0.000     0.011     3674   <Class::RubyVM::InstructionSequence>#disasm
  2.49      0.212     0.079     0.000     0.133    62258   SystemNavigation::InstructionStream::Instruction#parse_position
  2.16      2.204     0.068     0.000     2.135    76136   <Class::SystemNavigation::InstructionStream::Instruction>#parse
  2.06      0.141     0.065     0.000     0.076    62258   SystemNavigation::InstructionStream::Instruction#parse_lineno
  1.79      0.152     0.057     0.000     0.095    62258   SystemNavigation::InstructionStream::Instruction#parse_opcode
  1.77      0.078     0.056     0.000     0.022     3674   FastMethodSource::MethodExtensions#source
  1.60      0.051     0.051     0.000     0.000    62258   SystemNavigation::InstructionStream::Instruction#sending?
  1.54      0.134     0.049     0.000     0.085    62258   SystemNavigation::InstructionStream::Instruction#parse_op_id
  1.54      0.049     0.049     0.000     0.000    85954   StringScanner#initialize
  1.46      0.046     0.046     0.000     0.000    81220   String#to_i
  1.44      0.046     0.046     0.000     0.000    62258   SystemNavigation::InstructionStream::Instruction#accessing_ivar?
  1.33      0.100     0.042     0.000     0.058    62258   SystemNavigation::InstructionStream::Instruction#parse_ivar
  1.08      0.151     0.034     0.000     0.116    71396   Kernel#!~
  1.07      0.034     0.034     0.000     0.000     7348   String#split
  1.04      0.052     0.033     0.000     0.019     3674   FastMethodSource::MethodExtensions#comment
  0.93      0.029     0.029     0.000     0.000    62258   SystemNavigation::InstructionStream::Instruction#evals?
  0.57      0.018     0.018     0.000     0.000    62258   SystemNavigation::InstructionStream::Instruction#vm_operative?
  0.56      0.018     0.018     0.000     0.000    31129   SystemNavigation::InstructionStream::Instruction#reads_ivar?
  0.52      0.017     0.017     0.000     0.000    31129   SystemNavigation::InstructionStream::Instruction#dynamically_reads_ivar?
  0.48      2.418     0.015     0.000     2.402     7348   SystemNavigation::InstructionStream#iseqs
  0.48      0.015     0.015     0.000     0.000    31129   SystemNavigation::InstructionStream::Instruction#writes_ivar?
  0.46      0.195     0.014     0.000     0.181     3674   SystemNavigation::CompiledMethod#initialize
  0.45      0.014     0.014     0.000     0.000    31129   SystemNavigation::InstructionStream::Instruction#dynamically_writes_ivar?
  0.44      3.067     0.014     0.000     3.053    70723  *Proc#call
  0.32      2.726     0.010     0.000     2.715     7348   SystemNavigation::CompiledMethod#scan_for
  0.28      2.698     0.009     0.000     2.689     7348   SystemNavigation::InstructionStream::Decoder#select_instructions
  0.27      3.075     0.009     0.000     3.067     7669  *Array#map
  0.25      0.265     0.008     0.000     0.258     7348   Enumerator#with_index
  0.23      3.088     0.007     0.000     3.080     4524   SystemNavigation::MethodQuery#evaluate
  0.23      0.016     0.007     0.000     0.009     7348   FastMethodSource::Method#name
  0.19      0.011     0.006     0.000     0.005     4546   SystemNavigation::InstructionStream::Instruction::AttrWriterInstruction#visit
  0.19      0.006     0.006     0.000     0.000     4791   Module#instance_method
  0.18      0.011     0.006     0.000     0.005     7348   FastMethodSource::Method#source_location
  0.18      0.017     0.006     0.000     0.012     3674   <Class::SystemNavigation::InstructionStream>#on
  0.18      1.366     0.006     0.000     1.360     3674   SystemNavigation::InstructionStream::Decoder#ivar_read_scan
  0.17      0.006     0.006     0.000     0.000     7348   FastMethodSource::Method#initialize
  0.17      0.019     0.005     0.000     0.013     1165   SystemNavigation::MethodHash#initialize
  0.17      0.005     0.005     0.000     0.000    13950   Symbol#to_s
  0.17      0.005     0.005     0.000     0.000     7348   UnboundMethod#source_location
  0.17      0.005     0.005     0.000     0.000    15039   Array#any?
  0.16      0.066     0.005     0.000     0.061     3674   <Module::FastMethodSource>#comment_for
  0.16      0.005     0.005     0.000     0.000     6770   Array#concat
  0.16      0.005     0.005     0.000     0.000     7348   Kernel#respond_to?
  0.16      0.005     0.005     0.000     0.000     4454   Exception#initialize
  0.16      0.014     0.005     0.000     0.009     4800   SystemNavigation::InstructionStream::Instruction::AttrInstruction#convert_accessor_to_name
  0.16      1.342     0.005     0.000     1.337     3674   SystemNavigation::InstructionStream::Decoder#ivar_write_scan
  0.16      0.021     0.005     0.000     0.016     4546   SystemNavigation::InstructionStream::Instruction::AttrReaderInstruction#visit
  0.16      0.005     0.005     0.000     0.000     4800   String#tr
  0.15      0.106     0.005     0.000     0.101     3674   SystemNavigation::InstructionStream#decode
  0.15      0.005     0.005     0.000     0.000     3145   Array#compact
  0.15      0.037     0.005     0.000     0.032     9092   SystemNavigation::InstructionStream::Instruction::AttrInstruction#accept
  0.14      0.111     0.005     0.000     0.106     3674   SystemNavigation::CompiledMethod#compile
  0.14      0.072     0.004     0.000     0.068     4546   <Class::SystemNavigation::InstructionStream::Instruction::AttrInstruction>#parse
  0.14      0.007     0.004     0.000     0.003     7348   SystemNavigation::InstructionStream#scan_for
  0.13      0.089     0.004     0.000     0.085     3674   <Module::FastMethodSource>#source_for
  0.13      0.004     0.004     0.000     0.000     2773   Symbol#inspect
  0.13      3.092     0.004     0.000     3.088      754   Hash#each
  0.12      0.004     0.004     0.000     0.000     9818   StringScanner#terminate
  0.12      0.315     0.004     0.000     0.312     3674   <Class::SystemNavigation::CompiledMethod>#compile
  0.12      0.004     0.004     0.000     0.000     6669   Kernel#hash
  0.12      0.004     0.004     0.000     0.000     4047   Fixnum#inspect
  0.12      0.004     0.004     0.000     0.000     6882   String#[]
  0.12      0.004     0.004     0.000     0.000     7348   UnboundMethod#name
  0.12      0.008     0.004     0.000     0.004      750   Array#-
  0.11      0.004     0.004     0.000     0.000     3674   SystemNavigation::InstructionStream#initialize
  0.11      1.378     0.003     0.000     1.375     3674   SystemNavigation::CompiledMethod#reads_field?
  0.10      0.003     0.003     0.000     0.000     3950   String#rstrip
  0.09      0.033     0.003     0.000     0.031     4546   <Class::SystemNavigation::InstructionStream::Instruction::AttrInstruction>#attrreaderinstr
  0.09      0.003     0.003     0.000     0.000      822   Module#public_instance_methods
  0.09      0.010     0.003     0.000     0.007      750   #<refinement:Array@SystemNavigation::ArrayRefinement>#split
  0.09      0.003     0.003     0.000     0.000     3674   SystemNavigation::InstructionStream::Decoder#initialize
  0.09      0.003     0.003     0.000     0.000      754   SystemNavigation::MethodHash#empty_hash
  0.08      0.025     0.003     0.000     0.022     4546   <Class::SystemNavigation::InstructionStream::Instruction::AttrInstruction>#attrwriterinstr
  0.08      0.003     0.003     0.000     0.000     1874   Kernel#singleton_class
  0.07      1.353     0.002     0.000     1.351     3674   SystemNavigation::CompiledMethod#writes_field?
  0.07      0.002     0.002     0.000     0.000     4546   SystemNavigation::InstructionStream::Instruction::AttrInstruction#initialize
  0.07      0.002     0.002     0.000     0.000        1   <Module::ObjectSpace>#each_object
  0.06      3.108     0.002     0.000     3.106      754   <Class::SystemNavigation::MethodQuery>#execute
  0.06      0.002     0.002     0.000     0.000     4800   String#downcase
  0.06      0.002     0.002     0.000     0.000     9092   UnboundMethod#original_name
  0.06      0.002     0.002     0.000     0.000     2082   String#to_sym
  0.06      0.002     0.002     0.000     0.000     4546   SystemNavigation::InstructionStream::Instruction::AttrReaderInstruction#initialize
  0.06      0.002     0.002     0.000     0.000      822   Module#private_instance_methods
  0.06      0.002     0.002     0.000     0.000      822   Module#protected_instance_methods
  0.05      0.002     0.002     0.000     0.000     4546   SystemNavigation::InstructionStream::Instruction::AttrWriterInstruction#initialize
  0.05      0.002     0.002     0.000     0.001      204   Array#|
  0.05      0.002     0.002     0.000     0.000     2802   Symbol#to_proc
  0.05      0.002     0.002     0.000     0.000     2245   Array#shift
  0.05      3.160     0.002     0.000     3.158      343   #<refinement:Module@SystemNavigation::ModuleRefinement>#select_methods_that_access
  0.05      0.012     0.001     0.000     0.011      750   SystemNavigation::AncestorMethodFinder#find_closest_ancestors
  0.04      0.001     0.001     0.000     0.000     4454   Exception#backtrace
  0.04      0.001     0.001     0.000     0.000     1058   String#inspect
  0.04      0.010     0.001     0.000     0.009      750   SystemNavigation::AncestorMethodFinder#initialize
  0.04      0.001     0.001     0.000     0.000     1165   Hash#initialize
  0.04      0.001     0.001     0.000     0.000     4524   Kernel#nil?
  0.04      0.001     0.001     0.000     0.000     1165   Kernel#proc
  0.04      0.001     0.001     0.000     0.000     4454   Exception#exception
  0.04      0.001     0.001     0.000     0.000      750   Module#ancestors
  0.04      0.001     0.001     0.000     0.000     4728   Hash#[]
  0.04      0.001     0.001     0.000     0.000     1496   Array#index
  0.03      0.001     0.001     0.000     0.000     4558   Module#===
  0.03      0.001     0.001     0.000     0.000      343   Array#flatten
  0.03      0.013     0.001     0.000     0.012      343   #<refinement:Module@SystemNavigation::ModuleRefinement>#own_selectors
  0.03      0.038     0.001     0.000     0.037      375   <Class::SystemNavigation::AncestorMethodFinder>#find_all_ancestors
  0.03      3.093     0.001     0.000     3.092      754   Enumerable#inject
  0.03      3.101     0.001     0.000     3.100      754   SystemNavigation::MethodQuery#instance_and_singleton_do
  0.03      0.025     0.001     0.000     0.024      750   SystemNavigation::AncestorMethodFinder#find_all_methods
  0.03      0.003     0.001     0.000     0.003     1301  *Hash#merge!
  0.03      0.001     0.001     0.000     0.000      754   SystemNavigation::MethodQuery#initialize
  0.03      0.001     0.001     0.000     0.000     1496   Array#last
  0.02      0.002     0.001     0.000     0.001      750   Kernel#dup
  0.02      0.038     0.001     0.000     0.037      343   #<refinement:Module@SystemNavigation::ModuleRefinement>#own_methods
  0.02      0.030     0.001     0.000     0.029      411   SystemNavigation::MethodQuery#convert_to_methods
  0.02      0.001     0.001     0.000     0.000     3429   UnboundMethod#hash
  0.02      0.001     0.001     0.000     0.000      113   Array#inspect
  0.02      0.001     0.001     0.000     0.000      750   Array#initialize_copy
  0.02      0.001     0.001     0.000     0.001      750   Kernel#initialize_dup
  0.02      0.001     0.001     0.000     0.000       41   SystemNavigation::InstructionStream::Instruction#putobjects?
  0.02      0.039     0.001     0.000     0.038      375   #<refinement:Module@SystemNavigation::ModuleRefinement>#ancestor_methods
  0.02      0.001     0.001     0.000     0.000      751   Class#superclass
  0.02      0.014     0.000     0.000     0.014      411   <Class::SystemNavigation::MethodHash>#create
  0.01      3.161     0.000     0.000     3.161      686  *Enumerator::Yielder#<<
  0.01      3.074     0.000     0.000     3.073      343   SystemNavigation::MethodQuery#find_accessing_methods
  0.01      0.003     0.000     0.000     0.002      343   SystemNavigation::MethodHash#as_array
  0.01      0.000     0.000     0.000     0.000      750   Array#first
  0.01      0.000     0.000     0.000     0.000      342   Array#unshift
  0.01      0.000     0.000     0.000     0.000      750   Kernel#is_a?
  0.01      3.161     0.000     0.000     3.161      852  *Array#each
  0.01      0.000     0.000     0.000     0.000       30   Regexp#match
  0.01      0.000     0.000     0.000     0.000      343   Hash#values
  0.01      0.000     0.000     0.000     0.000      131   Regexp#inspect
  0.01      0.000     0.000     0.000     0.000      186   FalseClass#inspect
  0.00      0.000     0.000     0.000     0.000       20   Module#inspect
  0.00      0.000     0.000     0.000     0.000      236   UnboundMethod#eql?
  0.00      0.000     0.000     0.000     0.000       10   SystemNavigation::InstructionStream::Instruction#putstrings?
  0.00      0.000     0.000     0.000     0.000       69   TrueClass#inspect
  0.00      0.000     0.000     0.000     0.000       30   String#match
  0.00      3.164     0.000     0.000     3.164        1   Global#[No method]
  0.00      0.000     0.000     0.000     0.000        6   Range#inspect
  0.00      0.000     0.000     0.000     0.000        4   Float#inspect
  0.00      3.164     0.000     0.000     3.164        2  *Enumerator::Generator#each
  0.00      3.164     0.000     0.000     3.164        1   SystemNavigation#all_accesses
  0.00      0.000     0.000     0.000     0.000        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#with_all_superclasses
  0.00      0.002     0.000     0.000     0.002        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#all_subclasses
  0.00      0.000     0.000     0.000     0.000        2   Enumerator#initialize
  0.00      0.000     0.000     0.000     0.000        1   Array#push
  0.00      0.000     0.000     0.000     0.000        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#with_all_subclasses
  0.00      3.164     0.000     0.000     3.164        2  *Enumerator#each
  0.00      3.164     0.000     0.000     3.164      751  *Enumerable#flat_map
  0.00      0.000     0.000     0.000     0.000        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#with_all_sub_and_superclasses

* indicates recursively called methods
=end
