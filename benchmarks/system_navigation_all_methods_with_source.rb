require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal -----------------------------------------------------------------
#all_methods_with_source - 1    0.170000   0.030000   0.200000 (  0.203697)
#all_methods_with_source - 5    0.790000   0.130000   0.920000 (  0.928560)
#all_methods_with_source - 10   1.720000   0.250000   1.970000 (  1.964597)
#all_methods_with_source - 20   3.290000   0.440000   3.730000 (  3.739400)
-------------------------------------------------------- total: 6.820000sec

                                    user     system      total        real
#all_methods_with_source - 1    0.160000   0.020000   0.180000 (  0.187143)
#all_methods_with_source - 5    0.780000   0.140000   0.920000 (  0.926441)
#all_methods_with_source - 10   1.650000   0.230000   1.880000 (  1.870201)
#all_methods_with_source - 20   3.200000   0.500000   3.700000 (  3.708661)
=end

sn = SystemNavigation.default

Benchmark.bmbm do |bm|
  bm.report('#all_methods_with_source - 1') do
    1.times do
      sn.all_methods_with_source(string: 'puts')
    end
  end

  bm.report('#all_methods_with_source - 5') do
    5.times do
      sn.all_methods_with_source(string: 'puts')
    end
  end

  bm.report('#all_methods_with_source - 10') do
    10.times do
      sn.all_methods_with_source(string: 'puts')
    end
  end

  bm.report('#all_methods_with_source - 20') do
    20.times do
      sn.all_methods_with_source(string: 'puts')
    end
  end
end
