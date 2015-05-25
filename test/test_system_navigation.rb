require_relative 'helper'

class TestSystemNavigation < Minitest::Test
  module Helper
    def access(ivar, klass)
      @sn.all_accesses(to: ivar, from: klass).sort_by(&:hash)
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

  def test_all_senders
    test_module = Module.new do
      def bingo
        twerkin_barimen
      end
    end

    _cool_class = Class.new do
      def twerkin_barimen
        :oh_yeah
      end
    end

    test_class = Class.new do
      def initialize
        @cool_object = cool_class.new
      end

      def bango
        self.twerkin_barimen
      end

      def foo
        @cool_object.twerkin_barimen
      end
    end

    another_module = Module.new do
      def bongo
        twerkin_barimen(1)
      end

      def self.evaling
        eval(%|eval('boom_boom(:foo, [1,2,3]) { twerkin_barimen(Object.new) }')|)
      end
    end

    another_class = Class.new do
      def bish
        twerkin_barimen(1, 2)
      end

      def bash
        twerkin_barimen(1) { }
      end

      def bosh
        foobarson(1) { twerkin_barimen }
      end
    end

    expected_methods = [
      test_module.instance_method(:bingo),
      test_class.instance_method(:bango),
      another_module.instance_method(:bongo),
      another_class.instance_method(:bish),
      another_class.instance_method(:bash),
      another_class.instance_method(:bosh),
      test_class.instance_method(:foo),
      another_module.singleton_class.instance_method(:evaling),
      self.class.instance_method(__method__)
    ].sort_by(&:hash)

    actual_methods = @sn.all_senders(of: :twerkin_barimen).sort_by(&:hash)
    assert_equal expected_methods, actual_methods
  end

  def test_all_stores
    test_class = Class.new do
      def bingo
        @cool_object = 1
      end

      def bango
        @cool_object
      end

      def bongo
        @cool_object.girls_love_me
      end

      def bish
        @cool_object += 1
      end
    end

    expected_methods = [
      test_class.instance_method(:bingo),
      test_class.instance_method(:bish)
    ].sort_by(&:hash)

    actual_methods = @sn.all_stores(into: :@cool_object, from: test_class).sort_by(&:hash)
    assert_equal expected_methods, actual_methods
  end
end
