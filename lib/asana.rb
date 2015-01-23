require 'sinatra'
require 'json'

asana_api  = 'https://app.asana.com/api/1.0'

get '/asana' do
  "This is Asana"
end


post '/asana/:workspace/:project' do

  # github stuff
  github = JSON.parse( check_request(request) )

  # asana stuff
  check_env
  w = asana_workspaces[ params[:workspace] ]
  p = asana_projects[ params[:project] ]
  logger.info("asana destination: /#{w}/#{p}")

  data = %Q{ -d "workspace=#{w}" -d "projects[0]=#{p}" -d "name=#{github['issue']['title']}" -d "notes=#{github['issue']['body']}" }
  cmd  = "curl -s -u #{ENV['WEBHOOK_ASANA_KEY']}: #{data} https://app.asana.com/api/1.0/tasks"
  logger.info("asana cmd: #{cmd}")

  `#{cmd}`

end


def check_env
   if not ENV.has_key?('WEBHOOK_ASANA_KEY')
     logger.error('Undefined WEBHOOK_ASANA_KEY')
     return halt 500, "Undefined WEBHOOK_ASANA_KEY"
     false
   else
     true
   end
end

def asana_workspaces
  res = `curl -s -u #{ENV['WEBHOOK_ASANA_KEY']}: https://app.asana.com/api/1.0/workspaces`
  var = {}

  JSON.parse(res)['data'].each do |d|
    # TODO: lowercase + remove spaces + remove 'acentos'
    var[ d['name'].downcase ] = d['id']
  end
  var
end

def asana_projects
  res = `curl -s -u #{ENV['WEBHOOK_ASANA_KEY']}: https://app.asana.com/api/1.0/projects`
  var = {}

  JSON.parse(res)['data'].each do |d|
    var[ d['name'].downcase ] = d['id']
  end
  var
end

