require_relative 'helper'

class TestSystemNavigationAllMethods < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_methods
    methods = @sn.all_methods

    refute_empty @sn.all_methods

    methods.each do |method|
      assert_instance_of UnboundMethod, method
    end
  end
end
