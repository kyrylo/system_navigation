require_relative '../helper'

class TestSystemNavigationAllImplementorsOf < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_implementors_of
    test_class = Class.new do
      def test_all_implementors_of
      end
    end

    test_module = Module.new do
      def test_all_implementors_of
      end
    end

    expected = [
      test_class,
      test_module,
      self.class
    ]

    assert_equal expected, @sn.all_implementors_of(:test_all_implementors_of)
  end

  def test_all_implementors_of_class_methods
    test_class = Class.new do
      def self.test_all_implementors_of_class_methods
      end
    end

    test_module = Module.new do
      def self.test_all_implementors_of_class_methods
      end
    end

    expected = [
      test_class,
      test_module,
      self.class
    ]

    assert_equal expected,
                 @sn.all_implementors_of(:test_all_implementors_of_class_methods)

  end
end
