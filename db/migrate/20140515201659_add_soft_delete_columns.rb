class AddSoftDeleteColumns < ActiveRecord::Migration
  def change
    add_column :form_structures, :is_deleted, :boolean, default: false
    add_column :form_responses, :is_deleted, :boolean, default: false
    add_column :form_questions, :is_deleted, :boolean, default: false
    add_column :form_answers, :is_deleted, :boolean, default: false
  end
end
