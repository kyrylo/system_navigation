require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ---------------------------------------------------
#all_calls - 1    0.680000   0.030000   0.710000 (  0.719033)
#all_calls - 5    3.430000   0.190000   3.620000 (  3.612461)
#all_calls - 10   7.400000   0.330000   7.730000 (  7.718199)
#all_calls - 20  15.310000   0.640000  15.950000 ( 15.945378)
----------------------------------------- total: 28.010000sec

                      user     system      total        real
#all_calls - 1    0.670000   0.050000   0.720000 (  0.711674)
#all_calls - 5    4.360000   0.250000   4.610000 (  4.650486)
#all_calls - 10   7.250000   0.370000   7.620000 (  7.620964)
#all_calls - 20  14.900000   0.600000  15.500000 ( 15.489046)
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
    5.times do
      sn.all_calls(on: :hello)
    end
  end

  bm.report('#all_calls - 10') do
    10.times do
      sn.all_calls(on: :hello)
    end
  end

  bm.report('#all_calls - 20') do
    20.times do
      sn.all_calls(on: :hello)
    end
  end
end
