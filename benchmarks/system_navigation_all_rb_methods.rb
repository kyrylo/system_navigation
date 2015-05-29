require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ---------------------------------------------------
#all_rb_methods   1.920000   0.010000   1.930000 (  1.930600)
------------------------------------------ total: 1.930000sec

                      user     system      total        real
#all_rb_methods   1.890000   0.000000   1.890000 (  1.895824)
=end

sn = SystemNavigation.default

Benchmark.bmbm do |bm|
  bm.report('#all_rb_methods') do
    sn.all_rb_methods
  end
end
