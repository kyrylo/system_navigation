require 'rake/testtask'

desc 'Run all benchmarks'
task :bm do
  system 'ruby benchmarks/**.rb'
end

task :gem do
  system 'gem build system_navigation*.gemspec'
end

task :uninstall do
  system 'gem uninstall system_navigation'
end

task :install do
  system 'gem install system_navigation*.gem'
end

task :test do
  Rake::TestTask.new do |t|
    t.test_files = Dir.glob('test/**/test_*.rb')
    t.warning = true
  end
end

task default: :test
