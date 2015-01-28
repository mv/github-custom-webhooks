require 'sinatra'
require 'json'

get '/asana' do
  "This is Asana"
end


###
### Github issue -> Asana task+subtasks
###
post '/asana/issue/:workspace/:project' do

  # github stuff
  github = JSON.parse( check_request(request) )


  # asana stuff
  asana_api = 'https://app.asana.com/api/1.0'
  check_env

  w = asana_workspaces[ params[:workspace] ]
  p = asana_projects[   params[:project]   ]
  logger.info("asana [/workspace/project/]: [/#{w}/#{p}/]")


  # parent task
  ## POST /tasks
  ##
  data = %Q{-d "workspace=#{w}" -d "projects[0]=#{p}" -d "name=#{github['issue']['title']}" -d "notes=github_issue_number: #{github['issue']['number']}" }
  cmd  = "curl -s #{asana_api}/tasks #{data}"
  logger.info("asana task cmd: #{cmd}")

  parent_id = JSON.parse(`#{cmd} -u #{ENV['WEBHOOK_ASANA_KEY']}:`)['data']['id']
  logger.info("asana task id: [#{parent_id}]")


  # subtasks
  ## POST /tasks/:parent_id/subtasks
  ##
  subtasks = [ '01-Check', '02-Verify', '03-Test', '04-Done' ].reverse

  subtasks.each do |subtask|
    data = %Q{-d "name=#{subtask}" -d "notes=To do..." }
    cmd  = "curl -s #{asana_api}/tasks/#{parent_id}/subtasks #{data}"
    logger.info("asana subtask new [#{subtask}]: #{cmd}")

    subtask_id = JSON.parse(`#{cmd} -u #{ENV['WEBHOOK_ASANA_KEY']}:`)['data']['id']
    logger.info("asana subtask created: [#{subtask_id}]")
  end

end


def check_env
   if not ENV.has_key?('WEBHOOK_ASANA_KEY')
     logger.error('Undefined WEBHOOK_ASANA_KEY')
     return halt 500, "Undefined WEBHOOK_ASANA_KEY"
     false
   else
     logger.info('Found: WEBHOOK_ASANA_KEY')
     true
   end
end

def asana_workspaces
  asana_api = 'https://app.asana.com/api/1.0'
  res = `curl -s -u #{ENV['WEBHOOK_ASANA_KEY']}: #{asana_api}/workspaces`
  var = {}

  JSON.parse(res)['data'].each do |d|
    # TODO: lowercase + remove spaces + remove 'acentos'
    var[ d['name'].downcase.gsub(" ", "-") ] = d['id']
  end
  var
end

## Projects
## --------
## From THIS:
## {
##     "data" => [
##         [0] {
##               "id" => 25021197661019,
##             "name" => "MvWay"
##         },
##         [1] {
##               "id" => 498346170860,
##             "name" => "Personal Projects"
##         }
##     ]
## }
##
## To THAT:
##
## var = {
##   "mvway" => 25021197661019,
##   "personal-projects" => 498346170860
## }

def asana_projects
  asana_api = 'https://app.asana.com/api/1.0'
  res = `curl -s -u #{ENV['WEBHOOK_ASANA_KEY']}: #{asana_api}/projects`
  var = {}

  JSON.parse(res)['data'].each do |d|
    var[ d['name'].downcase.gsub(" ", "-") ] = d['id']
  end
  var
end


