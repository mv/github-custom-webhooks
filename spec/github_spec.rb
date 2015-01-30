# spec/app_spec.rb

require File.expand_path '../spec_helper.rb', __FILE__

describe "Sinatra: Webhooks - /github/check" do

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

