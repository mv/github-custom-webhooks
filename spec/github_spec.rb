# spec/app_spec.rb

require File.expand_path '../spec_helper.rb', __FILE__

describe "Webhooks - /github/check" do

  it "should define WEBHOOK_GITHUB_SECRET_TOKEN environment variable" do
    expect(ENV.has_key?('WEBHOOK_GITHUB_SECRET_TOKEN')).to be true
  end

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
    params = {'issue' => {"title" => "POST test", "number" => "98"}}.to_json
    env    = {"CONTENT_TYPE" => "application/json" , "HTTP_X_HUB_SIGNATURE" => "sha1=2b6f0ef19ae7440c3ffa0404b8113ae97807fa90"}

    post '/github/check', params, env
    expect(last_response).to be_ok
    expect(last_response.body).to eq('["issue", {"title"=>"POST test", "number"=>"98"}]')
  end

end

