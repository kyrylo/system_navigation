Gem::Specification.new do |s|
  s.name         = 'system_navigation'
  s.version      = File.read('VERSION')
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = 'A library that provides additional introspection capabilities for Ruby programs'
  s.description  = 'A library that provides additional introspection capabilities for Ruby programs (allows various queries on methods and classes)'
  s.author       = 'Kyrylo Silin'
  s.email        = 'silin@kyrylo.org'
  s.homepage     = 'https://github.com/kyrylo/system_navigation'
  s.licenses     = 'Zlib'

  s.require_path = 'lib'
  s.files        = %w[
    lib/system_navigation.rb
    lib/system_navigation/ancestor_method_finder.rb
    lib/system_navigation/array_refinement.rb
    lib/system_navigation/compiled_method.rb
    lib/system_navigation/expression_tree.rb
    lib/system_navigation/instruction_stream.rb
    lib/system_navigation/instruction_stream/decoder.rb
    lib/system_navigation/instruction_stream/instruction.rb
    lib/system_navigation/instruction_stream/instruction/attr_instruction.rb
    lib/system_navigation/method_hash.rb
    lib/system_navigation/method_query.rb
    lib/system_navigation/module_refinement.rb
    lib/system_navigation/ruby_environment.rb
    VERSION
    README.md
    CHANGELOG.md
    LICENCE.txt
  ]
  s.platform = Gem::Platform::RUBY

  s.add_runtime_dependency 'fast_method_source', '~> 0'

  s.add_development_dependency 'bundler', '~> 1.9'
  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'pry', '~> 0.10'
end
