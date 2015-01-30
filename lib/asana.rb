require 'sinatra'
require 'json'

###
### Github issue -> Asana task+subtasks
###
module Asana

  class Task

    attr_reader :task_id

    ASANA_API = 'https://app.asana.com/api/1.0'

    def initialize(workspace, project)
      @workspace = workspace
      @project   = project
    end

    def create(issue)
      # tasks
      ## POST /tasks
      ##
      w = get_workspaces[ @workspace ]
      p = get_projects[   @project   ]

      data = %Q{-d "workspace=#{w}" -d "projects[0]=#{p}" -d "name=#{issue['name']}" -d "notes=github_issue_number: #{issue['number']}" }
      cmd  = "curl -s #{ASANA_API}/tasks #{data}"
      #     logger.info("asana task cmd: #{cmd}")

      @task_id = JSON.parse(`#{cmd} -u #{ENV['WEBHOOK_ASANA_KEY']}:`)['data']['id']
      #     logger.info("asana task id: [#{@task_id}]")

    end

    def create_subtasks(parent_id)
      # subtasks
      ## POST /tasks/:parent_id/subtasks
      ##
      subtasks = [ '01-Check', '02-Verify', '03-Test', '04-Done' ].reverse
      result = {}

      subtasks.each do |subtask|
        data = %Q{-d "name=#{subtask}" -d "notes=To do..." }
        cmd  = "curl -s #{ASANA_API}/tasks/#{parent_id}/subtasks #{data}"
        #       logger.info("asana subtask new [#{subtask}]: #{cmd}")

        subtask_id = JSON.parse(`#{cmd} -u #{ENV['WEBHOOK_ASANA_KEY']}:`)['data']['id']
        result[subtask] = subtask_id
        #       logger.info("asana subtask created: [#{subtask_id}]")
      end
      result.to_json
    end


    def check_key
      if ENV.has_key?('WEBHOOK_ASANA_KEY')
        true
      else
        false
      end
    end


    ## Projects
    ## --------
    ## From json:
    ## {
    ##     "data" => [
    ##         [0] {
    ##               "id" => 1234,
    ##             "name" => "Test"
    ##         },
    ##         [1] {
    ##               "id" => 7890,
    ##             "name" => "Personal Projects"
    ##         }
    ##     ]
    ## }
    ##
    ## To a lookup hash
    ## var = {
    ##   "test" => 1234,
    ##   "personal-projects" => 7890
    ## }

    def get_projects
      res = `curl -s -u #{ENV['WEBHOOK_ASANA_KEY']}: #{ASANA_API}/projects`

      # lookup hash by name
      var = {}
      JSON.parse(res)['data'].each { |d| var[ d['name'].downcase.gsub(" ", "-") ] = d['id'] }
      var
    end

    def get_workspaces
      res = `curl -s -u #{ENV['WEBHOOK_ASANA_KEY']}: #{ASANA_API}/workspaces`

      # lookup hash by name (again)
      var = {}
      JSON.parse(res)['data'].each { |d| var[ d['name'].downcase.gsub(" ", "-") ] = d['id'] }
      var
    end

  end # class

end # module

