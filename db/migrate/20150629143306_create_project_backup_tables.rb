class CreateProjectBackupTables < ActiveRecord::Migration
  def change
    create_table :project_backups, id: :uuid do |t|
      t.xml :project_content
      t.timestamps

      t.datetime :deleted_at

      t.uuid :project_id
      t.foreign_key :projects

      t.index :deleted_at
      t.index :project_id
    end
  end
end