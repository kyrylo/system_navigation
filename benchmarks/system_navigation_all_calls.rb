require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ---------------------------------------------------
#all_calls - 1    1.280000   0.100000   1.380000 (  1.377159)
#all_calls - 5    6.860000   0.460000   7.320000 (  7.323792)
#all_calls - 10  13.360000   0.920000  14.280000 ( 14.383873)
#all_calls - 20  26.660000   1.700000  28.360000 ( 28.690713)
----------------------------------------- total: 51.340000sec

                      user     system      total        real
#all_calls - 1    1.300000   0.090000   1.390000 (  1.403531)
#all_calls - 5    6.450000   0.390000   6.840000 (  6.930075)
#all_calls - 10  12.840000   0.880000  13.720000 ( 13.794026)
#all_calls - 20  26.840000   1.890000  28.730000 ( 33.407244)
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
