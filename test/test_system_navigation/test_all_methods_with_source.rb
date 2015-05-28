require_relative '../helper'

class TestSystemNavigationAllMethodsWithSource < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_methods_with_source_match_case_true
    test_class = Class.new do
      def test_all_methods_with_source_match_case_true
        :test_all_methods_with_source_match_case_true_sym
      end
    end

    _another_class = Module.new do
      def test_all_methods_with_source_match_case_true
        :TEST_ALL_METHODS_WITH_SOURCE_MATCH_CASE_TRUE_SYM
      end
    end

    expected = [
      test_class.instance_method(:test_all_methods_with_source_match_case_true),
      self.class.instance_method(__method__)
    ]

    string = 'test_all_methods_with_source_match_case_true_sym'

    assert_equal expected,
                 @sn.all_methods_with_source(string: string,
                                             match_case: true)
  end

  def test_all_methods_with_source_match_case_false
    test_class = Class.new do
      def test_all_methods_with_source_match_case_false
        :test_all_methods_with_source_match_case_false_sym
      end
    end

    another_class = Module.new do
      def test_all_methods_with_source_match_case_false
        :TEST_ALL_METHODS_WITH_SOURCE_MATCH_CASE_FALSE_SYM
      end
    end

    string = 'test_all_methods_with_source_match_case_false_sym'

    expected = [
      test_class.instance_method(:test_all_methods_with_source_match_case_false),
      another_class.instance_method(:test_all_methods_with_source_match_case_false),
      self.class.instance_method(__method__)
    ]

    assert_equal expected,
                 @sn.all_methods_with_source(string: string,
                                             match_case: false)
  end

  def test_all_methods_with_source_match_comment
    test_class = Class.new do
      # test_all_methods_with_source_comment_comment
      def test_all_methods_with_source_comment
      end
    end

    expected = [
      test_class.instance_method(:test_all_methods_with_source_comment),
      self.class.instance_method(__method__)
    ]

    string = 'test_all_methods_with_source_comment_comment'
    assert_equal expected, @sn.all_methods_with_source(string: string)
  end
end
