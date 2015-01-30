require 'sinatra'
require 'json'
require 'pp'

require_relative 'lib/asana'
require_relative 'lib/github'

set :logging, true

get '/' do
  "Test."
end

get '/webhook' do
  "Hello Webhook."
end

post '/github/check' do
  github = GitHub::Check.new(request)
  github.payload
end

get '/asana' do
  "This is Asana."
end

post '/asana/issue/:workspace/:project' do

  # github: check current 'request' that was triggered by Github project
  github = GitHub::Check.new(request).payload

  # asana: if payload is a 'issue', create task/subtasks
  asana_task = Asana::Task.new(params[:workspace], params[:project])

  new_issue = {
    'name'   => github['issue']['title'],
    'number' => github['issue']['number']
  }

  parent_id  = asana_task.create(new_issue)

  # optional(?)
  asana_task.create_subtasks(parent_id)

  # Polite result
  "New task: #{parent_id}"

# error do
#   if asana_task.check_key
#     'Asana: Sorry there was a nasty error - ' + env['sinatra.error'].name
#   else
#     'Asana UNAUTHORIZED: API Key is not defined.'
#   end
# end # error
end

post '/asana/issue/:workspace/:project/delete/:task_id' do

  asana_task = Asana::Task.new(params[:workspace], params[:project])

  asana_task.delete_task(params[:task_id])

end


