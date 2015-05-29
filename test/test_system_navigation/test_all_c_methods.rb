require_relative '../helper'

class TestSystemNavigationAllCMethods < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_c_methods
    assert @sn.all_c_methods.include?(Sample.instance_method(:c_method))
  end
end
