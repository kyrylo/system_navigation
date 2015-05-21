require_relative 'helper'

class TestSystemNavigation < Minitest::Test
  module Helper
    def access(ivar, klass)
      @sn.all_accesses(to: ivar, from: klass).sort_by(&:hash)
    end

    def calls_on(sym)
      @sn.all_calls(on: sym).sort_by(&:hash)
    end
  end

  include Helper

  def setup
    @sn = SystemNavigation.default
  end

  def test_all_accesses
    parent_class = Class.new do
      attr_reader :ivar

      def dynamic_read
        self.instance_variable_get(:@ivar)
      end

      def eval_write
        eval('@ivar = 100')
      end

      def parent_method
        @another_ivar
      end
    end

    test_class = Class.new(parent_class) do
      def initialize
        @ivar = 0
      end

      def read_and_write
        @ivar += 1
      end

      def mixed_write
        @another_ivar = 1
        @ivar = 99
        @and_another_ivar = 3
      end

      def dynamic_write
        self.instance_variable_set(:@ivar, 69)
      end

      def nested_eval
        eval("eval('@ivar')")
      end

      def random
        :empty
      end
    end

    child_class = Class.new(test_class) do
      attr_writer :ivar

      def method_read
        @ivar.succ
      end

      def eval_read
        eval('@ivar')
      end

      def empty
        :random
      end
    end

    expected_methods = [
      parent_class.instance_method(:ivar),
      parent_class.instance_method(:dynamic_read),
      parent_class.instance_method(:eval_write),
      test_class.instance_method(:initialize),
      test_class.instance_method(:read_and_write),
      test_class.instance_method(:mixed_write),
      test_class.instance_method(:nested_eval),
      child_class.instance_method(:method_read),
      child_class.instance_method(:eval_read),
      child_class.instance_method(:ivar=),
    ].sort_by(&:hash)

    assert_equal expected_methods, access(:@ivar, test_class)
    assert_equal [], access(:@nonexisting, test_class)
  end

  def test_all_accesses_private
    test_class = Class.new do
      def initialize(ivar)
        @ivar = ivar
      end

      private

      def private_read
        @ivar
      end

      def private_write
        @ivar = 11
      end
    end

    expected_methods = [
      test_class.instance_method(:initialize),
      test_class.instance_method(:private_write),
      test_class.instance_method(:private_read),
    ].sort_by(&:hash)

    assert_equal expected_methods, access(:@ivar, test_class)
  end

  def test_all_accesses_fuzzy_match
    test_class = Class.new do
      def initialize(ivar)
        @ivar = ivar
      end

      private def check
        @ivar.succ
      end
    end

    assert_equal [], access(:'@', test_class)
  end

  def test_all_accesses_basicobject_fuzzy
    assert_equal [], access(:'@', BasicObject)
  end

  def test_all_accesses_extend_include_prepend
    test_module_ext = Module.new do
      def ext
        @ivar = 1
      end
    end

    test_module_incl = Module.new do
      def incl
        @ivar
      end
    end

    test_module_prep = Module.new do
      def prep
        @ivar = 1
        @ivar
      end
    end

    test_class = Class.new do
      extend test_module_ext
      include test_module_incl
      prepend test_module_prep
    end

    expected_methods = [
      test_class.instance_method(:incl),
      test_class.instance_method(:prep),
    ].sort_by(&:hash)
    assert_equal expected_methods, access(:@ivar, test_class)

    expected_methods = [
      test_class.singleton_class.instance_method(:ext),
    ].sort_by(&:hash)
    assert_equal expected_methods, access(:@ivar, test_class.singleton_class)
  end

  def test_all_calls_on
    test_class = Class.new do
      def drum
        :drum_n_bass_yo
      end

      def none
        @none
      end
    end

    another_test_class = Class.new do
      def boom
        :drum_n_bass_yo
      end
    end

    singleton_test_class = Class.new do
      class << self
        def single
          :drum_n_bass_yo
        end
      end
    end

    expected_methods = [
      test_class.instance_method(:drum),
      another_test_class.instance_method(:boom),
      singleton_test_class.singleton_class.instance_method(:single),
      self.class.instance_method(__method__)
    ].sort_by(&:hash)
    assert_equal expected_methods, calls_on(:drum_n_bass_yo)
  end

  def test_all_calls_on_accessors
    test_class = Class.new do
      attr_accessor :comrade_joseph_koba_stalin

      def fluffy
        :fluffy
      end
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
    ].sort_by(&:hash)
    assert_equal expected_methods, calls_on(:comrade_joseph_koba_stalin)

    expected_methods = [
      test_class.instance_method(:comrade_joseph_koba_stalin=),
      and_another_test_class.instance_method(:comrade_joseph_koba_stalin=),
      self.class.instance_method(__method__)
    ].sort_by(&:hash)
    assert_equal expected_methods, calls_on(:comrade_joseph_koba_stalin=)
  end

  def test_all_calls_on_simple_hash
    test_class = Class.new do
      def piggy
        {comrade_vladimir_lenin_ulyanov: 1, oinky: 2}
      end
    end

    another_test_class = Class.new do
      def biggy
        {
          bingo: [:bango, :bongo],
          bish: [:comrade_lavrentiy_pavlovich_beria, :bosh]
        }
      end
    end

    expected_methods = [
      test_class.instance_method(:piggy),
      self.class.instance_method(__method__)
    ].sort_by(&:hash)
    assert_equal expected_methods, calls_on(:comrade_vladimir_lenin_ulyanov)

    expected_methods = [
      another_test_class.instance_method(:biggy),
      self.class.instance_method(__method__)
    ].sort_by(&:hash)
    assert_equal expected_methods, calls_on(:comrade_lavrentiy_pavlovich_beria)
  end

  def test_all_calls_on_eval
    test_class = Class.new do
      def eval
        eval(':marshal_zhukov')
      end

      def nested_eval
        eval('eval(:marshal_zhukov)')
      end
    end

    expected_methods = [
      test_class.instance_method(:eval),
      test_class.instance_method(:nested_eval),
      self.class.instance_method(__method__)
    ].sort_by(&:hash)
    assert_equal expected_methods, calls_on(:marshal_zhukov)
  end

  def test_all_calls
    parent_class = Class.new do
      def bingo
        :woohoo
      end
    end

    test_class = Class.new(parent_class) do
      def bango
        :woohoo
      end

      def meh
        :meh
      end
    end

    child_class = Class.new(test_class) do
      def bongo
        :woohoo
      end
    end

    _another_test_class = Class.new do
      def bish
        :woohoo
      end
    end

    expected_methods = [
      test_class.instance_method(:bango),
      child_class.instance_method(:bongo),
    ].sort_by(&:hash)
    assert_equal expected_methods,
                 @sn.all_calls(on: :woohoo, from: test_class).sort_by(&:hash)
  end

  def test_all_classes_implementing
    test_class = Class.new do
      def bango_bango; end

      def foo; end
    end

    _test_module = Module.new do
      def bango_bango; end
    end

    assert_equal [test_class], @sn.all_classes_implementing(:bango_bango)
  end

  def test_all_modules_implementing
    _test_class = Class.new do
      def bingo_bingo; end

      def foo; end
    end

    test_module = Module.new do
      def bingo_bingo; end
    end

    assert_equal [test_module], @sn.all_modules_implementing(:bingo_bingo)
  end

  def test_all_implementors_of
    test_class = Class.new do
      def bongo_bongo; end

      def foo; end
    end

    test_module = Module.new do
      def bongo_bongo; end
    end

    assert_equal [test_module, test_class].sort_by(&:hash),
                 @sn.all_implementors_of(:bongo_bongo).sort_by(&:hash)
  end

  def test_all_local_calls
    test_module = Module.new do
      def bango; :bingo; end
    end

    parent_class = Class.new do
      def foo
        :bingo
      end
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
    ].sort_by(&:hash)
    assert_equal expected_methods,
                 @sn.all_local_calls(on: :bingo, of_class: test_class).sort_by(&:hash)
  end

  def test_all_methods_with_source
    test_module = Module.new do
      def bingo
        'dworkin_barimen'
      end
    end

    parent_class = Class.new do
      include test_module

      def bango
        dworkin_barimen
      end
    end

    test_class = Class.new(parent_class) do
      def bongo
        :dworkin_barimen
      end

      # dworkin_barimen
      def bish
        :bar
        :baz
      end
    end

    expected_methods = [
      test_module.instance_method(:bingo),
      parent_class.instance_method(:bango),
      test_class.instance_method(:bongo),
      test_class.instance_method(:bish),
      self.class.instance_method(__method__)
    ].sort_by(&:hash)
    actual_methods = @sn.all_methods_with_source(string: 'dworkin_barimen',
                                                 match_case: true).sort_by(&:hash)
    assert_equal expected_methods, actual_methods
    assert_equal expected_methods,
                 @sn.all_methods_with_source(string: 'DWORKIN_BARIMEN', match_case: false).
                   sort_by(&:hash)
  end

  def test_rb_and_c_methods
    rb_methods_cnt = @sn.all_rb_methods.count
    c_methods_cnt = @sn.all_c_methods.count

    assert_equal (rb_methods_cnt + c_methods_cnt), @sn.all_methods.count
  end
end
