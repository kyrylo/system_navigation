require 'benchmark'

require_relative '../lib/system-navigation'

=begin
Rehearsal ---------------------------------------------------
#all_calls - 1    0.440000   0.000000   0.440000 (  0.442937)
#all_calls - 5    1.160000   0.000000   1.160000 (  1.155018)
#all_calls - 10   1.840000   0.000000   1.840000 (  1.858812)
#all_calls - 20   1.840000   0.000000   1.840000 (  1.861349)
------------------------------------------ total: 5.280000sec

                      user     system      total        real
#all_calls - 1    0.420000   0.000000   0.420000 (  0.424548)
#all_calls - 5    1.100000   0.000000   1.100000 (  1.097924)
#all_calls - 10   1.840000   0.000000   1.840000 (  1.834041)
#all_calls - 20   1.860000   0.000000   1.860000 (  1.854899)
ruby benchmarks/system_navigation_all_calls.rb  10.55s user 0.01s system 99% cpu 10.608 total
=end

sn = SystemNavigation.default

class A
  def initialize
    @foo = 1
  end
end

class B
  attr_reader :foo
end

class A
  def foo
    :hello
  end
end

class B
  def bar
    :hello
  end
end



Benchmark.bmbm do |bm|
  bm.report('#all_calls - 1') do
    1.times do
      sn.all_calls(on: :hello)
    end
  end

  bm.report('#all_calls - 5') do
    3.times do
      sn.all_calls(on: :hello)
    end
  end

  bm.report('#all_calls - 10') do
    5.times do
      sn.all_calls(on: :hello)
    end
  end

  bm.report('#all_calls - 20') do
    5.times do
      sn.all_calls(on: :hello)
    end
  end
end
