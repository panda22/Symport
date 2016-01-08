set :branch, 'staging'
set :user, 'vagrant'
set :use_sudo, true
set :deploy_to, '/var/www/labcompass'
set :stage_name, 'staging'
set :rails_env, 'production'
server '192.168.33.90', :app, :web, :db, primary: true
set :port, 22
set :web_user, 'nobody'
set :web_group, 'nobody'

set :default_environment, 'PATH' => 'PATH=$PATH:/opt/ruby/bin:/usr/pgsql-9.1/bin/:/usr/local/bin'

before 'deploy:finalize_update', 'deploy:custom_symlinks'
