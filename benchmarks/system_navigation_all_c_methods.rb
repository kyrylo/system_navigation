require 'benchmark'

require_relative '../lib/system-navigation'

=begin
Rehearsal --------------------------------------------------
#all_c_methods   2.000000   0.000000   2.000000 (  2.003585)
----------------------------------------- total: 2.000000sec

                     user     system      total        real
#all_c_methods   2.140000   0.000000   2.140000 (  2.142253)
=end

sn = SystemNavigation.default

Benchmark.bmbm do |bm|
  bm.report('#all_c_methods') do
    sn.all_c_methods
  end
end
