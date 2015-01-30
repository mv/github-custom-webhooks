#
# Marcus Vinicius Ferreira
# 2015-01

desc "RSpec tests."
task :test do
  system "rspec --color --format doc"
end

namespace :api do

  desc "Start API locally"
  task :run do
    if ENV.has_key?('WEBHOOK_ASANA_KEY')
      system "ruby app.rb"
    else
      puts "WEBHOOK_ASANA_KEY is not defined..."
    end
  end

  desc "Tunnel API through ngrok"
  task :ngrok do
    system "ngrok 4567"
  end

end

#
# Extras
#
task :default do
  printf "#\n# Tasks\n#\n"
  system "rake --tasks"
  puts
end

#
# vim:ft=ruby:foldlevel=9:foldmethod=marker:foldmarker={,}:
#

