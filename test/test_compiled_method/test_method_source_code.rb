require_relative '../helper'

class TestCompiledMethodMethodSourceCode < Minitest::Test
  def test_source
    assert_raises(SystemNavigation::MethodSourceCode::SourceNotFoundError) do
      method = Sample.instance_method(:c_method)
      SystemNavigation::CompiledMethod.new(method).source
    end
  end
end
