require 'doorbell'
require 'test_helper'

class DoorbellTest < ActiveSupport::TestCase
  test 'setup block yields self' do
    Doorbell.setup do |config|
      assert_equal Doorbell, config
    end
  end
end