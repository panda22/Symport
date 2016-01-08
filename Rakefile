# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc 'continuous integration task'
task :ci do 
  Rake::Task['db:migrate_test'].invoke
  Rake::Task['spec'].invoke
  Rake::Task['teaspoon_test'].invoke
end

namespace :db do
  task :migrate_test do
    system("rake db:migrate RAILS_ENV=test")
  end

  desc "Dumps the database to ~/backups/[APP_NAME]_[DATE].sql.gz"
  task :dump => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl #{db} | gzip -c  > ~/backups/#{app}_`date -I`.sql.gz"
    end
    puts cmd
    exec cmd
  end

  desc "Backs up all projects"
  task :backup_projects do
    Rake::Task['environment'].invoke
    projects = Project.all()
    for project in projects 
      if project.name != "DO NOT RENAME *^*^ DO NOT BACKUP"
        ProjectBackup.create!({
          project_content: ProjectBackupManager.create_xml_backup_for_project(project.id),
          project_id: project.id
        })
      end
    end    
  end

  desc "Deletes items that have been deleted for more than 30 days"
  task :cleanup_paranoia do
    Rake::Task['environment'].invoke
    ParanoiaCleaner.delete_old_records() 
  end  

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end

end

task :teaspoon_test do
  system("rake teaspoon FORMATTERS=teamcity RAILS_ENV=test")
end

namespace :superuser do 

  desc 'add a user as superuser, such as rake superuser:add[user@domain.com]'
  task :add, :email do |t, args|
    Rake::Task['environment'].invoke
    user = User.find_by(email: args.email)
    user.update_attributes! super_user: true
  end

  desc 'remove a user as superuser, such as rake superuser:remove[user@domain.com]'
  task :remove, :email do |t, args|
    Rake::Task['environment'].invoke
    user = User.find_by(email: args.email)
    user.update_attributes! super_user: false
  end
end

desc "show audit log for project"
task :audit_project, :project_name do |t, args|
  Rake::Task['environment'].invoke
  project = Project.find_by(name: args.project_name)
  
  if !project
    print "\n\nNo project found with the name " + args.project_name + "\n"
  else
    id = project.id
    print "\n\n"
    print "|Action".ljust(9)
    print "|User".ljust(15)
    print "|Timestamp".ljust(27)
    print "|Form Name".ljust(15)
    print "|Subject Id".ljust(15)
    print "|Team Member"
    print "\n______________________________________________________________________________________________\n"
    AuditLog.all.each do |log|
      if log.project_id == id
        print "|" + log.action.ljust(8)
        print "|" + log.user.full_name.ljust(14)
        print "|" + log.created_at.to_s.ljust(26)
        print "|" + (log.form_response ? log.form_response.form_structure.name : "{/}" ).ljust(14)
        print "|" + (log.form_response ? log.form_response.subject_id : "{/}" ).ljust(14)      
        print "|" + (log.team_member ? log.team_member.user.full_name : "{/}" )  
        print "\n"
        print "|" + (log.old_data || "{/}") + " ==>> " + (log.data || "{/}")
        print "\n\n"
      end
    end
  end

end

desc "show failed login attempts"
task :failed_login_report => :environment do
  print "\n\n"
  print "|Failed Login IP and Email".ljust(65)
  print "|Timestamp"
  print "\n______________________________________________________________________________________________\n"
  last_data = ""
  AuditLog.all.each do |log|
    if log.action == "sign_in_failed"
      last_data=log.data
      print "|x|" + log.data.ljust(64)
      print "|" + log.created_at.to_s
      print "\n"
    elsif log.action == "sign_in" && log.data==last_data
      last_data = ""
      print "|o|" + log.data.ljust(64)
      print "|" + log.created_at.to_s
      print "\n\n" 
    end
  end
end

desc "show all users"
task :user_report => :environment do
  print "\n\n"
  print "|Email".ljust(30)
  print "|First".ljust(15)
  print "|Last".ljust(15)
  print "|Created at"
  print "\n____________________________________________________________________________________\n"
  User.all.each do |user|
    print "|" + user.email.ljust(29)
    print "|" + user.first_name.ljust(14)
    print "|" + user.last_name.ljust(14)
    print "|" + user.created_at.to_s
    print "\n" 
  end
  print "\n\n"
end

desc "show users/subjects for each project"
task :usage_report => :environment do
  max_project_users = 50
  max_project_subjects = 1000

  proj_just = Project.all.max do |p| p.name.length end.name.length + 1

  print "\n" * 2
  print "Project".ljust(proj_just)                 
  print "| Users Count".ljust(14)
  print "| Subjects Count".ljust(16)
  print "\n"
  puts "-" * (proj_just + 29)


  Project.all.each do |project|
    print project.name.ljust(proj_just)
    users = project.users.where.not(super_user: true).count
    users_alert = users > max_project_users ? "*" : ""
    subjects = project.form_responses.select(:subject_id).distinct.count
    subjects_alert = subjects > max_project_subjects ? "*" : ""
    print "| " + "#{users_alert}#{users} ".rjust(12)
    print "| " + "#{subjects_alert}#{subjects} ".rjust(15)
    print "\n"
  end
end

#example: rake user_invite[hello@world.com,production]
desc "invite already set user to symport"
task :user_invite, [:email, :environment] do |t, args|
  Rake::Task['environment'].invoke
  base_url = ""
  if args.environment == "development"
    base_url = "http://localhost:3000/"
  elsif args.environment == "staging"
    base_url = "http://secure.symportresearch.com/"
  elsif args.environment == "production"
    base_url = "http://umich.symportresearch.com/"
  else
    puts ""
    puts "usage: rails user_invite[email,[development, staging, production]]"
    puts "see rakefile for example"
    puts ""
    next
  end
  user = User.find_by(:email => args.email)
  puts "user #{user.id} retrieved"
  temp_password = SecureRandom.urlsafe_base64
  user.password = temp_password
  user.password_confirmation = temp_password
  user.save!(:validate => false)
  puts "user saved with new random password"
  pending_user = PendingUserUpdater.create_temp(user, "Welcome to Symport")
  pending_user.save!
  puts "pending user #{pending_user.id} created and saved"
  project_sql = "select t.project_id from team_members t, users u where t.user_id=u.id and u.email='#{args.email}'"
  project_id = ActiveRecord::Base.connection.execute(project_sql).first["project_id"]
  project_name = Project.find_by(:id => project_id).name
  #base_url = url_for(:controller => 'index')
  user_email = UserMailer.invite_new_user(args.email, pending_user, base_url, project_name)
  notification_email = UserMailer.notify_new_user_invite(args.email, pending_user, base_url, project_name)
  puts "emails created"
  user_email.deliver
  notification_email.deliver
  puts "emails delivered"
end

