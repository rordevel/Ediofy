require 'mina/bundler'

namespace :resque do
  desc 'Stops the resque worker'
  task :stop, :environment do
    if "/home/ubuntu/ediofy/shared/tmp/gmep_production_store_asset_worker.pid"
      command %[echo "-----> Stopping resque"]
      command 'sudo monit stop resque'
      command 'sleep 5'
    end
  end

  desc 'Starts the resque worker'
  task :start, :environment do
    command %[echo "-----> Starting resque"]
    command 'sudo monit start resque'
  end

  desc "Restarts the resque worker"
  task :restart, :environment do
    command %[echo "-----> Restarting resque"]
    command 'sudo monit stop resque'
    command 'sleep 5' # Give monit a short period between stop & start requests, otherwise it refuses to process the start
    command 'sudo monit start resque'
  end
end

# namespace :resque do
#   set :rpush_command, -> { "cd #{fetch(:current_path)} && bundle exec rpush" }
#
#   desc 'Start rpush'
#   task start: :environment do
#     command %[echo '-----> Starting rpush']
#     command "#{fetch(:rpush_command)} start -e #{fetch(:rails_env)}"
#   end
#
#   desc 'Stop rpush'
#   task stop: :environment do
#     command %[echo '-----> Stopping rpush']
#     # command "kill -9 $(ps ax | grep rpush | fgrep -v grep | awk '{ print $1 }')"
#     # command "if $(ps ax | grep rpush | fgrep -v grep | awk '{ print $1 }') &> /dev/null; then kill -9 $(ps ax | grep rpush | fgrep -v grep | awk '{ print $1 }') ; fi"
#     command "APP_ID=$(ps ax | grep rpush | fgrep -v grep | awk '{ print $1 }')
#               if [ -n \"${APP_ID}\" ]; then
#                 echo \"Stopping instance $APP_ID\"
#                 kill -9 $APP_ID
#               fi"
#   end
#
#   desc 'Restart rpush'
#   task restart: :environment do
#     command %[echo '-----> Restarting rpush']
#     command "#{fetch(:rpush_command)} stop -e #{fetch(:rails_env)}; #{fetch(:rpush_command)} start -e #{fetch(:rails_env)}"
#   end
#
#   desc 'Push pending notifications'
#   task push: :environment do
#     command %[echo '-----> Pushing pending notifications']
#     command "#{fetch(:rpush_command)} push -e #{fetch(:rails_env)}"
#   end
#
#   desc 'Check rpush status'
#   task status: :environment do
#     command %[echo '-----> Checking rpush status']
#     command "#{fetch(:rpush_command)} status -e #{fetch(:rails_env)}"
#   end
# end
