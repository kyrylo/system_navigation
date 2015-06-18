require 'fast_method_source'

require 'forwardable'
require 'strscan'
require 'ripper'

require_relative 'system_navigation/array_refinement'
require_relative 'system_navigation/module_refinement'
require_relative 'system_navigation/ruby_environment'
require_relative 'system_navigation/instruction_stream'
require_relative 'system_navigation/expression_tree'
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

  using ModuleRefinement

  extend Forwardable
  def_delegators :@environment,
                 :all_behaviors, :all_classes, :all_classes_and_modules,
                 :all_modules, :all_objects

  def self.default
    self.new
  end

  VAR_TEMPLATE = /\A[\$@]@?.+/

  def initialize
    @environment = SystemNavigation::RubyEnvironment.new
  end

  ##
  # Query methods for instance/global/class variables in descending (subclasses)
  # and ascending (superclasses) fashion.
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
  # @param to [Symbol] The name of the instance/global/class variable to search
  #   for
  # @param from [Class] The class that limits the scope of the query. Optional.
  #   If omitted, performs the query starting from the top of the object
  #   hierarchy (BasicObject)
  # @param only_get [Boolean] Limits the scope of the query only to methods that
  #   write into the +var+. Optional. Mutually exclusive with +only_set+
  # @param only_set [Boolean] Limits the scope of the query only to methods that
  #   read from the +var+. Optional. Mutually exclusive with +only_get+
  # @return [Array<UnboundMethod>] methods that access the +var+ according to
  #   the given scope
  # @note This is a very costly operation, if you don't provide the +from+
  #   argument
  def all_accesses(to:, from: nil, only_get: nil, only_set: nil)
    if only_set && only_get
      fail ArgumentError, 'both only_get and only_set were provided'
    end

    if from && !from.instance_of?(Class)
      fail TypeError, "from must be a Class (#{from.class} given)"
    end

    unless to.match(VAR_TEMPLATE)
      fail ArgumentError, 'invalid argument for to:'
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
  #   sn.all_calls(on: :singleton, gem: 'system_navigation')
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
  # @!macro [new] selector.param
  #   @param selector [Symbol] the name of the method to be searched for
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
  # @!macro selector.param
  # @return [Array<Class>] modules that implement +selector+
  def all_modules_implementing(selector)
    self.all_modules.select { |mod| mod.includes_selector?(selector) }
  end

  ##
  # Query classes and modules for the methods they implement.
  #
  # @example
  #   sn.all_implementors_of(:select)
  #   #=> [Enumerator::Lazy, IO, ..., #<Class:Kernel>]
  #
  # @!macro selector.param
  # @return [Array<Class, Module>] classes and modules that implement +selector+
  def all_implementors_of(selector)
    self.all_classes_and_modules.select do |klass|
      klass.includes_selector?(selector)
    end
  end

  ##
  # Query gems for classes they implement.
  #
  # @example
  #   sn.all_classes_in_gem_named('system_navigation')
  #   #=> [SystemNavigation::AncestorMethodFinder, ..., SystemNavigation]
  #
  # @!macro [new] gem.param
  #   @param gem [String] The name of the gem. Case sensitive
  # @return [Array<Class>] classes that were defined by +gem+
  def all_classes_in_gem_named(gem)
    self.all_classes.select { |klass| klass.belongs_to?(gem) }
  end

  ##
  # Query gems for modules they implement.
  #
  # @example
  #   sn.all_modules_in_gem_named('pry-theme')
  #   #=> [PryTheme::Theme::DefaultAttrs, ..., PryTheme]
  #
  # @!macro [new] gem.param
  # @return [Array<Class>] modules that were defined by +gem+
  def all_modules_in_gem_named(gem)
    self.all_modules.select { |mod| mod.belongs_to?(gem) }
  end

  ##
  # Query gems for classes and modules they implement.
  #
  # @example
  #   sn.all_classes_and_modules_in_gem_named('pry-theme')
  #   #=> [PryTheme::Preview, ..., PryTheme::Color256]
  #
  # @!macro [new] gem.param
  # @return [Array<Class, Module>] classes and modules that were defined by
  #   +gem+
  def all_classes_and_modules_in_gem_named(gem)
    self.all_classes_and_modules.select { |klassmod| klassmod.belongs_to?(gem) }
  end

  ##
  # Get all methods defined in current Ruby process.
  #
  # @example
  #   sn.all_methods
  #   #=> [#<UnboundMethod: Gem::Dependency#name>, ...]
  #
  # @return [Array<UnboundMethod>] all methods that exist
  def all_methods
    self.all_classes_and_modules.map do |klassmod|
      klassmod.own_methods.as_array
    end.flatten
  end

  ##
  # Search for a string in all classes and modules including their comments and
  # names.
  #
  # @example
  #   class A
  #     def foo
  #       :hello_hi
  #     end
  #   end
  #
  #   class B
  #     def bar
  #       'hello_hi'
  #     end
  #   end
  #
  #   module M
  #     # hello_hi
  #     def baz
  #     end
  #   end
  #
  #
  # sn.all_methods_with_source(string: 'hello_hi')
  # #=> [#<UnboundMethod: B#bar>, #<UnboundMethod: A#foo>, #<UnboundMethod: M#foo>]
  #
  # @param string [String] The string to be searched for
  # @param match_case [Boolean] Whether to match case or not. Optional
  # @return [Array<UnboundMethod>] methods that matched +string+
  # @note This is a very costly operation
  def all_methods_with_source(string:, match_case: true)
    return [] if string.empty?

    self.all_classes_and_modules.flat_map do |klassmod|
      klassmod.select_matching_methods(string, match_case)
    end
  end

  ##
  # Get all methods implemented in C.
  #
  # @example
  #   sn.all_c_methods
  #   #=> [#<UnboundMethod: #<Class:Etc>#getlogin>, ...]
  #
  # @return [Array<UnboundMethod>] all methods that were implemented in C
  def all_c_methods
    self.all_classes_and_modules.flat_map do |klassmod|
      klassmod.select_c_methods
    end
  end

  ##
  # Get all methods implemented in Ruby.
  #
  # @example
  #   sn.all_rb_methods
  #   #=> [#<UnboundMethod: Gem::Dependency#name>, ...]
  #
  # @return [Array<UnboundMethod>] all methods that were implemented in Ruby
  def all_rb_methods
    self.all_classes_and_modules.flat_map do |klassmod|
      klassmod.select_rb_methods
    end
  end

  ##
  # Get all methods that implement +message+.
  #
  # @example
  #   sn.all_senders_of(:puts)
  #   #=> []
  #
  # @param message [Symbol] The name of the method you're interested in
  # @return [Array<UnboundMethod>] all methods that send +message
  def all_senders_of(message)
    self.all_classes_and_modules.flat_map do |klassmod|
      klassmod.select_senders_of(message)
    end
  end

  ##
  # Get all messages that all methods send.
  #
  # @example
  #   sn.all_sent_messages
  #   #=> [:name, :hash, ..., :type]
  #
  # @return [Array<Symbol>] all unique messages
  # @note This is a very costly operation
  def all_sent_messages
    self.all_classes_and_modules.flat_map do |klassmod|
      klassmod.all_messages.as_array
    end.uniq
  end
end
