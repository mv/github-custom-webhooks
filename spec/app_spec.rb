# spec/app_spec.rb

require File.expand_path '../spec_helper.rb', __FILE__

describe "Sinatra Application - Webhooks" do

  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Test.')
  end

  it "/webhook entrypoint" do
    get '/webhook'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Hello Webhook.')
  end

end

describe "Sinatra Application - Github Webhooks" do

  it "should POST to /github/check " do
    params = {:type => "issue"}.to_json

    post '/github/check', params
    expect(last_response).to be_ok
  end

  it "should POST to /github/check with no-signature" do
    params = {:type => "issue"}.to_json

    post '/github/check', params
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Payload-is-not-signed')
  end

  it "should POST to /github/check with a invalid signature" do
    ENV['WEBHOOK_GITHUB_SECRET_TOKEN'] = 'one-secret-token'
    params = {:type => "issue"}.to_json
    env    = {"CONTENT_TYPE" => "application/json" , "HTTP_X_HUB_SIGNATURE" => "bogus-signature"}

    post '/github/check', params, env
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Payload-is-not-valid.')
  end

  it "should POST to /github/check with a valid signature" do
    ENV['WEBHOOK_GITHUB_SECRET_TOKEN'] = 'one-secret-token'
    params = {:type => "issue"}.to_json
    env    = {"CONTENT_TYPE" => "application/json" , "HTTP_X_HUB_SIGNATURE" => "sha1=5a8ea7c7959974a8f7184abd1d58c29973d815be"}

    post '/github/check', params, env
    expect(last_response).to be_ok
    expect(last_response.body).to eq('["type", "issue"]')
  end

end

