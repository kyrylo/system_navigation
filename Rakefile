require 'rake/testtask'
require 'rake/extensiontask'

Rake::ExtensionTask.new do |ext|
  ext.name    = 'method_source_code'
  ext.ext_dir = 'ext/system_navigation/method_source_code'
  ext.lib_dir = 'lib/system_navigation'
end

Rake::TestTask.new do |t|
  t.test_files = Dir.glob('test/**/test_*.rb')
end

task default: :test

desc 'Run all benchmarks'
task :bm do
  system 'ruby benchmarks/**.rb'
end

task :gem do
  system 'gem build system_navigation*.gemspec'
end

task :clean do
  system 'rm -rf tmp && rm -rf pkg'
end

task :req => [:clean, :compile, :gem, :install] do
  system 'pry -rsystem_navigation'
end

task :install do
  system 'gem install system_navigation*.gem'
end
