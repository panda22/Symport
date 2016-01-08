set :branch, 'staging'
set :user, "vagrant"
set :use_sudo, true
set :deploy_to, "/var/www/labcompass"
set :stage_name, 'staging'
set :rails_env, 'production'
server "107.170.81.106", :app, :web, :db, primary: true
set :port, 22
