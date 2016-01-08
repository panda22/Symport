class AddForeignKeysForFormQuestionConditions < ActiveRecord::Migration
  def change
    remove_foreign_key :form_question_conditions, :form_questions
    add_foreign_key :form_question_conditions, :form_questions, depedent: :delete

  end
end