require_relative '../helper'

class TestSystemNavigationAllClassesImplementing < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_classes_implementing
    test_class = Class.new do
      def test_all_classes_implementing
      end
    end

    _test_module = Module.new do
      def test_all_classes_implementing
      end
    end

    expected = [
      test_class,
      self.class
    ]

    assert_equal expected,
                 @sn.all_classes_implementing(:test_all_classes_implementing)
  end

  def test_all_classes_implementing_class_method
    test_class = Class.new do
      def self.test_all_classes_implementing_class_method
      end
    end

    _test_module = Module.new do
      def self.test_all_classes_implementing_class_method
      end
    end

    expected = [
      test_class,
      self.class
    ]

    assert_equal expected,
                 @sn.all_classes_implementing(:test_all_classes_implementing_class_method)
  end
end
