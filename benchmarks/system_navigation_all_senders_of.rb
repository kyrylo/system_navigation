require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ----------------------------------------------------------
#all_senders_of(:puts)   0.510000   0.010000   0.520000 (  0.514385)
------------------------------------------------- total: 0.520000sec

                             user     system      total        real
#all_senders_of(:puts)   0.480000   0.010000   0.490000 (  0.498999)
=end

sn = SystemNavigation.default

Benchmark.bmbm do |bm|
  bm.report('#all_senders_of(:puts)') do
    sn.all_senders_of(:puts)
  end
end
