require_relative 'helper'

class TestSystemNavigationAllImplementorsOf < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_implementors_of
    test_class = Class.new do
      def bongo_bongo; end

      def foo; end
    end

    test_module = Module.new do
      def bongo_bongo; end
    end

    assert_equal [test_module, test_class], @sn.all_implementors_of(:bongo_bongo)
  end
end
