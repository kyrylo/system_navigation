require_relative '../helper'

class TestSystemNavigationAllSentMessages < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_sent_messages
    _test_class = Class.new do
      def test_all_sent_messagses
        self.test_all_sent_messages
      end
    end

    assert @sn.all_sent_messages.include?(:test_all_sent_messages)
  end
end
