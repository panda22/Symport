class AddDemoProgressToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :demo_progress, :integer, default: 0
  end
end
