class AddAttributionColumnToProjects < ActiveRecord::Migration
  def change
  	add_column :projects, :attribution, :string, default: ""
  end
end
