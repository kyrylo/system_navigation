require_relative 'helper'

class TestSystemNavigationAllClassesImplementing < Minitest::Test
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
end
