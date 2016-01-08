class AddLastViewedProjectColumn < ActiveRecord::Migration
  def change
  	add_column :users, :last_viewed_project, :string
  end
end