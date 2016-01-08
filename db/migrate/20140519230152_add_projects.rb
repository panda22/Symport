class AddProjects < ActiveRecord::Migration
  def change
    create_table :projects, id: :uuid do |t|
      t.text :name
      t.boolean :is_deleted, default: false
      t.timestamps
    end

    add_column :form_structures, :project_id, :uuid
    add_index :form_structures, :project_id
    add_foreign_key :form_structures, :projects
  end
end
