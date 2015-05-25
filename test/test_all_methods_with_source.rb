require_relative 'helper'

class TestSystemNavigationAllMethodsWithSource < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_methods_with_source
    test_module = Module.new do
      def bingo; 'dworkin_barimen'; end
    end

    parent_class = Class.new do
      include test_module

      def bango; dworkin_barimen; end
    end

    test_class = Class.new(parent_class) do
      def bongo; :dworkin_barimen; end

      # dworkin_barimen
      def bish; :bar && :baz; end
    end

    expected = [
      test_module.instance_method(:bingo),
      parent_class.instance_method(:bango),
      test_class.instance_method(:bongo),
      test_class.instance_method(:bish),
      self.class.instance_method(__method__)
    ]
    assert_equal expected,
                 @sn.all_methods_with_source(string: 'dworkin_barimen',
                                             match_case: true)
    assert_equal expected,
                 @sn.all_methods_with_source(string: 'DWORKIN_BARIMEN',
                                             match_case: false)

  end
end
