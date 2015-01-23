require 'sinatra'
require 'json'
require 'pp'

get '/' do
  "Test."
end

get '/webhook' do
  "Hello Webhook"
end

post '/request' do
  response = <<-HTML
<html><pre>

request.body
------------
#{JSON.parse(request.body.read).pretty_inspect}
</pre></html>

request.env
-----------
#{request.env.pretty_inspect}

  HTML
end

post '/check' do
  check_request(request)
end

post '/webhook' do
  pp "Receiving Webhook #{params[:webhookId]}"
end


###
### Ref: https://developer.github.com/webhooks/securing/
###
def check_request(request)
  request.body.rewind
  payload = request.body.read
  verify_signature(payload)
  payload
end

def verify_signature(payload)

  if not request.env.has_key?('HTTP_X_HUB_SIGNATURE')
    logger.warn("X_HUB_SIGNATURE is not defined. Skipping...")
    return
  end

  signature = 'sha1=' + OpenSSL::HMAC.hexdigest( OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_SECRET_TOKEN'], payload )

  if Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
    logger.info("Signature OK: #{signature}")
  else
    logger.error("Signature error: #{signature}. Expected #{request.env['HTTP_X_HUB_SIGNATURE']}")
    return halt 500, "Signatures didn't match!"
  end
end

