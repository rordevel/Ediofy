require 'mina/multistage'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
# require 'mina/hipchat'
require_relative 'deploy/recipes/resque'

set :application_name, 'ediofy'
set :execution_mode, :system
# set :domain, '54.206.86.101'
set :deploy_to, '/home/ubuntu/ediofy'
set :repository, 'https://github.com/Ediofy/ediofy.git'
#set :branch, 'jan21-branch-with-omniauth-removal'
set :branch, 'master'
set :rails_env, 'production'


# set :hipchat_room, '4104285' # roomname or id
# set :hipchat_token, 'rkoOo7LH9pvYUtpCsuHIUWJ68vbEJKVaP0qspCvX' # auth token
# Optional Data
# set :hipchat_application, 'New version of backend has been deployed on staging' # application  name
# set :hipchat_color, 'green' # Color it red. or "yellow", "green", "purple", "random" (default "yellow")
# set :hipchat_notify, true # Send notifications to users (default false)
# Optional settings:
set :user, 'ubuntu'          # Username in the server to SSH to.
set :forward_agent, true     # SSH forward_agent.
# set :identity_file, '~/.ssh/ediofy-staging.pem' #/home/tariq
# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push('public/uploads')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/cable.yml', 'config/omniauth.yml', 'config/secrets.yml', '.env', 'public/styles.css')
# set :shared_paths, ['config/database.yml', 'config/cable.yml', 'config/omniauth.yml', 'config/secrets.yml', '.env']
# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
set :bundle_bin, '/home/ubuntu/.rbenv/shims/bundle'

task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-2.3.1@default]'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
  # command %{bundle exec rake db:create}
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        invoke 'resque:restart'
        if fetch(:rails_env) != 'staging'
          command %{cd public && rm styles.css && wget http://13.236.55.137/styles.css}
        end
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
   #run(:local){ say 'done with deployment' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
