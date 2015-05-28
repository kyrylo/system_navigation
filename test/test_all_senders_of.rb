require_relative 'helper'

class TestSystemNavigationAllSendersOf < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_senders_of
    test_module = Module.new do
      def test_all_senders_of
        test_all_senders_of
      end
    end

    expected = [
      test_module.instance_method(:test_all_senders_of),
      self.class.instance_method(:test_all_senders_of)
    ]

    assert_equal expected, @sn.all_senders_of(:test_all_senders_of)
  end

  def test_all_senders_of_ivar
    test_class = Class.new do
      def test_all_senders_of_ivar
        @test_all_senders_of_ivar.test_all_senders_of_ivar
      end
    end

    expected = [
      test_class.instance_method(:test_all_senders_of_ivar),
      self.class.instance_method(:test_all_senders_of_ivar)
    ]

    assert_equal expected, @sn.all_senders_of(:test_all_senders_of_ivar)
  end

  def test_all_senders_of_self
    test_class = Class.new do
      def test_all_senders_of_self
        self.test_all_senders_of_self
      end
    end

    expected = [
      test_class.instance_method(:test_all_senders_of_self),
      self.class.instance_method(:test_all_senders_of_self)
    ]

    assert_equal expected, @sn.all_senders_of(:test_all_senders_of_self)
  end

  def test_all_senders_of_args
    test_class = Class.new do
      def test_all_senders_of_args
        test_all_senders_of_args(1, 2)
      end
    end

    expected = [
      test_class.instance_method(:test_all_senders_of_args),
      self.class.instance_method(:test_all_senders_of_args)
    ]

    assert_equal expected, @sn.all_senders_of(:test_all_senders_of_args)
  end

  def test_all_senders_of_eval
    test_class = Class.new do
      def test_all_senders_of_eval
        eval(%|eval('boom(:foo, [1,2,3]) { test_all_senders_of_eval(Object.new) }')|)
      end
    end

    expected = [
      test_class.instance_method(:test_all_senders_of_eval),
      self.class.instance_method(:test_all_senders_of_eval)
    ]

    assert_equal expected, @sn.all_senders_of(:test_all_senders_of_eval)
  end

  def test_all_senders_of_block_arg
    test_class = Class.new do
      def test_all_senders_of_block_arg
        test_all_senders_of_block_arg(1) { }
      end
    end

    expected = [
      test_class.instance_method(:test_all_senders_of_block_arg),
      self.class.instance_method(:test_all_senders_of_block_arg)
    ]

    assert_equal expected, @sn.all_senders_of(:test_all_senders_of_block_arg)
  end

  def test_all_senders_of_block_inside
    test_class = Class.new do
      def test_all_senders_of_block_inside
        boom(1) { test_all_senders_of_block_inside }
      end
    end

    expected = [
      test_class.instance_method(:test_all_senders_of_block_inside),
      self.class.instance_method(:test_all_senders_of_block_inside)
    ]

    assert_equal expected, @sn.all_senders_of(:test_all_senders_of_block_inside)
  end
end
