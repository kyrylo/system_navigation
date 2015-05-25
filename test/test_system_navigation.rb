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
