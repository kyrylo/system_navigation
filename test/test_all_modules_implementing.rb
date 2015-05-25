require_relative 'helper'

class TestSystemNavigationAllModulesImplementing < Minitest::Test
  def setup
    @sn = SystemNavigation.default
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
end
