require 'sinatra'
require 'json'
require 'pp'

require_relative 'lib/asana'
require_relative 'lib/github'

get '/' do
  "Test."
end

get '/webhook' do
  "Hello Webhook."
end

post '/github/check' do
  g = GitHub::Check.new(request).payload
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

