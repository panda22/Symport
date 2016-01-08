class AddGettingStartedTable < ActiveRecord::Migration
  def change
  	add_column :users, :create, :boolean, default: false
  	add_column :users, :import, :boolean, default: false
  	add_column :users, :clean, :boolean, default: false
  	add_column :users, :format, :boolean, default: false
  	add_column :users, :invite, :boolean, default: false
  	User.all.update_all(create: true)
  	User.all.update_all(import: true)
  	User.all.update_all(clean: true)
  	User.all.update_all(format: true)
  	User.all.update_all(invite: true)
  end
end
