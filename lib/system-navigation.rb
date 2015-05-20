require 'English'
require 'set'

require_relative 'system_navigation/instruction_stream'
require_relative 'system_navigation/instruction_stream/decoder'
require_relative 'system_navigation/instruction_stream/instruction'
require_relative 'system_navigation/instruction_stream/instruction/attr_instruction'
require_relative 'system_navigation/navigation_capabilities'
require_relative 'system_navigation/ruby_environment'

class SystemNavigation
  # The VERSION file must be in the root directory of the library.
  VERSION_FILE = File.expand_path('../../VERSION', __FILE__)

  VERSION = File.exist?(VERSION_FILE) ?
              File.read(VERSION_FILE).chomp : '(could not find VERSION file)'

  using NavigationCapabilities

  def self.default
    self.new
  end

  def initialize
    @environment = SystemNavigation::RubyEnvironment.new
  end

  def all_accesses(to:, from:)
    accesses = []

    from.with_all_sub_and_superclasses do |klass|
      klass.which_selectors_access(to).each do |sel|
        accesses.push(klass.instance_method(sel))
      end
    end

    accesses
  end

  def all_calls_on(sym)
    all_references_to(sym)
  end

  def all_references_to(literal)
    result = []

    self.all_behaviors do |klass|
      selectors = klass.which_selectors_refer_to(literal)
      selectors.each { |sel| result << klass.instance_method(sel) }
    end

    result
  end

  def all_behaviors(&block)
    @environment.all_behaviors(&block)
  end
end
