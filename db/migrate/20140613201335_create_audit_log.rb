class CreateAuditLog < ActiveRecord::Migration
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :project_id
      t.uuid :form_structure_id
      t.text :action
      t.text :old_data
      t.text :new_data
      t.timestamps

      t.index :user_id
      t.foreign_key :users, dependent: :delete

      t.index :project_id
      t.foreign_key :projects, dependent: :delete

      t.index :form_structure_id
      t.foreign_key :form_structures, dependent: :delete

      t.index :action
      t.index :created_at
    end
  end
end
