require_relative '../helper'

class TestSystemNavigationAllCalls < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_accesses_to
    test_class = Class.new do
      def test_all_accesses_to
        @test_all_accesses_to
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to),
      self.class.instance_method(__method__)
    ]

    assert_equal expected, @sn.all_accesses(to: :@test_all_accesses_to)
  end

  def test_all_accesses_to_from
    test_class = Class.new do
      def test_all_accesses_to_from
        @test_all_accesses_to_from
      end
    end

    assert_equal [test_class.instance_method(:test_all_accesses_to_from)],
                 @sn.all_accesses(to: :@test_all_accesses_to_from,
                                  from: test_class)
  end

  def test_all_accesses_to_from_superclass
    parent_class = Class.new do
      def test_all_accesses_to_from_superclass
        @test_all_accesses_to_from_superclass
      end
    end

    test_class = Class.new(parent_class) do
      def test_all_accesses_to_from_superclass
        @test_all_accesses_to_from_superclass
      end
    end

    expected = [
      parent_class.instance_method(:test_all_accesses_to_from_superclass),
      test_class.instance_method(:test_all_accesses_to_from_superclass)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_superclass,
                                  from: test_class)
  end

  def test_all_accesses_to_from_subclass
    parent_class = Class.new do
      def test_all_accesses_to_from_subclass
        @test_all_accesses_to_from_subclass
      end
    end

    test_class = Class.new(parent_class) do
      def test_all_accesses_to_from_subclass
        @test_all_accesses_to_from_subclass
      end
    end

    expected = [
      parent_class.instance_method(:test_all_accesses_to_from_subclass),
      test_class.instance_method(:test_all_accesses_to_from_subclass)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_subclass,
                                  from: parent_class)
  end

  def test_all_accesses_to_from_singleton
    test_class = Class.new do
      def self.test_all_accesses_to_from_singleton
        @test_all_accesses_to_from_singleton
      end
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_accesses_to_from_singleton)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_singleton,
                                  from: test_class)
  end

  def test_all_accesses_to_from_singleton_superclass
    parent_class = Class.new do
      def self.test_all_accesses_to_from_singleton_superclass
        @test_all_accesses_to_from_singleton_superclass
      end
    end

    test_class = Class.new(parent_class) do
      def self.test_all_accesses_to_from_singleton_superclass
        @test_all_accesses_to_from_singleton_superclass
      end
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_accesses_to_from_singleton_superclass),
      parent_class.singleton_class.instance_method(:test_all_accesses_to_from_singleton_superclass)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_singleton_superclass,
                                  from: test_class)
  end

  def test_all_accesses_to_from_singleton_subclass
    parent_class = Class.new do
      def self.test_all_accesses_to_from_singleton_subclass
        @test_all_accesses_to_from_singleton_subclass
      end
    end

    test_class = Class.new(parent_class) do
      def self.test_all_accesses_to_from_singleton_subclass
        @test_all_accesses_to_from_singleton_subclass
      end
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_accesses_to_from_singleton_subclass),
      parent_class.singleton_class.instance_method(:test_all_accesses_to_from_singleton_subclass)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_singleton_subclass,
                                  from: parent_class)
  end

  def test_all_accesses_to_from_attr_accessor
    test_class = Class.new do
      attr_accessor :test_all_accesses_to_from_attr_accessor
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_attr_accessor),
      test_class.instance_method(:test_all_accesses_to_from_attr_accessor=)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_attr_accessor,
                                  from: test_class)
  end

  def test_all_accesses_to_from_attr_reader
    test_class = Class.new do
      attr_reader :test_all_accesses_to_from_attr_reader
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_attr_reader)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_attr_reader,
                                  from: test_class)
  end

  def test_all_accesses_to_from_attr_writer
    test_class = Class.new do
      attr_writer :test_all_accesses_to_from_attr_writer
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_attr_writer=)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_attr_writer,
                                  from: test_class)
  end

  def test_all_accesses_to_from_attr_accessor_singleton
    test_class = Class.new do
      class << self
        attr_accessor :test_all_accesses_to_from_attr_accessor_singleton
      end
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_accesses_to_from_attr_accessor_singleton),
      test_class.singleton_class.instance_method(:test_all_accesses_to_from_attr_accessor_singleton=)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_attr_accessor_singleton,
                                  from: test_class)
  end

  def test_all_accesses_to_from_instance_variable_get
    test_class = Class.new do
      def test_all_accesses_to_from_instance_variable_get
        instance_variable_get(:@test_all_accesses_to_from_instance_variable_get)
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_instance_variable_get)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_instance_variable_get,
                                  from: test_class)
  end

  def test_all_accesses_to_from_instance_variable_set
    test_class = Class.new do
      def test_all_accesses_to_from_instance_variable_set
        instance_variable_set(:@test_all_accesses_to_from_instance_variable_set, 1)
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_instance_variable_set)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_instance_variable_set,
                                  from: test_class)
  end

  def test_all_accesses_to_from_set
    test_class = Class.new do
      def test_all_accesses_to_from_set
        @test_all_accesses_to_from_set = 1
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_set)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_set,
                                  from: test_class)
  end

  def test_all_accesses_to_from_set_and_get
    test_class = Class.new do
      def test_all_accesses_to_from_set_and_get
        @test_all_accesses_to_from_set_and_get = 1
        @test_all_accesses_to_from_set_and_get
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_set_and_get)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_set_and_get,
                                  from: test_class)
  end

  def test_all_accesses_to_from_eval_get
    test_class = Class.new do
      def test_all_accesses_to_from_eval_get
        eval('@test_all_accesses_to_from_eval_get')
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_eval_get)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_eval_get,
                                  from: test_class)
  end

  def test_all_accesses_to_from_eval_set
    test_class = Class.new do
      def test_all_accesses_to_from_eval_set
        eval('@test_all_accesses_to_from_eval_set = 1')
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_eval_set)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_eval_set,
                                  from: test_class)
  end

  def test_all_accesses_to_from_deep_eval_get
    test_class = Class.new do
      def test_all_accesses_to_from_deep_eval_get
        eval('eval("eval(\'@test_all_accesses_to_from_deep_eval_get\')")')
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_deep_eval_get)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_deep_eval_get,
                                  from: test_class)
  end

  def test_all_accesses_to_from_nonexistent
    test_class = Class.new do
      def test_all_accesses_to_from_nonexistent
        @test_all_accesses_to_from_nonexistent
      end
    end

    assert_equal [], @sn.all_accesses(to: :@abcdefg, from: test_class)
  end

  def test_all_accesses_to_from_private_set
    test_class = Class.new do
      private

      def test_all_accesses_to_from_private_set
        @test_all_accesses_to_from_private_set = 1
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_private_set)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_private_set,
                                  from: test_class)
  end

  def test_all_accesses_to_from_fuzzy
    test_class = Class.new do
      def self.test_all_accesses_to_from_fuzzy
        @test_all_accesses_to_from_fuzzy
      end

      def test_all_accesses_to_from_fuzzy
        @test_all_accesses_to_from_fuzzy = 1
      end
    end

    assert_raises(ArgumentError) do
      @sn.all_accesses(to: :'@', from: test_class)
    end
  end

  def test_all_accesses_to_fuzzy
    assert_raises(ArgumentError) do
      @sn.all_accesses(to: :'@')
    end
  end

  def test_all_accesses_to_from_include
    test_module = Module.new do
      def test_all_accesses_to_from_include
        @test_all_accesses_to_from_include
      end
    end

    test_class = Class.new do
      include test_module
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_include)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_include,
                                  from: test_class)
  end

  def test_all_accesses_to_from_include_singleton
    test_module = Module.new do
      def self.test_all_accesses_to_from_include_singleton
        @test_all_accesses_to_from_include_singleton
      end
    end

    test_class = Class.new do
      include test_module
    end

    assert_equal [],
                 @sn.all_accesses(to: :@test_all_accesses_to_from_include_singleton,
                                  from: test_class)
  end

  def test_all_accesses_to_from_prepend
    test_module = Module.new do
      def test_all_accesses_to_from_prepend
        @test_all_accesses_to_from_prepend
      end
    end

    test_class = Class.new do
      prepend test_module
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_prepend)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_prepend,
                                  from: test_class)
  end

  def test_all_accesses_to_from_prepend_singleton
    test_module = Module.new do
      def self.test_all_accesses_to_from_prepend_singleton
        @test_all_accesses_to_from_prepend_singleton
      end
    end

    test_class = Class.new do
      prepend test_module
    end

    assert_equal [],
                 @sn.all_accesses(to: :@test_all_accesses_to_from_prepend_singleton,
                                  from: test_class)
  end

  def test_all_accesses_to_from_extend
    test_module = Module.new do
      def test_all_accesses_to_from_extend
        @test_all_accesses_to_from_extend
      end
    end

    test_class = Class.new do
      extend test_module
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_accesses_to_from_extend)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_extend,
                                  from: test_class)
  end

  def test_all_accesses_to_from_deep_include
    test_module_a = Module.new do
      def test_all_accesses_to_from_deep_include
        @test_all_accesses_to_from_deep_include
      end
    end

    test_module_b = Module.new do
      include test_module_a
    end

    test_class = Class.new do
      include test_module_b
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_deep_include)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_deep_include,
                                  from: test_class)
  end

  def test_all_accesses_to_from_include_into_singleton
    test_module = Module.new do
      def test_all_accesses_to_from_include_into_singleton
        @test_all_accesses_to_from_include_into_singleton
      end
    end

    test_class = Class.new do
      self.singleton_class.include(test_module)
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_accesses_to_from_include_into_singleton)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_include_into_singleton,
                                  from: test_class)
  end

  def test_all_accesses_to_from_include_singleton_into_singleton
    test_module = Module.new do
      def self.test_all_accesses_to_from_include_singleton_into_singleton
        @test_all_accesses_to_from_include_singleton_into_singleton
      end
    end

    test_class = Class.new do
      self.singleton_class.include(test_module)
    end

    assert_equal [],
                 @sn.all_accesses(to: :@test_all_accesses_to_from_include_singleton_into_singleton,
                                  from: test_class)
  end

  def test_all_accesses_to_from_prepend_to_singleton
    test_module = Module.new do
      def test_all_accesses_to_from_prepend_to_singleton
        @test_all_accesses_to_from_prepend_to_singleton
      end
    end

    test_class = Class.new do
      self.singleton_class.prepend(test_module)
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_accesses_to_from_prepend_to_singleton)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_prepend_to_singleton,
                                  from: test_class)
  end

  def test_all_accesses_to_from_prepend_singleton_to_singleton
    test_module = Module.new do
      def self.test_all_accesses_to_from_prepend_singleton_to_singleton
        @test_all_accesses_to_from_prepend_singleton_to_singleton
      end
    end

    test_class = Class.new do
      self.singleton_class.prepend(test_module)
    end

    assert_equal [],
                 @sn.all_accesses(to: :@test_all_accesses_to_from_prepend_singleton_to_singleton,
                                  from: test_class)
  end

  def test_all_accesses_to_from_extend_with_singleton
    test_module = Module.new do
      def test_all_accesses_to_from_extend_with_singleton
        @test_all_accesses_to_from_extend_with_singleton
      end
    end

    test_class = Class.new do
      self.singleton_class.extend(test_module)
    end

    expected = [
      test_class.singleton_class.singleton_class.instance_method(:test_all_accesses_to_from_extend_with_singleton)
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :@test_all_accesses_to_from_extend_with_singleton,
                                  from: test_class.singleton_class)
    assert_equal [],
                 @sn.all_accesses(to: :@test_all_accesses_to_from_extend_with_singleton,
                                  from: test_class)

  end

  def test_all_accesses_to_from_extend_singleton_with_singleton
    test_module = Module.new do
      def self.test_all_accesses_to_from_extend_singleton_with_singleton
        @test_all_accesses_to_from_extend_singleton_with_singleton
      end
    end

    test_class = Class.new do
      self.singleton_class.prepend(test_module)
    end

    assert_equal [],
                 @sn.all_accesses(to: :@test_all_accesses_to_from_extend_singleton_with_singleton,
                                  from: test_class)
  end

  def test_all_accesses_to_from_only_get
    test_class = Class.new do
      def test_all_accesses_to_from_only_get
        @test_all_accesses_to_from_only_get
      end

      def test_all_accesses_to_from_only_set
        @test_all_accesses_to_from_only_get = 1
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_only_get),
    ]

    assert_equal expected, @sn.all_accesses(to: :@test_all_accesses_to_from_only_get,
                                            from: test_class,
                                            only_get: true)
  end

  def test_all_accesses_to_from_only_set
    test_class = Class.new do
      def test_all_accesses_to_from_only_get
        @test_all_accesses_to_from_only_set
      end

      def test_all_accesses_to_from_only_set
        @test_all_accesses_to_from_only_set = 1
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_from_only_set),
    ]

    assert_equal expected, @sn.all_accesses(to: :@test_all_accesses_to_from_only_set,
                                            from: test_class,
                                            only_set: true)
  end

  def test_all_accesses_to_from_only_get_only_set
    assert_raises(ArgumentError) do
      @sn.all_accesses(to: :@foo, from: Class.new, only_set: true, only_get: true)
    end
  end

  def test_all_accesses_to_from_module
    test_module = Module.new

    assert_raises(TypeError) do
      @sn.all_accesses(to: :@test_all_accesses_to_from_module,
                       from: test_module)
    end
  end

  def test_all_accesses_to_global_variable
    test_class = Class.new do
      def test_all_accesses_to_global_variable_all_set
        $TEST_ALL_ACCESSES_TO_GLOBAL_VARIABLE_ALL = 1
      end

      def test_all_accesses_to_global_variable_all_get
        $TEST_ALL_ACCESSES_TO_GLOBAL_VARIABLE_ALL
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_global_variable_all_set),
      test_class.instance_method(:test_all_accesses_to_global_variable_all_get)
    ]

    assert_equal expected, @sn.all_accesses(to: :$TEST_ALL_ACCESSES_TO_GLOBAL_VARIABLE_ALL,
                                            from: test_class)
  end

  def test_all_accesses_to_global_variable_set
    test_class = Class.new do
      def test_all_accesses_to_global_variable_set
        $TEST_ALL_ACCESSES_TO_GLOBAL_VARIABLE_SET = 1
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_global_variable_set)
    ]

    assert_equal expected, @sn.all_accesses(to: :$TEST_ALL_ACCESSES_TO_GLOBAL_VARIABLE_SET,
                                            from: test_class,
                                            only_set: true)
  end

  def test_all_accesses_to_global_variable_get
    test_class = Class.new do
      def test_all_accesses_to_global_variable_get
        $TEST_ALL_ACCESSES_TO_GLOBAL_VARIABLE_GET
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_global_variable_get)
    ]

    assert_equal expected, @sn.all_accesses(to: :$TEST_ALL_ACCESSES_TO_GLOBAL_VARIABLE_GET,
                                            from: test_class,
                                            only_get: true)
  end

  def test_all_accesses_to_class_variable
    test_class = Class.new do
      def test_all_accesses_to_class_variable_all_set
        @@test_all_accesses_to_class_variable_all = 1
      end

      def test_all_accesses_to_class_variable_all_get
        @@test_all_accesses_to_class_variable_all
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_class_variable_all_set),
      test_class.instance_method(:test_all_accesses_to_class_variable_all_get)
    ]

    assert_equal expected, @sn.all_accesses(to: :@@test_all_accesses_to_class_variable_all,
                                            from: test_class)
  end

  def test_all_accesses_to_class_variable_set
    test_class = Class.new do
      def test_all_accesses_to_class_variable_set
        @@test_all_accesses_to_class_variable_set = 1
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_class_variable_set)
    ]

    assert_equal expected, @sn.all_accesses(to: :@@test_all_accesses_to_class_variable_set,
                                            from: test_class,
                                            only_set: true)
  end

  def test_all_accesses_to_class_variable_get
    test_class = Class.new do
      def test_all_accesses_to_class_variable_get
        @@test_all_accesses_to_class_variable_get
      end
    end

    expected = [
      test_class.instance_method(:test_all_accesses_to_class_variable_get)
    ]

    assert_equal expected, @sn.all_accesses(to: :@@test_all_accesses_to_class_variable_get,
                                            from: test_class,
                                            only_get: true)
  end
end
