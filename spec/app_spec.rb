# spec/app_spec.rb

require File.expand_path '../spec_helper.rb', __FILE__

describe "Webhooks - Home" do

  it "should GET '/'" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Test.')
  end

  it "should GET '/webhook'" do
    get '/webhook'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Hello Webhook.')
  end

end

