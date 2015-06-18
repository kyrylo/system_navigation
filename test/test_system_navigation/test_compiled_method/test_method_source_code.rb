require_relative '../../helper'

class TestCompiledMethodMethodSourceCode < Minitest::Test
  def test_source
    method = Sample.instance_method(:c_method)
    assert_empty SystemNavigation::CompiledMethod.new(method).source
  end
end
