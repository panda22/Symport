class SwitchProjectsToParanoia < ActiveRecord::Migration
  def change
    remove_column :projects, :is_deleted, :boolean

    add_column :projects, :deleted_at, :datetime
    add_index :projects, :deleted_at
  end
end
