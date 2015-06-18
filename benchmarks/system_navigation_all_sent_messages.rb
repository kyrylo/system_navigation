require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ------------------------------------------------------
#all_sent_messages   0.490000   0.020000   0.510000 (  0.512115)
--------------------------------------------- total: 0.510000sec

                         user     system      total        real
#all_sent_messages   0.490000   0.020000   0.510000 (  0.508792)
=end

sn = SystemNavigation.default

Benchmark.bmbm do |bm|
  bm.report('#all_sent_messages') do
    sn.all_sent_messages
  end
end
