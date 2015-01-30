require 'sinatra'
require 'json'

module GitHub

  class Check

    attr_reader :request, :signature, :my_signature

    def initialize(request)
      @request   = request
      @payload   = request.body.read
      @signature = request.env['HTTP_X_HUB_SIGNATURE'] || 'no-signature' # if request.env.has_key?('HTTP_X_HUB_SIGNATURE') || 'no-signature'
    end

    def is_signed?
      @request.env.has_key?('HTTP_X_HUB_SIGNATURE') ? true : false
    end

    def is_not_signed?
      @request.env.has_key?('HTTP_X_HUB_SIGNATURE') ? false : true
    end

    def payload
      if is_not_signed?
        'Payload-is-not-signed'
      elsif valid?
        JSON.parse( @payload )
      else
        'Payload-is-not-valid.'
      end
    end

    ###
    ### Ref: https://developer.github.com/webhooks/securing/
    ###
    def valid?
      if not ENV.has_key?('WEBHOOK_GITHUB_SECRET_TOKEN')
        false
      end

      @my_signature = 'sha1=' + OpenSSL::HMAC.hexdigest( OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_GITHUB_SECRET_TOKEN'], @payload )
#     puts "my_signature: #{@my_signature}"

      if Rack::Utils.secure_compare(@my_signature, @signature)
        true
      else
        false
      end
    end

  end # class

end # module

