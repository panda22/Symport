class AddIsDemoToProjects < ActiveRecord::Migration
  def change
  	add_column :projects, :is_demo, :boolean, default: false
  end
end
