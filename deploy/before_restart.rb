Chef::Log.info("Running deploy/before_migrate.rb...")
 
Chef::Log.info("Symlinking #{release_path}/public/assets to #{new_resource.deploy_to}/shared/assets")
 
# link "#{release_path}/public/assets" do
#   to "#{new_resource.deploy_to}/shared/assets"
# end
 
rails_env = new_resource.environment["RAILS_ENV"]
Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")
 
execute "rake assets:precompile" do
  cwd release_path
  command "bundle exec rake assets:precompile"
  environment "RAILS_ENV" => rails_env
end

tmp_dir = "#{new_resource.deploy_to}/current/tmp"

directory "#{tmp_dir}/cache" do
  action :delete
  recursive true
end

directory "#{tmp_dir}/ember-rails" do
  action :delete
  recursive true
end

