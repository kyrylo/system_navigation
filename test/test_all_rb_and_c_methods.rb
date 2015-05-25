require_relative 'helper'

class TestSystemNavigation < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_rb_and_c_methods
    rb_methods_cnt = @sn.all_rb_methods.count
    c_methods_cnt = @sn.all_c_methods.count

    assert_equal (rb_methods_cnt + c_methods_cnt), @sn.all_methods.count
  end
end
