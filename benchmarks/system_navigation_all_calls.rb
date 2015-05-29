require 'benchmark'

require_relative '../lib/system-navigation'

=begin
Rehearsal ---------------------------------------------------
#all_calls - 1    2.490000   0.010000   2.500000 (  2.498720)
#all_calls - 5   12.900000   0.010000  12.910000 ( 12.892300)
#all_calls - 10  27.330000   0.020000  27.350000 ( 27.342593)
#all_calls - 20  52.830000   0.030000  52.860000 ( 52.834644)
----------------------------------------- total: 95.620000sec

                      user     system      total        real
#all_calls - 1    2.630000   0.010000   2.640000 (  2.634253)
#all_calls - 5   13.780000   0.010000  13.790000 ( 13.807633)
#all_calls - 10  26.330000   0.010000  26.340000 ( 26.341292)
#all_calls - 20  51.340000   0.050000  51.390000 ( 51.348082)
ruby benchmarks/system_navigation_all_calls.rb  189.75s user 0.18s system 100% cpu 3:09.86 total
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
