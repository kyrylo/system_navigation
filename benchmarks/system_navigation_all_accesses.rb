require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ------------------------------------------------------
#all_accesses - 1    2.390000   0.000000   2.390000 (  2.388984)
#all_accesses - 5   12.040000   0.020000  12.060000 ( 12.053250)
#all_accesses - 10  23.750000   0.020000  23.770000 ( 23.762558)
#all_accesses - 20  46.930000   0.050000  46.980000 ( 46.935476)
-------------------------------------------- total: 85.200000sec

                         user     system      total        real
#all_accesses - 1    2.420000   0.000000   2.420000 (  2.418456)
#all_accesses - 5   11.690000   0.000000  11.690000 ( 11.682687)
#all_accesses - 10  23.280000   0.040000  23.320000 ( 23.306703)
#all_accesses - 20  45.950000   0.040000  45.990000 ( 45.955641)
ruby benchmarks/system_navigation_all_accesses.rb  168.60s user 0.20s system 100% cpu 2:48.70 total
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

Benchmark.bmbm do |bm|
  bm.report('#all_accesses - 1') do
    1.times do
      sn.all_accesses(to: :@foo)
    end
  end

  bm.report('#all_accesses - 5') do
    5.times do
      sn.all_accesses(to: :@foo)
    end
  end

  bm.report('#all_accesses - 10') do
    10.times do
      sn.all_accesses(to: :@foo)
    end
  end

  bm.report('#all_accesses - 20') do
    20.times do
      sn.all_accesses(to: :@foo)
    end
  end
end
