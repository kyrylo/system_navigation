require 'benchmark'

require_relative '../lib/system_navigation'

=begin
Rehearsal ---------------------------------------------------
#all_rb_methods   0.150000   0.020000   0.170000 (  0.169238)
------------------------------------------ total: 0.170000sec

                      user     system      total        real
#all_rb_methods   0.120000   0.050000   0.170000 (  0.167551)
=end

sn = SystemNavigation.default

Benchmark.bmbm do |bm|
  bm.report('#all_rb_methods') do
    sn.all_rb_methods
  end
end
