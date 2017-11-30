require 'test_helper'
require 'jwt'
require 'timecop'

module Doorbell
  class DummyUser
  end

  class Request
    attr_reader :headers
    def initialize(headers:)
      @headers = headers
    end
  end
  class DummyClass
    include Doorbell::Authenticable
        
    attr_reader :params, :request

    def initialize(params:, request:)
      @params = params
      @request = request
    end
        
    def authenticate
      authenticate_for DummyUser   
    end
  end
  
  class AuthenticableTest < ActiveSupport::TestCase
    
    test 'throw exception when token empty' do
        dummy = Doorbell::DummyClass.new(params: { token: nil }, request: Request.new(headers:{ 'Authorization' => nil }))
        assert_raises(AuthenticationError) {
            dummy.authenticate
        }
    end

    test 'throw exception when token wrong' do
        dummy = Doorbell::DummyClass.new(params: { token: nil }, request: Request.new(headers:{ 'Authorization' => 'Bearer aud.exp' }))
        assert_raises(AuthenticationError) {
            dummy.authenticate
        }
    end

    test 'throw exception when token is expired' do
        token =
        JWT.encode(
          {sub: '1', exp: Doorbell.token_lifetime},
          Doorbell.token_secret_signature_key.call,
          Doorbell.token_signature_algorithm
        )
        dummy = Doorbell::DummyClass.new(params: { token: nil }, request: Request.new(headers:{ 'Authorization' => token }))
        Timecop.travel(25.hours.from_now) do
        assert_raises(AuthenticationError) {
            dummy.authenticate
        }
    end
    
  end
  end
end