require_relative '../helper'

class TestSystemNavigationAllRbMethods < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_rb_methods
    assert @sn.all_rb_methods.include?(Sample.instance_method(:rb_method))
  end
end
