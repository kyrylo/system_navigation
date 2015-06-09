require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ------------------------------------------------------
#all_accesses - 1    1.120000   0.070000   1.190000 (  1.195386)
#all_accesses - 5    5.800000   0.350000   6.150000 (  6.152076)
#all_accesses - 10  12.630000   0.750000  13.380000 ( 13.378833)
#all_accesses - 20  24.670000   1.530000  26.200000 ( 26.199472)
-------------------------------------------- total: 46.920000sec

                         user     system      total        real
#all_accesses - 1    1.200000   0.090000   1.290000 (  1.302716)
#all_accesses - 5    6.130000   0.330000   6.460000 (  6.453621)
#all_accesses - 10  12.000000   0.680000  12.680000 ( 12.671966)
#all_accesses - 20  26.070000   1.490000  27.560000 ( 41.693160)
                                                      ^ leaking memory here
                                                   (fast_method_source's fault)
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
