require_relative 'helper'

class TestSystemNavigationAllCalls < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_calls_bad_arguments
    assert_raises(ArgumentError) do
      @sn.all_calls(on: :foo, gem: 'bar', from: Class.new)
    end
  end

  def test_all_calls_global
    test_class = Class.new do
      def drum; :drum_n_bass_yo; end
      def none; @none; end
    end

    another_test_class = Class.new do
      def boom; :drum_n_bass_yo; end
    end

    singleton_test_class = Class.new do
      class << self
        def single; :drum_n_bass_yo; end
      end
    end

    expected_methods = [
      test_class.instance_method(:drum),
      another_test_class.instance_method(:boom),
      singleton_test_class.singleton_class.instance_method(:single),
      self.class.instance_method(__method__)
    ]
    assert_equal expected_methods, @sn.all_calls(on: :drum_n_bass_yo)
  end

  def test_all_calls_accessors
    test_class = Class.new do
      attr_accessor :comrade_joseph_koba_stalin
      def fluffy; :fluffy; end
    end

    another_test_class = Class.new do
      attr_reader :comrade_joseph_koba_stalin
    end

    and_another_test_class = Class.new do
      attr_writer :comrade_joseph_koba_stalin
    end

    expected_methods = [
      test_class.instance_method(:comrade_joseph_koba_stalin),
      another_test_class.instance_method(:comrade_joseph_koba_stalin),
      self.class.instance_method(__method__)
    ]
    assert_equal expected_methods, @sn.all_calls(on: :comrade_joseph_koba_stalin)

    expected_methods = [
      test_class.instance_method(:comrade_joseph_koba_stalin=),
      and_another_test_class.instance_method(:comrade_joseph_koba_stalin=),
      self.class.instance_method(__method__)
    ]
    assert_equal expected_methods, @sn.all_calls(on: :comrade_joseph_koba_stalin=)
  end

  def test_all_calls_simple_hash
    test_class = Class.new do
      def piggy; {comrade_vladimir_lenin_ulyanov: 1, oinky: 2}; end
    end

    another_test_class = Class.new do
      def biggy
        { bingo: [:bango, :bongo],
          bish: [:comrade_lavrentiy_pavlovich_beria, :bosh] }
      end
    end

    expected_methods = [
      test_class.instance_method(:piggy),
      self.class.instance_method(__method__)
    ]
    assert_equal expected_methods, @sn.all_calls(on: :comrade_vladimir_lenin_ulyanov)

    expected_methods = [
      another_test_class.instance_method(:biggy),
      self.class.instance_method(__method__)
    ]
    assert_equal expected_methods, @sn.all_calls(on: :comrade_lavrentiy_pavlovich_beria)
  end

  def test_all_calls_eval
    test_class = Class.new do
      def eval; eval(':marshal_zhukov'); end
      def nested_eval; eval('eval(:marshal_zhukov)'); end
    end

    expected_methods = [
      test_class.instance_method(:eval),
      test_class.instance_method(:nested_eval),
      self.class.instance_method(__method__)
    ]
    assert_equal expected_methods, @sn.all_calls(on: :marshal_zhukov)
  end

  def test_all_calls_local
    parent_class = Class.new do
      def bingo; :woohoo; end
    end

    test_class = Class.new(parent_class) do
      def bango; :woohoo; end
      def meh; :meh; end
    end

    child_class = Class.new(test_class) do
      def bongo; :woohoo; end
    end

    _another_test_class = Class.new do
      def bish; :woohoo; end
    end

    expected_methods = [
      test_class.instance_method(:bango),
      child_class.instance_method(:bongo),
    ]
    assert_equal expected_methods, @sn.all_calls(on: :woohoo, from: test_class)
  end

  def test_all_calls_gem
    test_module = Module.new do
      def bango; :bingo; end
    end

    parent_class = Class.new do
      def foo; :bingo; end
    end

    test_class = Class.new(parent_class) do
      def self.bingo; :bingo; end
      include test_module
      def bongo; :bongo; end
    end

    expected_methods = [
      test_class.instance_method(:bango),
      parent_class.instance_method(:foo),
      test_class.singleton_class.instance_method(:bingo)
    ]
    assert_equal expected_methods,
                 @sn.all_local_calls(on: :bingo, of_class: test_class)
  end

  def test_all_calls_gem
    expected = [ Minitest.singleton_method(:autorun),
                 Minitest::Runnable.singleton_method(:on_signal),
                 Minitest::Spec::DSL.instance_method(:spec_type) ]
    assert_equal expected, @sn.all_calls(on: :call, gem: 'minitest')
  end
end
