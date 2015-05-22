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
  def_delegators :@environment,
                 :all_behaviors, :all_classes, :all_classes_and_modules,
                 :all_modules, :all_objects

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
      self.all_references_to(on)
    end
  end

  def all_classes_implementing(selector)
    self.all_classes.select do |klass|
      klass.includes_selector?(selector)
    end
  end

  def all_modules_implementing(selector)
    self.all_modules.select do |mod|
      mod.includes_selector?(selector)
    end
  end

  def all_implementors_of(selector)
    self.all_behaviors.select do |klass|
      klass.includes_selector?(selector)
    end
  end

  def all_classes_and_modules_in_gem_named(gem_name)
    self.all_classes_and_modules.select do |klass|
      klass.belongs_to?(gem_name)
    end
  end

  def all_local_calls(on:, of_class:)
    references = []

    select_methods = proc { |klass|
      selectors = klass.which_global_selectors_refer_to(on)
      selectors.map { |sel| klass.instance_method(sel) }
    }

    references << of_class.with_all_sub_and_superclasses.
                 flat_map(&select_methods)
    references << of_class.singleton_class.with_all_sub_and_superclasses.
                 flat_map(&select_methods)
    references.flatten
  end

  def all_methods
    self.all_behaviors.flat_map { |klass| klass.all_methods }
  end

  def all_methods_with_source(string:, match_case: true)
    self.all_behaviors.flat_map do |klass|
      klass.select_matching_methods(string, match_case)
    end
  end

  def all_c_methods
    self.all_behaviors.flat_map { |klass| klass.c_methods }
  end

  def all_rb_methods
    self.all_behaviors.flat_map { |klass| klass.rb_methods }
  end

  def all_senders(of:)
    self.all_behaviors.flat_map do |klass|
      klass.which_selectors_send(of)
    end
  end

  def all_sent_messages
    self.all_behaviors.flat_map do |klass|
      klass.all_messages
    end.uniq
  end

  protected

  def all_references_to(literal)
    self.all_behaviors.flat_map do |klass|
      selectors = klass.which_selectors_refer_to(literal)
      selectors.map { |sel| klass.instance_method(sel) }
    end
  end
end
