require 'method_source'

require 'forwardable'
require 'strscan'

require_relative 'system_navigation/array_refinement'
require_relative 'system_navigation/unbound_method_utils'
require_relative 'system_navigation/module_utils'
require_relative 'system_navigation/ruby_environment'
require_relative 'system_navigation/instruction_stream'
require_relative 'system_navigation/method_query'
require_relative 'system_navigation/compiled_method'
require_relative 'system_navigation/method_hash'
require_relative 'system_navigation/ancestor_method_finder'
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

  ##
  # Query methods for instance variables in descending (subclasses) and
  # ascending (superclasses) fashion.
  #
  # @example Global
  #   class A
  #     def initialize
  #       @foo = 1
  #     end
  #   end
  #
  #   class B
  #     attr_reader :foo
  #   end
  #
  #   sn.all_accesses(to: :@foo)
  #   #=> [#<UnboundMethod: A#initialize>, #<UnboundMethod: B#foo>]
  #
  # @example Local
  #   class A
  #     def initialize
  #       @foo = 1
  #     end
  #   end
  #
  #   class B
  #     attr_reader :foo
  #   end
  #
  #   sn.all_accesses(to: :@foo, from: B)
  #   #=> [#<UnboundMethod: B#foo>]
  #
  # @example Only get invokations
  #   class A
  #     def initialize
  #       @foo = 1
  #     end
  #   end
  #
  #   class B
  #     attr_reader :foo
  #   end
  #
  #   sn.all_accesses(to: :@foo, only_get: true)
  #   #=> [#<UnboundMethod: B#foo>]
  #
  # @param to [Symbol] The name of the instance variable to search for
  # @param from [Class, Module] The behaviour that limits the scope of the
  #   query. Optional. If omitted, performs the query starting from the top of
  #   the object hierarchy (BasicObject)
  # @param only_get [Boolean] Limits the scope of the query only to methods that
  #   write into the +ivar+. Optional. Mutually exclusive with +only_set+
  # @param only_set [Boolean] Limits the scope of the query only to methods that
  #   read from the +ivar+. Optional. Mutually exclusive with +only_get+
  # @return [Array<UnboundMethod>] methods that access the +ivar+ according to
  #   the given scope
  # @note This is a very costly operation, if you don't provide the +from+
  #   argument
  def all_accesses(to:, from: nil, only_get: nil, only_set: nil)
    if only_set && only_get
      fail ArgumentError, 'both only_get and only_set were provided'
    end

    (from || BasicObject).with_all_sub_and_superclasses.flat_map do |klass|
      klass.select_methods_that_access(to, only_get, only_set)
    end
  end

  ##
  # Query methods for literals they call.
  #
  # @example Global
  #   class A
  #     def foo
  #       :hello
  #     end
  #   end
  #
  #   class B
  #     def bar
  #       :hello
  #     end
  #   end
  #
  #   sn.all_calls(on: :hello)
  #   #=> [#<UnboundMethod: A#foo>, #<UnboundMethod: B#bar>]
  #
  # @example Local
  #   class A
  #     def foo
  #       :hello
  #     end
  #   end
  #
  #   class B
  #     def bar
  #       :hello
  #     end
  #   end
  #
  #   sn.all_calls(on: :hello, from: A)
  #   #=> [#<UnboundMethod: A#foo>]
  #
  # @example Gem
  #   sn.all_calls(on: :singleton, gem: 'system-navigation')
  #   #=> [...]
  #
  # @param on [Boolean, Integer, Float, String, Symbol, Array, Hash, Range,
  #   Regexp] The literal to search for
  # @param from [Class, Module] The behaviour that limits the scope of the
  #   query. If it's present, the search will be performed from top to bottom
  #   (only subclasses). Optional
  # @param gem [String] Limits the scope of the query only to methods
  #   that are defined in the RubyGem +gem+ classes and modules. Optional.
  # @return [Array<UnboundMethod>] methods that call the given +literal+
  # @note This is a very costly operation, if you don't provide the +from+
  #   argument
  # @note The list of supported literals can be found here:
  #   http://ruby-doc.org/core-2.2.2/doc/syntax/literals_rdoc.html
  def all_calls(on:, from: nil, gem: nil)
    if from && gem
      fail ArgumentError, 'both from and gem were provided'
    end

    subject = if from
                from.with_all_subclasses
              elsif gem
                self.all_classes_and_modules_in_gem_named(gem)
              else
                self.all_classes_and_modules
              end

    subject.flat_map { |behavior| behavior.select_methods_that_refer_to(on) }
  end

  ##
  # Query classes for the methods they implement.
  #
  # @example
  #   sn.all_classes_implementing(:~)
  #   #=> [Regexp, Bignum, Fixnum]
  #
  # @param selector [Symbol] the name of the method to be searched for
  # @return [Array<Class>] classes that implement +selector+
  def all_classes_implementing(selector)
    self.all_classes.select { |klass| klass.includes_selector?(selector) }
  end

  ##
  # Query modules for the methods they implement.
  #
  # @example
  #   sn.all_classes_implementing(:select)
  #   #=> [Enumerable, Kernel, #<Module:0x007f56daf92918>]
  #
  # @param selector [Symbol] the name of the method to be searched for
  # @return [Array<Class>] modules that implement +selector+
  def all_modules_implementing(selector)
    self.all_modules.select { |mod| mod.includes_selector?(selector) }
  end

  def all_implementors_of(selector)
    self.all_behaviors.select { |klass| klass.includes_selector?(selector) }
  end

  def all_classes_in_gem_named(gem_name)
    self.all_classes.select { |klass| klass.belongs_to?(gem_name) }
  end

  def all_modules_in_gem_named(gem_name)
    self.all_modules.select { |klass| klass.belongs_to?(gem_name) }
  end

  def all_classes_and_modules_in_gem_named(gem_name)
    self.all_classes_and_modules.select do |klass|
      klass.belongs_to?(gem_name)
    end
  end

  def all_methods
    self.all_behaviors.flat_map { |klass| klass.own_methods }
  end

  def all_methods_with_source(string:, match_case: true)
    self.all_behaviors.flat_map do |klass|
      klass.select_matching_methods(string, match_case)
    end
  end

  def all_c_methods
    self.all_behaviors.flat_map { |klass| klass.select_c_methods }
  end

  def all_rb_methods
    self.all_behaviors.flat_map { |klass| klass.select_rb_methods }
  end

  def all_senders(of:)
    self.all_classes_and_modules.flat_map { |klass| klass.select_senders_of(of) }
  end

  def all_sent_messages
    self.all_behaviors.flat_map do |klass|
      klass.all_messages
    end.uniq
  end
end
