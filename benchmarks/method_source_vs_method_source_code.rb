# coding: utf-8
require 'benchmark'
require 'ripper'

=begin

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

require_relative '../lib/system_navigation'

method_list = SystemNavigation.default.all_methods.select(&:source_location).
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
    method_list.map(&:source)
  end
end
