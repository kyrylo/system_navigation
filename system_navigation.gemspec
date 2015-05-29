Gem::Specification.new do |s|
  s.name         = 'system_navigation'
  s.version      = File.read('VERSION')
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = ''
  s.description  = ''
  s.author       = 'Kyrylo Silin'
  s.email        = 'silin@kyrylo.org'
  s.homepage     = 'https://github.com/kyrylo/system_navigation'
  s.licenses     = 'MIT'

  s.require_path = 'lib'
  s.files        = `git ls-files`.split("\n")

  s.add_runtime_dependency 'method_source', '~> 0.8'

  s.add_development_dependency 'bundler', '~> 1.9'
  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'pry', '~> 0.10'
end
