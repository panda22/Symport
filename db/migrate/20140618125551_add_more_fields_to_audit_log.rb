class AddMoreFieldsToAuditLog < ActiveRecord::Migration
  def change
    add_column :audit_logs, :form_question_id, :uuid
    add_index :audit_logs, :form_question_id
    add_foreign_key :audit_logs, :form_questions, dependent: :delete

    add_column :audit_logs, :subject_id, :string
    add_index :audit_logs, :subject_id

    add_column :audit_logs, :team_member_id, :uuid
    add_index :audit_logs, :team_member_id
    add_foreign_key :audit_logs, :team_members, dependent: :delete

    rename_column :audit_logs, :new_data, :data
  end
end
