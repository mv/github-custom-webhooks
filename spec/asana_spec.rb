# spec/app_spec.rb

require File.expand_path '../spec_helper.rb', __FILE__

describe "Asana API" do

  it "should create a new asana object" do
    asana_task = Asana::Task.new( 'w1','p1' )
    expect(asana_task).not_to be_nil
  end

  it "should check if ASANA_KEY is defined" do
    ENV['WEBHOOK_ASANA_KEY'] = 'asana_key'
    asana_task = Asana::Task.new( 'w1','p1' )
    expect(asana_task.check_key).to be true
  end

  it "should check if ASANA_KEY is not defined" do
    ENV.delete('WEBHOOK_ASANA_KEY')
    asana_task = Asana::Task.new( 'w1','p1' )
    expect(asana_task.check_key).to be false
  end

  if ENV.has_key?('WEBHOOK_ASANA_KEY')

    key = ENV['WEBHOOK_ASANA_KEY']
    w   = ENV['WEBHOOK_ASANA_WORKSPACE']
    p   = ENV['WEBHOOK_ASANA_PROJECT']

    it "should find Asana workdspaces for key ...#{key[-4..-1]}" do
      ENV['WEBHOOK_ASANA_KEY'] = key
      asana_task = Asana::Task.new(w,p)
      res = asana_task.get_workspaces
      expect(res.keys.count).to be > 0
    end

    it "should find Asana projects for key ...#{key[-4..-1]}" do
      ENV['WEBHOOK_ASANA_KEY'] = key
      asana_task = Asana::Task.new(w,p)
      res = asana_task.get_projects
      expect(res.keys.count).to be > 0
    end

    describe "Asana API: Tasks" do

      asana_task = ''
      task_id    = ''

      it "should create new task for key ...#{key[-4..-1]}" do
        ENV['WEBHOOK_ASANA_KEY'] = key
        asana_task = Asana::Task.new(w,p)
        task_id    = asana_task.create( {'name' => 'rspec', 'number' => '-99'} )

        expect(task_id).not_to be nil
      end

      it "should create subtasks for key ...#{key[-4..-1]}" do
        res = asana_task.create_subtasks(task_id)
        expect(res).not_to be nil
      end

      it "should delete task and subtasks" do
        res = asana_task.delete_task(task_id)
        expect(res).to eq('{"data":{}}')
      end

    end # describe

  end # if
end

describe "Webhooks - /asana" do

  it "should GET '/asana'" do
    get '/asana'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('This is Asana.')
  end

  it "should define WEBHOOK_ASANA_KEY environment variable" do
    expect(ENV.has_key?('WEBHOOK_ASANA_KEY')).to be true
  end

  if ENV.has_key?('WEBHOOK_ASANA_KEY')

    key = ENV['WEBHOOK_ASANA_KEY']
    w   = ENV['WEBHOOK_ASANA_WORKSPACE']
    p   = ENV['WEBHOOK_ASANA_PROJECT']

    task_id = ''

    it "should POST to /asana/:workspace/:project" do
      ENV['WEBHOOK_ASANA_KEY'] = key
      ENV['WEBHOOK_GITHUB_SECRET_TOKEN'] = 'one-secret-token'
      params = {'issue' => {"title" => "POST test", "number" => "98"}}.to_json
      env    = {"CONTENT_TYPE" => "application/json" , "HTTP_X_HUB_SIGNATURE" => "sha1=2b6f0ef19ae7440c3ffa0404b8113ae97807fa90"}

      post "/asana/issue/#{w}/#{p}", params, env
      expect(last_response).to be_ok
      expect(last_response.body).to match(/New task: \d+/)

      task_id = last_response.body.match(/\d+/).to_s
    end

    it "should POST to /asana/:workspace/:project/delete/:task_id" do
      ENV['WEBHOOK_ASANA_KEY'] = key

      post "/asana/issue/#{w}/#{p}/delete/#{task_id}"
      expect(last_response).to be_ok
      expect(last_response.body).to eq('{"data":{}}')
    end

  end # if
end

