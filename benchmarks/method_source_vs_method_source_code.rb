# coding: utf-8
require 'benchmark'
require 'ripper'

=begin
Sample methods: 9622
Rehearsal -------------------------------------------------
method_source  31.620000   0.190000  31.810000 ( 31.785361)
--------------------------------------- total: 31.810000sec

                    user     system      total        real
method_source  30.770000   0.120000  30.890000 ( 30.859638)
ruby benchmarks/method_source_vs_method_source_code.rb  90.67s user 0.57s system 99% cpu 1:31.86 total
=end

# Require more classes for more methods.
require 'abbrev'
require 'base64'
require 'bigdecimal'
require 'cgi'
require 'cmath'
require 'coverage'
require 'csv'
require 'delegate'
require 'digest'
require 'drb'
require 'e2mmap'
require 'erb'
require 'forwardable'
require 'logger'
require 'irb'
require 'net/http'
require 'prettyprint'
require 'observer'
require 'ostruct'
require 'rake'
require 'rdoc'
require 'profiler'
require 'rss'
require 'tempfile'
require 'weakref'
require 'yaml'
require 'xmlrpc'
require 'ripper'

require_relative '../lib/system_navigation'

puts "Counting the number of sample methods..."

method_list = SystemNavigation.default.all_methods.select(&:source_location).sort_by(&:hash).
              select do |method|
  begin
    method.source
  rescue
    next
  end
end

puts "Sample methods: #{method_list.count}"

Benchmark.bmbm do |bm|
  bm.report('method_source') do
    method_list.map do |method|
      method.source
    end
  end

  bm.report('method_source_code') do
    method_list.map do |method|
      SystemNavigation::CompiledMethod2.new(method).source
    end
  end
end
