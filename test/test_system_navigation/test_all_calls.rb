require_relative '../helper'

class TestSystemNavigationAllCalls < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_calls_on
    test_class = Class.new do
      def test_all_calls_on
        :test_all_calls_on
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on),
      self.class.instance_method(__method__)
    ]

    assert_equal expected, @sn.all_calls(on: :test_all_calls_on)
  end

  def test_all_calls_on_from
    test_class = Class.new do
      def test_all_calls_on_from
        :test_all_calls_on_from
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from),
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from, from: test_class)
  end

  def test_all_calls_on_gem
    expected = [ Minitest.singleton_class.instance_method(:autorun),
                 Minitest::Runnable.singleton_class.instance_method(:on_signal),
                 Minitest::Spec::DSL.instance_method(:spec_type) ]
    assert_equal expected, @sn.all_calls(on: :call, gem: 'minitest')
  end

  def test_all_calls_on_from_gem
    assert_raises(ArgumentError) do
      @sn.all_calls(on: :foo, gem: 'bar', from: Class.new)
    end
  end

  def test_all_calls_on_from_superclass
    parent_class = Class.new do
      def test_all_calls_on_from_superclass
        :test_all_calls_on_from_superclass
      end
    end

    test_class = Class.new(parent_class) do
      def test_all_calls_on_from_superclass
        :test_all_calls_on_from_superclass
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_superclass)
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_superclass,
                               from: test_class)
  end

  def test_all_calls_on_from_subclass
    parent_class = Class.new do
      def test_all_calls_on_from_superclass
        :test_all_calls_on_from_superclass
      end
    end

    test_class = Class.new(parent_class) do
      def test_all_calls_on_from_superclass
        :test_all_calls_on_from_superclass
      end
    end

    expected = [
      parent_class.instance_method(:test_all_calls_on_from_superclass),
      test_class.instance_method(:test_all_calls_on_from_superclass)
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_superclass,
                               from: parent_class)
  end

  def test_all_calls_on_from_singleton
    test_class = Class.new do
      def self.test_all_calls_on_from_singleton
        :test_all_calls_on_from_singleton
      end
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_calls_on_from_singleton)
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_singleton,
                               from: test_class)
  end

  def test_all_calls_on_from_singleton_superclass
    parent_class = Class.new do
      def self.test_all_calls_on_from_singleton_superclass
        :test_all_calls_on_from_singleton_superclass
      end
    end

    test_class = Class.new(parent_class) do
      def self.test_all_calls_on_from_singleton_superclass
        :test_all_calls_on_from_singleton_superclass
      end
    end

    assert_equal [],
                 @sn.all_calls(on: :@test_all_calls_on_from_singleton_superclass,
                               from: test_class)
  end

  def test_all_calls_on_from_singleton_subclass
    parent_class = Class.new do
      def self.test_all_calls_on_from_singleton_subclass
        :test_all_calls_on_from_singleton_subclass
      end
    end

    test_class = Class.new(parent_class) do
      def self.test_all_calls_on_from_singleton_subclass
        :test_all_calls_on_from_singleton_subclass
      end
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_calls_on_from_singleton_subclass),
      parent_class.singleton_class.instance_method(:test_all_calls_on_from_singleton_subclass)
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_singleton_subclass,
                               from: parent_class)
  end

  def test_all_calls_on_from_attr_accessor_read
    test_class = Class.new do
      attr_accessor :test_all_calls_on_from_attr_accessor_read
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_attr_accessor_read),
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_attr_accessor_read,
                               from: test_class)
  end

  def test_all_calls_on_from_attr_accessor_write
    test_class = Class.new do
      attr_accessor :test_all_calls_on_from_attr_accessor_write
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_attr_accessor_write=),
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_attr_accessor_write=,
                                   from: test_class)
  end

  def test_all_calls_on_from_attr_reader
    test_class = Class.new do
      attr_reader :test_all_calls_on_from_attr_reader
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_attr_reader)
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_attr_reader,
                               from: test_class)
  end

  def test_all_calls_on_from_attr_writer
    test_class = Class.new do
      attr_writer :test_all_calls_on_from_attr_writer
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_attr_writer=)
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_attr_writer=,
                                   from: test_class)
  end

  def test_all_calls_on_from_attr_accessor_singleton
    test_class = Class.new do
      class << self
        attr_reader :test_all_calls_on_from_attr_accessor_singleton
      end
    end

    expected = [
      test_class.singleton_class.instance_method(:test_all_calls_on_from_attr_accessor_singleton),
    ]

    assert_equal expected,
                 @sn.all_accesses(to: :test_all_calls_on_from_attr_accessor_singleton,
                                  from: test_class)
  end

  def test_all_calls_on_from_symbol_array_and_hash
    test_class = Class.new do
      def test_all_calls_on_from_symbol_array_and_hash
        { bingo: [:bango, :bongo],
          bish: [:test_all_calls_on_from_symbol_array_and_hash, :bosh] }
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_symbol_array_and_hash)
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_symbol_array_and_hash,
                               from: test_class)
  end

  def test_all_calls_on_from_hash
    test_class = Class.new do
      def test_all_calls_on_from_symbol_hash
        { test_all_calls_on_from_symbol_hash: 1, bingo: 2 }
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_symbol_hash)
    ]
    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_symbol_hash,
                               from: test_class)
  end

  def test_all_calls_on_from_eval
    test_class = Class.new do
      def test_all_calls_on_from_eval
        eval(':test_all_calls_on_from_eval')
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_eval),
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_eval,
                               from: test_class)
  end

  def test_all_calls_on_from_deep_eval
    test_class = Class.new do
      def test_all_calls_on_from_deep_eval
        eval('eval("eval(:test_all_calls_on_from_deep_eval)")')
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_deep_eval),
    ]

    assert_equal expected,
                 @sn.all_calls(on: :test_all_calls_on_from_deep_eval,
                               from: test_class)
  end

  def test_all_calls_on_from_nonexistent
    test_class = Class.new do
      def test_all_calls_on_from_nonexistent
        :test_all_calls_on_from_nonexistent
      end
    end

    assert_equal [], @sn.all_calls(on: :abcdefg, from: test_class)
  end

  def test_all_calls_on_from_true
    test_class = Class.new do
      def test_all_calls_on_from_true
        true
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_true),
    ]

    assert_equal expected, @sn.all_calls(on: true, from: test_class)
  end

  def test_all_calls_on_from_false
    test_class = Class.new do
      def test_all_calls_on_from_false
        false
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_false),
    ]

    assert_equal expected, @sn.all_calls(on: false, from: test_class)
  end

  def test_all_calls_on_from_nil
    test_class = Class.new do
      def test_all_calls_on_from_nil
        nil
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_nil),
    ]

    assert_equal expected, @sn.all_calls(on: nil, from: test_class)
  end

  def test_all_calls_on_from_100
    test_class = Class.new do
      def test_all_calls_on_from_100
        100
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_100),
    ]

    assert_equal expected, @sn.all_calls(on: 100, from: test_class)
  end

  def test_all_calls_on_from_1_00
    test_class = Class.new do
      def test_all_calls_on_from_1_00
        1_00
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_1_00),
    ]

    assert_equal expected, @sn.all_calls(on: 1_00, from: test_class)
  end

  def test_all_calls_on_from_100_float
    test_class = Class.new do
      def test_all_calls_on_from_100_float
        1.00
      end

      def test_all_calls_on_from_1
        1
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_100_float),
    ]

    assert_equal expected, @sn.all_calls(on: 1.00, from: test_class)
  end

  def test_all_calls_on_from_100e
    skip

    test_class = Class.new do
      def test_all_calls_on_from_100e
        100e-2
      end

      def test_all_calls_on_from_10_float
        1.0
      end

      def test_all_calls_on_from_100E
        100e-2
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_100e),
      test_class.instance_method(:test_all_calls_on_from_100E,)
    ]

    assert_equal expected, @sn.all_calls(on: 100e-2, from: test_class)
  end

  def test_all_calls_on_from_0d170
    skip

    test_class = Class.new do
      def test_all_calls_on_from_0d170
        0d170
      end

      def test_all_calls_on_from_0D170
        0D170
      end
    end

    expected = [
      test_class.instance_method(:test_all_calls_on_from_0d170),
      test_class.instance_method(:test_all_calls_on_from_0D170),
    ]

    assert_equal expected, @sn.all_calls(on: 0d170, from: test_class)
  end

  def test_all_calls_on_from_0xaa
    skip

    test_class = Class.new do
      def test_all_calls_on_from_0xaa
        0xaa
      end

      def test_all_calls_on_from_0xAa
        0xAa
      end

      def test_all_calls_on_from_0xAA
        0xAA
      end

      def test_all_calls_on_from_0Xaa
        0Xaa
      end

      def test_all_calls_on_from_0XAa
        0XAa
      end

      def test_all_calls_on_from_0XaA
        0XaA
      end

      expected = [
        test_class.instance_method(:test_all_calls_on_from_0xaa),
        test_class.instance_method(:test_all_calls_on_from_0xAa),
        test_class.instance_method(:test_all_calls_on_from_0xAA),
        test_class.instance_method(:test_all_calls_on_from_0Xaa),
        test_class.instance_method(:test_all_calls_on_from_0XAa),
        test_class.instance_method(:test_all_calls_on_from_0XaA)
      ]

      assert_equal expected, @sn.all_calls(on: 0xaa, from: test_class)
    end

    def test_all_calls_on_from_string
      skip

      test_class = Class.new do
        def test_all_calls_on_from_string
          "test_all_calls_on_from_string"
        end
      end

      expected = [
        test_class.instance_method(:test_all_calls_on_from_string)
      ]

      assert_equal expected,
                   @sn.all_calls(on: "test_all_calls_on_from_string",
                                 from: test_class)
    end

    def test_all_calls_on_from_hash
      skip

      test_class = Class.new do
        def test_all_calls_on_from_hash
          {1 => [:test_all_calls_on_from_hash]}
        end
      end

      expected = [
        test_class.instance_method(:test_all_calls_on_from_hash)
      ]

      assert_equal expected,
                   @sn.all_calls(on: {1 => [:test_all_calls_on_from_hash]},
                                 from: test_class)
    end

    def test_all_calls_on_from_array
      skip

      test_class = Class.new do
        def test_all_calls_on_from_array
          [1, :test_all_calls_on_from_array, 3.0]
        end
      end

      expected = [
        test_class.instance_method(:test_all_calls_on_from_array)
      ]

      assert_equal expected,
                   @sn.all_calls(on: [1, :test_all_calls_on_from_array, 3.0],
                                 from: test_class)
    end

    def test_all_calls_on_from_range
      skip

      test_class = Class.new do
        def test_all_calls_on_from_range
          0...2.test_all_calls_on_from_range
        end
      end

      expected = [
        test_class.instance_method(:test_all_calls_on_from_range)
      ]

      assert_equal expected, @sn.all_calls(on: 0...2, from: test_class)
    end

    def test_all_calls_on_from_backticks
      skip

      test_class = Class.new do
        def test_all_calls_on_from_backticks
          `test_all_calls_on_from_backticks`
        end
      end

      expected = [
        test_class.instance_method(:test_all_calls_on_from_backticks)
      ]

      assert_equal expected,
                   @sn.all_calls(on: `test_all_calls_on_from_backticks`,
                                 from: test_class)
    end
  end
end
