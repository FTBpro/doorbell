require 'jwt'

module Doorbell
  class AuthService
    attr_reader :token
    attr_reader :payload

    def initialize(token: nil, verify_options: {})
        @payload, _ = decode_token token, verify_options
        @token = token
    end
    
    def entity_for(entity_class)
      if entity_class.respond_to? :from_token_payload
        entity_class.from_token_payload @payload
      else
        entity_class.find @payload['sub']
      end
    end

    private

    def decode_token(token, verify_options)
      JWT.decode token.to_s, decode_key, true, system_verify_options.merge(verify_options)
    end

    def secret_key
      Doorbell.token_secret_signature_key.call
    end

    def decode_key
      Doorbell.token_public_key || secret_key
    end

    def system_verify_options
      verify_claims.merge({
        algorithm: Doorbell.token_signature_algorithm
      })
    end

    def claims
      _claims = {}
      _claims[:exp] = token_lifetime if verify_lifetime?
      _claims[:aud] = token_audience if verify_audience?
      _claims
    end

    def token_lifetime
      Doorbell.token_lifetime.from_now.to_i if verify_lifetime?
    end

    def verify_lifetime?
      !Doorbell.token_lifetime.nil?
    end

    def verify_claims
      {
        aud: token_audience,
        verify_aud: verify_audience?,
        verify_expiration: verify_lifetime?
      }
    end

    def token_audience
      verify_audience? && Doorbell.token_audience.call
    end

    def verify_audience?
      Doorbell.token_audience.present?
    end
  end
end
