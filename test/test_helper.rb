require 'doorbell'
require 'simplecov'
require 'active_support/all'
require 'minitest/autorun'
require 'minitest/reporters'

reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

SimpleCov.start

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new



module Doorbell
  class MyCustomException < StandardError
  end
end

# Make sure doorbell global configuration is reset before every tests
# to avoid order dependent failures.
class ActiveSupport::TestCase
  setup :reset_doorbell_configuration

  private

  def reset_doorbell_configuration
    Doorbell.token_signature_algorithm = 'HS256'
    Doorbell.token_secret_signature_key = -> { "secret" }
    Doorbell.token_public_key = nil
    Doorbell.token_audience = nil
    Doorbell.token_lifetime = 1.day
  end
end
