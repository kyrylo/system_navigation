require 'rake/testtask'
require 'rake/extensiontask'
require 'rake/clean'

dlext = RbConfig::CONFIG['DLEXT']

CLEAN.include("ext/**/*.#{dlext}", "ext/**/*.log", "ext/**/*.o",
              "ext/**/*~", "ext/**/*#*", "ext/**/*.obj", "**/*#*", "**/*#*.*",
              "ext/**/*.def", "ext/**/*.pdb", "**/*_flymake*.*", "**/*_flymake", "**/*.rbc")

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

task :cleanup do
  system 'rm -rf tmp'
  system 'rm -rf lib/system_navigation/method_source_code.so'
end

task :uninstall do
  system 'gem uninstall system_navigation'
end

task :req => [:uninstall, :cleanup, :compile, :gem, :install] do
  system 'pry -rsystem_navigation'
end

task :install do
  system 'gem install system_navigation*.gem'
end
