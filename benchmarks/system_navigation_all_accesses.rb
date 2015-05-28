require 'benchmark'

require_relative '../lib/system-navigation'

=begin
Rehearsal ------------------------------------------------------
#all_accesses - 1    0.510000   0.000000   0.510000 (  0.504832)
#all_accesses - 5    1.530000   0.000000   1.530000 (  1.541016)
#all_accesses - 10   2.560000   0.000000   2.560000 (  2.565996)
#all_accesses - 20   2.370000   0.000000   2.370000 (  2.396435)
--------------------------------------------- total: 6.970000sec

                         user     system      total        real
#all_accesses - 1    0.490000   0.000000   0.490000 (  0.491207)
#all_accesses - 5    1.410000   0.000000   1.410000 (  1.423758)
#all_accesses - 10   2.350000   0.000000   2.350000 (  2.368681)
#all_accesses - 20   2.360000   0.000000   2.360000 (  2.359312)
ruby benchmarks/system_navigation_all_accesses.rb  13.64s user 0.01s system 99% cpu 13.739 total
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
    3.times do
      sn.all_accesses(to: :@foo)
    end
  end

  bm.report('#all_accesses - 10') do
    5.times do
      sn.all_accesses(to: :@foo)
    end
  end

  bm.report('#all_accesses - 20') do
    5.times do
      sn.all_accesses(to: :@foo)
    end
  end
end
