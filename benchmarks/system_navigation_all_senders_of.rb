require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ----------------------------------------------------------
#all_senders_of(:puts)   2.340000   0.010000   2.350000 (  2.352055)
------------------------------------------------- total: 2.350000sec

                             user     system      total        real
#all_senders_of(:puts)   2.310000   0.000000   2.310000 (  2.311983)
=end

sn = SystemNavigation.default

Benchmark.bmbm do |bm|
  bm.report('#all_senders_of(:puts)') do
    sn.all_senders_of(:puts)
  end
end
