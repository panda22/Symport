class SwitchToParanoia < ActiveRecord::Migration
  def change
    remove_column :form_answers, :is_deleted, :boolean
    remove_column :form_questions, :is_deleted, :boolean
    remove_column :form_responses, :is_deleted, :boolean
    remove_column :form_structures, :is_deleted, :boolean

    add_column :form_structures, :deleted_at, :datetime
    add_index :form_structures, :deleted_at

    add_column :form_responses, :deleted_at, :datetime
    add_index :form_responses, :deleted_at

    add_column :form_questions, :deleted_at, :datetime
    add_index :form_questions, :deleted_at

    add_column :form_answers, :deleted_at, :datetime
    add_index :form_answers, :deleted_at
  end
end
