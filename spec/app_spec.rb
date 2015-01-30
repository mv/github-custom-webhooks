# spec/app_spec.rb

require File.expand_path '../spec_helper.rb', __FILE__

describe "Sinatra: Webhooks" do

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

