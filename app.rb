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

post '/echo' do
  request.body.read.to_json.pretty_inspect
end

post '/webhook' do
  pp "Receiving Webhook #{params[:webhookId]}"
end

