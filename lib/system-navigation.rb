require 'English'
require 'forwardable'

require_relative 'system_navigation/array_utils'
require_relative 'system_navigation/unbound_method_utils'
require_relative 'system_navigation/module_utils'
require_relative 'system_navigation/ruby_environment'
require_relative 'system_navigation/instruction_stream'
require_relative 'system_navigation/instruction_stream/decoder'
require_relative 'system_navigation/instruction_stream/instruction'
require_relative 'system_navigation/instruction_stream/instruction/attr_instruction'

class SystemNavigation
  # The VERSION file must be in the root directory of the library.
  VERSION_FILE = File.expand_path('../../VERSION', __FILE__)

  VERSION = File.exist?(VERSION_FILE) ?
              File.read(VERSION_FILE).chomp : '(could not find VERSION file)'

  using ModuleUtils

  extend Forwardable
  def_delegator :@environment, :all_behaviors

  def self.default
    self.new
  end

  def initialize
    @environment = SystemNavigation::RubyEnvironment.new
  end

  def all_accesses(to:, from:)
    from.with_all_sub_and_superclasses.flat_map do |klass|
      klass.which_selectors_access(to).map do |sel|
        klass.instance_method(sel)
      end
    end
  end

  def all_calls(on:, from: nil)
    if from
      from.with_all_subclasses_do.flat_map do |klass|
        selectors = klass.which_selectors_refer_to(on)
        selectors.map { |sel| klass.instance_method(sel) }
      end
    else
      all_references_to(on)
    end
  end

  private

  def all_references_to(literal)
    self.all_behaviors.flat_map do |klass|
      selectors = klass.which_selectors_refer_to(literal)
      selectors.map { |sel| klass.instance_method(sel) }
    end
  end
end
