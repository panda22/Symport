class FormQuestionConditionsAsParanoid < ActiveRecord::Migration
  def change
    add_column :form_question_conditions, :deleted_at, :datetime
    add_index :form_question_conditions, :deleted_at
  end
end
