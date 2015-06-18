require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal --------------------------------------------------
#all_c_methods   0.160000   0.020000   0.180000 (  0.169852)
----------------------------------------- total: 0.180000sec

                     user     system      total        real
#all_c_methods   0.140000   0.020000   0.160000 (  0.158081)
=end

sn = SystemNavigation.default

Benchmark.bmbm do |bm|
  bm.report('#all_c_methods') do
    sn.all_c_methods
  end
end
