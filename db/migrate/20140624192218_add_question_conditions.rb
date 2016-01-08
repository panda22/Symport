class AddQuestionConditions < ActiveRecord::Migration
  def change
    create_table :form_question_conditions, id: :uuid do |t|
      t.uuid :form_question_id
      t.uuid :depends_on_id
      t.text :operator
      t.text :value

      t.index :form_question_id
      t.index :depends_on_id

      t.foreign_key :form_questions, column: 'form_question_id', depedendent: :delete
      t.foreign_key :form_questions, column: 'depends_on_id', depedendent: :delete
    end
  end
end
