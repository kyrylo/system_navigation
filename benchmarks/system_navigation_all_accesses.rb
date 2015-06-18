require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ------------------------------------------------------
#all_accesses - 1    0.690000   0.020000   0.710000 (  0.714255)
#all_accesses - 5    3.390000   0.150000   3.540000 (  3.537601)
#all_accesses - 10   7.340000   0.290000   7.630000 (  7.627960)
#all_accesses - 20  14.210000   0.560000  14.770000 ( 14.758581)
-------------------------------------------- total: 26.650000sec

                         user     system      total        real
#all_accesses - 1    0.750000   0.010000   0.760000 (  0.766126)
#all_accesses - 5    3.390000   0.120000   3.510000 (  3.500050)
#all_accesses - 10   6.740000   0.260000   7.000000 (  6.991065)
#all_accesses - 20  13.830000   0.420000  14.250000 ( 14.239442)
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
