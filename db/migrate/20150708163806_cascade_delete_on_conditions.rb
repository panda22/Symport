class CascadeDeleteOnConditions < ActiveRecord::Migration
  def up
    remove_foreign_key :form_question_conditions, :form_questions
    add_foreign_key :form_question_conditions, :form_questions, depedent: :delete

    remove_foreign_key :form_question_conditions, column: :depends_on_id
    add_foreign_key :form_question_conditions, :form_questions, column: :depends_on_id, depedent: :delete
  end

  def down
    remove_foreign_key :form_question_conditions, :form_questions
    add_foreign_key :form_question_conditions, :form_questions, depedent: :delete

    remove_foreign_key :form_question_conditions, column: :depends_on_id
    add_foreign_key :form_question_conditions, :form_questions, column: :depends_on_id, depedent: :delete
  end
end