set :branch, 'production'
set :user, 'mtadmin'
set :use_sudo, true
set :deploy_to, '/var/www/labcompass'
set :stage_name, 'production1'
set :rails_env, 'production'
server '10.16.4.209', :app, :web, :db, primary: true
set :port, 22
set :web_user, 'nobody'
set :web_group, 'nobody'

set :default_environment, 'PATH' => 'PATH=$PATH:/opt/ruby/bin:/usr/pgsql-9.1/bin/:/usr/local/bin'

before 'deploy:finalize_update', 'deploy:custom_symlinks'
