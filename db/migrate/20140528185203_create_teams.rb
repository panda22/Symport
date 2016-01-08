class CreateTeams < ActiveRecord::Migration
  def change
    create_table :team_members, id: :uuid do |t|
      t.uuid :project_id
      t.uuid :user_id
      t.text :permission_level
      t.date :expiration_date
      t.boolean :view_personally_identifiable_answers, default: false
      t.timestamps
      t.datetime :deleted_at

      t.index :project_id
      t.index :user_id
      t.index :deleted_at
    end

    create_table :form_structure_permissions, id: :uuid do |t|
      t.uuid :form_structure_id
      t.uuid :user_id
      t.text :permission_level
      t.timestamps
      t.datetime :deleted_at

      t.index :form_structure_id
      t.index :user_id
      t.index :deleted_at
    end
  end
end
