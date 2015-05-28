require_relative '../helper'

class TestSystemNavigationAllModulesImplementing < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_modules_implementing
    _test_class = Class.new do
      def test_all_modules_implementing
      end
    end

    test_module = Module.new do
      def test_all_modules_implementing
      end
    end

    expected  = [
      test_module
    ]

    assert_equal expected,
                 @sn.all_modules_implementing(:test_all_modules_implementing)
  end

  def test_all_modules_implementing_class_method
    _test_class = Class.new do
      def self.test_all_modules_implementing_class_method
      end
    end

    test_module = Module.new do
      def self.test_all_modules_implementing_class_method
      end
    end

    expected = [
      test_module
    ]

    assert_equal expected,
                 @sn.all_modules_implementing(:test_all_modules_implementing_class_method)
  end
end
