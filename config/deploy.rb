require 'bundler/capistrano'
require 'capistrano/ext/multistage'
load 'deploy/assets'

set :application, 'labcompass'

set :stages, %w(staging production)
set :default_stage, 'staging'
ssh_options[:forward_agent] = true
ssh_options[:keys] = ENV['AO_SSH_KEY_PATH']
ssh_options[:user] = 'vagrant'
default_run_options[:pty] = true

set :repository,  'git@gitlab.atomicobject.com:labcompass/labcompass.git'
set :scm, :git
set :scm_verbose, true
set :deploy_via, :remote_cache

set :use_sudo, false
set :keep_releases, 3

set :web_user, 'nobody'
set :web_group, 'www-data'

namespace :deploy do
  task :start do ; end
  task :stop  do ; end

  task :restart, roles: :app, except: { no_release: true } do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  task :pre_permissions do
    run "#{try_sudo} chown -f -R #{user}:#{user} #{deploy_to}"
  end
  task :post_permissions do
    run "#{try_sudo} chown -R #{web_user}:#{web_group} #{deploy_to}"
  end

  task :custom_symlinks do
    run "#{try_sudo} ln -nfs #{deploy_to}/shared/config/database.yml #{current_release}/config/database.yml"
  end

end

namespace :security_check do
  task :default do
    run "echo 'If you see a prompt for a password below, you do not have SSH agent forwarding set up \
        properly: hit CTRL-C and run `ssh-add`' && git \
        ls-remote git@gitlab.atomicobject.com:labcompass/labcompass.git > /dev/null"
  end
end

before 'deploy:pre_permissions', 'security_check'
before 'deploy:update_code', 'deploy:pre_permissions'
after 'deploy:setup', 'deploy:post_permissions'
after 'deploy:restart', 'deploy:post_permissions'
before 'deploy:post_permissions', 'deploy:cleanup'
