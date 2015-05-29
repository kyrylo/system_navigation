require 'rubyprof'

require_relative '../lib/system-navigation'

sn = SystemNavigation.default

result = RubyProf.profile do
  sn.all_accesses(to: :@foo)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, {})

=begin
Measure Mode: wall_time
Thread ID: 70355946928480
Fiber ID: 70355966473780
Total: 19.760497
Sort by: self_time

 %self      total      self      wait     child     calls  name
 17.06      5.157     3.372     0.000     1.785    29663   Kernel#eval
  8.55      1.690     1.690     0.000     0.000    81066   Exception#backtrace
  4.39      0.868     0.868     0.000     0.000  1013976   StringScanner#scan
  4.06      1.425     0.802     0.000     0.623   295020   SystemNavigation::InstructionStream::Instruction#initialize
  3.96      0.782     0.782     0.000     0.000  1234012   StringScanner#skip
  3.70     10.689     0.730     0.000     9.959   673494  *Class#new
  3.45      6.500     0.683     0.000     5.817   295020   SystemNavigation::InstructionStream::Instruction#parse
  2.76      1.463     0.545     0.000     0.918   240592   SystemNavigation::InstructionStream::Instruction#parse_operand
  2.50      0.494     0.494     0.000     0.000   754306   StringScanner#peek
  2.35      0.464     0.464     0.000     0.000   281125   String#=~
  2.20      0.435     0.435     0.000     0.000   549016   String#lstrip
  2.12      1.375     0.419     0.000     0.956   295020   SystemNavigation::InstructionStream::Instruction#parse_service_instruction
  1.74      1.133     0.344     0.000     0.789    37060   Array#select
  1.65      0.859     0.325     0.000     0.533   240592   SystemNavigation::InstructionStream::Instruction#parse_position
  1.64      0.363     0.324     0.000     0.039     7260   <Class::RubyVM::InstructionSequence>#disasm
  1.41      8.790     0.279     0.000     8.511   295020   <Class::SystemNavigation::InstructionStream::Instruction>#parse
  1.31      0.259     0.259     0.000     0.000   470988   String#replace
  1.30      0.559     0.257     0.000     0.301   240592   SystemNavigation::InstructionStream::Instruction#parse_lineno
  1.22      0.242     0.242     0.000     0.000   810608   StringScanner#check
  1.16      0.614     0.229     0.000     0.385   240592   SystemNavigation::InstructionStream::Instruction#parse_opcode
  1.04      0.206     0.206     0.000     0.000   240592   SystemNavigation::InstructionStream::Instruction#sending?
  1.03      0.203     0.203     0.000     0.000   331956   StringScanner#initialize
  1.01      0.569     0.200     0.000     0.369   240592   SystemNavigation::InstructionStream::Instruction#parse_op_id
  0.93      0.184     0.184     0.000     0.000   303408   String#to_i
  0.89      0.176     0.176     0.000     0.000   240592   SystemNavigation::InstructionStream::Instruction#accessing_ivar?
  0.84      0.379     0.165     0.000     0.214   240592   SystemNavigation::InstructionStream::Instruction#parse_ivar
  0.70      0.603     0.139     0.000     0.464   281125   Kernel#!~
  0.70      0.138     0.138     0.000     0.000    14520   String#split
  0.57      0.113     0.113     0.000     0.000   240592   SystemNavigation::InstructionStream::Instruction#evals?
  0.46      0.091     0.091     0.000     0.000    50438   Exception#exception
  0.41      0.080     0.080     0.000     0.000    25800   Regexp#===
  0.40      5.237     0.080     0.000     5.157    29663   Kernel#catch
  0.36      0.072     0.072     0.000     0.000   240592   SystemNavigation::InstructionStream::Instruction#vm_operative?
  0.36      5.507     0.072     0.000     5.435    29663   MethodSource::CodeHelpers#complete_expression?
  0.30      0.060     0.060     0.000     0.000   120296   SystemNavigation::InstructionStream::Instruction#reads_ivar?
  0.29      0.058     0.058     0.000     0.000   120296   SystemNavigation::InstructionStream::Instruction#dynamically_reads_ivar?
  0.28      0.056     0.056     0.000     0.000   120296   SystemNavigation::InstructionStream::Instruction#writes_ivar?
  0.28      0.056     0.056     0.000     0.000   120296   SystemNavigation::InstructionStream::Instruction#dynamically_writes_ivar?
  0.26      0.178     0.051     0.000     0.127    25152   <Module::MethodSource::CodeHelpers::IncompleteExpression>#===
  0.21      0.056     0.042     0.000     0.014        1   <Module::ObjectSpace>#each_object
  0.20      9.453     0.040     0.000     9.413    14520   SystemNavigation::InstructionStream#iseqs
  0.18     19.474     0.035     0.000    19.439   257908  *Proc#call
  0.17      8.425     0.033     0.000     8.392     7260   SystemNavigation::CompiledMethod#initialize
  0.14      5.656     0.028     0.000     5.628     7260   <Module::MethodSource>#source_helper
  0.14     10.574     0.028     0.000    10.546    14520   SystemNavigation::CompiledMethod#scan_for
  0.11     10.495     0.022     0.000    10.473    14520   SystemNavigation::InstructionStream::Decoder#select_instructions
  0.11      0.040     0.022     0.000     0.018    25162   Exception#message
  0.11      0.021     0.021     0.000     0.000     8628   Array#compact
  0.10      2.608     0.021     0.000     2.588     7260   <Module::MethodSource>#comment_helper
  0.10      5.603     0.019     0.000     5.584     4522   MethodSource::CodeHelpers#expression_at
  0.09      1.004     0.019     0.000     0.985    14520   Enumerator#with_index
  0.09     19.493     0.019     0.000    19.474    17496  *Array#map
  0.09      0.018     0.018     0.000     0.000    25162   Exception#to_s
  0.09      0.018     0.018     0.000     0.000    16773   Fixnum#inspect
  0.09      0.018     0.018     0.000     0.000    14520   UnboundMethod#source_location
  0.09      0.022     0.018     0.000     0.003     9156   <Module::MethodSource>#lines_for
  0.09      0.017     0.017     0.000     0.000    36936   StringScanner#terminate
  0.09     19.522     0.017     0.000    19.505     8868   SystemNavigation::MethodQuery#evaluate
  0.09      5.321     0.017     0.000     5.304     7260   SystemNavigation::InstructionStream::Decoder#ivar_read_scan
  0.08      2.638     0.016     0.000     2.622     7260   MethodSource::MethodExtensions#comment
  0.08      0.048     0.016     0.000     0.032     7260   <Class::SystemNavigation::InstructionStream>#on
  0.08      0.015     0.015     0.000     0.000    25670   Symbol#to_s
  0.07      5.206     0.015     0.000     5.192     7260   SystemNavigation::InstructionStream::Decoder#ivar_write_scan
  0.07      0.015     0.015     0.000     0.000    29648   Array#any?
  0.07      5.685     0.014     0.000     5.670     7260   MethodSource::MethodExtensions#source
  0.07      0.014     0.014     0.000     0.000      607   Array#unshift
  0.07      0.045     0.013     0.000     0.032     2348   SystemNavigation::MethodHash#initialize
  0.06      0.013     0.013     0.000     0.000     9426   Module#instance_method
  0.06      0.375     0.012     0.000     0.363     7260   SystemNavigation::InstructionStream#decode
  0.06      0.012     0.012     0.000     0.000    13091   Array#concat
  0.06      0.012     0.012     0.000     0.000     9492   Symbol#inspect
  0.06      0.019     0.011     0.000     0.007    14520   SystemNavigation::InstructionStream#scan_for
  0.06      2.568     0.011     0.000     2.557     4522   MethodSource::CodeHelpers#comment_describing
  0.05      5.574     0.011     0.000     5.563     4721   MethodSource::CodeHelpers#extract_first_expression
  0.05      8.837     0.011     0.000     8.826     7260   <Class::SystemNavigation::CompiledMethod>#compile
  0.05      0.011     0.011     0.000     0.000    14672   String#rstrip
  0.05      0.386     0.011     0.000     0.375     7260   SystemNavigation::CompiledMethod#compile
  0.05     19.532     0.010     0.000    19.522     1478   Hash#each
  0.05      0.021     0.010     0.000     0.011     6500   SystemNavigation::InstructionStream::Instruction::AttrWriterInstruction#visit
  0.05      0.010     0.010     0.000     0.000    14151   Kernel#hash
  0.05      0.010     0.010     0.000     0.000    14520   UnboundMethod#name
  0.05      0.009     0.009     0.000     0.000     7260   SystemNavigation::InstructionStream#initialize
  0.05      0.009     0.009     0.000     0.000     4511   Kernel#throw
  0.05      5.355     0.009     0.000     5.346     7260   SystemNavigation::CompiledMethod#reads_field?
  0.05      0.009     0.009     0.000     0.000    33744   Module#===
  0.04      0.009     0.009     0.000     0.000     7130   String#tr
  0.04      0.019     0.009     0.000     0.010     1412   Array#-
  0.04      0.037     0.008     0.000     0.028     6500   SystemNavigation::InstructionStream::Instruction::AttrReaderInstruction#visit
  0.04      0.066     0.008     0.000     0.058    13000   SystemNavigation::InstructionStream::Instruction::AttrInstruction#accept
  0.04      0.008     0.008     0.000     0.000     9022   Array#[]
  0.04      0.024     0.008     0.000     0.016     7130   SystemNavigation::InstructionStream::Instruction::AttrInstruction#convert_accessor_to_name
  0.04      0.133     0.008     0.000     0.125     6500   <Class::SystemNavigation::InstructionStream::Instruction::AttrInstruction>#parse
  0.04      0.008     0.008     0.000     0.000    13014   String#[]
  0.04      0.008     0.008     0.000     0.000     7260   SystemNavigation::InstructionStream::Decoder#initialize
  0.04      0.007     0.007     0.000     0.000     5610   Exception#initialize
  0.04      0.007     0.007     0.000     0.000     1740   Module#public_instance_methods
  0.04      2.550     0.007     0.000     2.543     4511   MethodSource::CodeHelpers#extract_last_comment
  0.03      0.013     0.006     0.000     0.007     7394  *Hash#merge!
  0.03      0.023     0.006     0.000     0.016     1410   #<refinement:Array@SystemNavigation::ArrayRefinement>#split
  0.03      0.006     0.006     0.000     0.000     8020   Symbol#to_proc
  0.03      0.006     0.006     0.000     0.000     4857   String#inspect
  0.03      5.234     0.006     0.000     5.228     7260   SystemNavigation::CompiledMethod#writes_field?
  0.03      0.006     0.006     0.000     0.000     1478   SystemNavigation::MethodHash#empty_hash
  0.03      0.006     0.006     0.000     0.000     3871   Kernel#singleton_class
  0.03     19.570     0.005     0.000    19.565     1478   <Class::SystemNavigation::MethodQuery>#execute
  0.03      0.060     0.005     0.000     0.055     6500   <Class::SystemNavigation::InstructionStream::Instruction::AttrInstruction>#attrreaderinstr
  0.03      0.005     0.005     0.000     0.000    10454   Kernel#is_a?
  0.02      0.046     0.005     0.000     0.041     6500   <Class::SystemNavigation::InstructionStream::Instruction::AttrInstruction>#attrwriterinstr
  0.02      0.005     0.005     0.000     0.000     5884   String#to_sym
  0.02      0.004     0.004     0.000     0.000     2348   Hash#initialize
  0.02      0.007     0.004     0.000     0.002      788   Array#|
  0.02      0.004     0.004     0.000     0.000     1740   Module#private_instance_methods
  0.02      0.004     0.004     0.000     0.000     1744   Module#protected_instance_methods
  0.02      0.004     0.004     0.000     0.000     6500   SystemNavigation::InstructionStream::Instruction::AttrInstruction#initialize
  0.02      0.004     0.004     0.000     0.000    13000   UnboundMethod#original_name
  0.02     19.700     0.004     0.000    19.696      608   #<refinement:Module@SystemNavigation::ModuleRefinement>#select_methods_that_access
  0.02      0.004     0.004     0.000     0.000     4222   Array#shift
  0.02      0.011     0.004     0.000     0.007     5476   <Class::Exception>#exception
  0.02      0.014     0.004     0.000     0.011     5476   Kernel#raise
  0.02      0.029     0.004     0.000     0.025     1410   SystemNavigation::AncestorMethodFinder#find_closest_ancestors
  0.02      0.004     0.004     0.000     0.000     6500   SystemNavigation::InstructionStream::Instruction::AttrReaderInstruction#initialize
  0.02      0.003     0.003     0.000     0.000     7130   String#downcase
  0.02      0.003     0.003     0.000     0.000     6500   SystemNavigation::InstructionStream::Instruction::AttrWriterInstruction#initialize
  0.02      0.025     0.003     0.000     0.021     1410   SystemNavigation::AncestorMethodFinder#initialize
  0.02      0.003     0.003     0.000     0.000      630   String#gsub
  0.02      0.003     0.003     0.000     0.000     2348   Kernel#proc
  0.02     19.535     0.003     0.000    19.532     1478   Enumerable#inject
  0.01      0.003     0.003     0.000     0.000     2813   Array#index
  0.01      0.003     0.003     0.000     0.000     8868   Kernel#nil?
  0.01      0.003     0.003     0.000     0.000     9654   Hash#[]
  0.01      0.003     0.003     0.000     0.000     1410   Module#ancestors
  0.01     19.554     0.002     0.000    19.551     1478   SystemNavigation::MethodQuery#instance_and_singleton_do
  0.01      0.103     0.002     0.000     0.101      705   <Class::SystemNavigation::AncestorMethodFinder>#find_all_ancestors
  0.01      0.002     0.002     0.000     0.000      608   Array#flatten
  0.01      0.029     0.002     0.000     0.026      608   #<refinement:Module@SystemNavigation::ModuleRefinement>#own_selectors
  0.01      0.002     0.002     0.000     0.000     4721   Fixnum#zero?
  0.01      0.002     0.002     0.000     0.000     1478   SystemNavigation::MethodQuery#initialize
  0.01      0.071     0.002     0.000     0.069     1410   SystemNavigation::AncestorMethodFinder#find_all_methods
  0.01      0.003     0.002     0.000     0.001      112   <Class::IO>#readlines
  0.01      0.083     0.002     0.000     0.081      608   #<refinement:Module@SystemNavigation::ModuleRefinement>#own_methods
  0.01      0.005     0.002     0.000     0.003     1410   Kernel#dup
  0.01      0.002     0.002     0.000     0.000     2813   Array#last
  0.01      0.002     0.002     0.000     0.000     8672   UnboundMethod#hash
  0.01      0.071     0.002     0.000     0.069      870   SystemNavigation::MethodQuery#convert_to_methods
  0.01      0.003     0.002     0.000     0.001      154   SystemNavigation::InstructionStream::Instruction#putstrings?
  0.01      0.002     0.002     0.000     0.000     1410   Array#initialize_copy
  0.01      0.036     0.001     0.000     0.034      870   <Class::SystemNavigation::MethodHash>#create
  0.01     19.704     0.001     0.000    19.702     1216  *Enumerator::Yielder#<<
  0.01      0.003     0.001     0.000     0.002     1410   Kernel#initialize_dup
  0.01      0.105     0.001     0.000     0.103      705   #<refinement:Module@SystemNavigation::ModuleRefinement>#ancestor_methods
  0.01      0.001     0.001     0.000     0.000     1411   Class#superclass
  0.01      0.006     0.001     0.000     0.005      608   SystemNavigation::MethodHash#as_array
  0.01      0.002     0.001     0.000     0.001      127   SystemNavigation::InstructionStream::Instruction#putobjects?
  0.01     19.489     0.001     0.000    19.488      608   SystemNavigation::MethodQuery#find_accessing_methods
  0.01      0.001     0.001     0.000     0.000     1410   Array#first
  0.00      0.001     0.001     0.000     0.000      125   Regexp#match
  0.00      0.001     0.001     0.000     0.000      864   FalseClass#inspect
  0.00      0.001     0.001     0.000     0.000      474   Regexp#inspect
  0.00      0.001     0.001     0.000     0.000      112   SystemCallError#initialize
  0.00      0.001     0.001     0.000     0.000      482   TrueClass#inspect
  0.00     19.704     0.001     0.000    19.704    11003  *Array#each
  0.00      0.001     0.001     0.000     0.000      608   Hash#values
  0.00      0.001     0.000     0.000     0.000      129   Array#inspect
  0.00      0.000     0.000     0.000     0.000      132   Module#inspect
  0.00      0.001     0.000     0.000     0.001      125   String#match
  0.00      0.000     0.000     0.000     0.000       36   Range#inspect
  0.00      0.000     0.000     0.000     0.000      108   <Module::MethodSource::CodeHelpers::IncompleteExpression>#rbx?
  0.00      0.000     0.000     0.000     0.000      367   UnboundMethod#eql?
  0.00      0.000     0.000     0.000     0.000      214   <Class::SystemCallError>#===
  0.00      0.000     0.000     0.000     0.000       22   BasicObject#method_missing
  0.00      0.000     0.000     0.000     0.000       12   Float#inspect
  0.00      0.000     0.000     0.000     0.000       22   NoMethodError#initialize
  0.00      0.000     0.000     0.000     0.000       22   NameError#initialize
  0.00      0.000     0.000     0.000     0.000        2   <Class::#<Class:0x007ffa0a914bf8>>#public_instance_methods
  0.00     19.760     0.000     0.000    19.760        1   <Object::Object>#__pry__
  0.00     19.760     0.000     0.000    19.760        2  *Enumerator::Generator#each
  0.00      0.056     0.000     0.000     0.056        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#all_subclasses
  0.00      0.000     0.000     0.000     0.000        1   Array#push
  0.00      0.000     0.000     0.000     0.000       10   NilClass#to_s
  0.00      0.000     0.000     0.000     0.000        2   Enumerator#initialize
  0.00     19.760     0.000     0.000    19.760        1   SystemNavigation#all_accesses
  0.00      0.000     0.000     0.000     0.000        2   <Class::#<Class:0x007ffa0a914bf8>>#protected_instance_methods
  0.00      0.000     0.000     0.000     0.000        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#with_all_superclasses
  0.00     19.760     0.000     0.000    19.760        2  *Enumerator#each
  0.00     19.760     0.000     0.000    19.760     1411  *Enumerable#flat_map
  0.00      0.000     0.000     0.000     0.000        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#with_all_subclasses
  0.00      0.000     0.000     0.000     0.000        1   #<refinement:Module@SystemNavigation::ModuleRefinement>#with_all_sub_and_superclasses

* indicates recursively called methods
=end
