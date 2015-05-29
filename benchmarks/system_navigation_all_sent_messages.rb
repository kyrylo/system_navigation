require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ------------------------------------------------------
#all_sent_messages   2.390000   0.010000   2.400000 (  2.396560)
--------------------------------------------- total: 2.400000sec

                         user     system      total        real
#all_sent_messages   2.480000   0.000000   2.480000 (  2.487175)
=end

sn = SystemNavigation.default

Benchmark.bmbm do |bm|
  bm.report('#all_sent_messages') do
    sn.all_sent_messages
  end
end
